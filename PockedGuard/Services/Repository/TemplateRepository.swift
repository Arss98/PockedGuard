//
//  TemplateRepository.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.09.2025.
//

import RxSwift
import RxCocoa
import CoreData

protocol TemplateRepositoryProtocol {
    var templates: BehaviorRelay<[TemplateDomainModel]> { get }
    var templateError: PublishRelay<Error> { get }
    var currentTransactionType: BehaviorRelay<TransactionType> { get }
    func getTemplates(type: TransactionType?) -> [TemplateDomainModel]
    func createTemplate(_ tempalte: TemplateDomainModel) -> Completable
    func deleteTemplate(with id: UUID) -> Completable
    func updateTemplate(id: UUID, newIcon: String?, newType: TransactionType?, newAmount: Double?,
                        newCategoryID: UUID?) -> Single<TemplateDomainModel?>
}

final class TemplateRepository: TemplateRepositoryProtocol {
    // MARK: - Public properties
    let templates: BehaviorRelay<[TemplateDomainModel]> = .init(value: [])
    let templateError: PublishRelay<Error> = .init()
    let currentTransactionType: BehaviorRelay<TransactionType> = .init(value: .expense)
    
    // MARK: - Private properties
    private let coreDataService: CoreDataServiceProtocol
    private let disposeBag: DisposeBag = .init()
    private let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "icon", ascending: true)]
    private let backgroundScheduler: ConcurrentDispatchQueueScheduler = .init(qos: .userInitiated)
    private var templatesCache: [TransactionType: [TemplateDomainModel]] = [:]
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
        setupBindings()
        fetchTemplates()
    }
}

// MARK: - TemplateRepositoryProtocol
extension TemplateRepository {
    func createTemplate(_ template: TemplateDomainModel) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.performBackgroundTask { context in
                let templateEntity: Templates = Templates(context: context)
                templateEntity.id = template.id
                templateEntity.icon = template.icon
                templateEntity.type = template.type.rawValue
                templateEntity.amount = template.amount ?? .zero
                
                if let categoryId = template.category?.id {
                    let category = try self.coreDataService.fetchEntityByID(Category.self, id: categoryId, in: context)
                    templateEntity.category = category
                }
                
                return templateEntity
            }
            .asCompletable()
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.fetchTemplates()
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
    
    func updateTemplate(id: UUID, newIcon: String?, newType: TransactionType?, newAmount: Double?,
                        newCategoryID: UUID?) -> Single<TemplateDomainModel?> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.performBackgroundTask { context in
                let templateEntity = try self.coreDataService.fetchEntityByID(Templates.self, id: id, in: context)
                
                newIcon.map { templateEntity.icon = $0 }
                newType.map { templateEntity.type = $0.rawValue }
                newAmount.map { templateEntity.amount = $0 }
                
                if let newCategoryID {
                    let category = try self.coreDataService.fetchEntityByID(Category.self, id: newCategoryID, in: context)
                    
                    templateEntity.category = category
                }
                
                return templateEntity.toDomain()
            }
            .subscribe(on: self.backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { template in
                self.fetchTemplates()
                single(.success(template))
            }, onFailure: { error in
                single(.failure(error))
            })
        }
    }
    
    func deleteTemplate(with id: UUID) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.delete(Templates.self, predicate: NSPredicate(format: "id == %@", id as CVarArg))
                .subscribe(on: backgroundScheduler)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: {
                    self.fetchTemplates()
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
        }
    }
    
    func getTemplates(type: TransactionType?) -> [TemplateDomainModel] {
        guard let type else { return [] }
        return templatesCache[type] ?? []
    }
}

// MARK: - Private methods
private extension TemplateRepository {
    func setupBindings() {
        currentTransactionType
            .subscribe(onNext: { [weak self] transactionType in
                self?.updateTemplatesForCurrentType()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchTemplates(_ predicate: NSPredicate? = nil) {
        coreDataService.fetch(Templates.self, predicate: predicate, sortDescriptors: sortDescriptors)
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] templates in
                self?.cacheTemplates(templates)
                self?.updateTemplatesForCurrentType()
            } onFailure: { [weak self] error in
                self?.templateError.accept(error)
            }
            .disposed(by: disposeBag)
    }
    
    func cacheTemplates(_ templates: [TemplateDomainModel]) {
        var newCache: [TransactionType: [TemplateDomainModel]] = [:]
        
        TransactionType.allCases.forEach { type in
            newCache[type] = []
        }
        
        let groupedTemplates: [TransactionType: [TemplateDomainModel]] = Dictionary(grouping: templates, by: { $0.type })
        for (type, templates) in groupedTemplates {
            newCache[type] = templates
        }
        
        if templates.isEmpty {
            newCache[currentTransactionType.value] = []
        }
        
        templatesCache = newCache
    }
    
    func updateTemplatesForCurrentType() {
        let currentType: TransactionType = currentTransactionType.value
        let filteredTemplates: [TemplateDomainModel] = templatesCache[currentType] ?? []
        templates.accept(filteredTemplates)
    }
}
