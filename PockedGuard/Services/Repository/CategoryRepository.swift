//
//  CategoryRepository.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.09.2025.
//

import RxSwift
import RxCocoa

protocol CategoryRepositoryProtocol {
    var categories: BehaviorRelay<[CategoryDomainModel]> { get }
    var categoriesError: PublishRelay<Error> { get }
    var currentTransactionType: BehaviorRelay<TransactionType> { get }
    var dataInitialized: PublishRelay<Void> { get }
    func getCategories(type: TransactionType?) -> [CategoryDomainModel]
    func createCategory(_ category: CategoryDomainModel) -> Completable
    func deleteCategory(with id: UUID) -> Completable
    func updateCategory(id: UUID, newName: String?, newColor: String?,
                        newType: TransactionType?) -> Single<CategoryDomainModel?>
}

final class CategoryRepository: CategoryRepositoryProtocol {
    // MARK: - Public properties
    let categories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
    let categoriesError: PublishRelay<Error> = .init()
    let currentTransactionType: BehaviorRelay<TransactionType> = .init(value: .expense)
    let dataInitialized: PublishRelay<Void> = .init()
    
    // MARK: - Private properties
    private let coreDataService: CoreDataServiceProtocol
    private let disposeBag: DisposeBag = .init()
    private let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "name", ascending: true)]
    private let backgroundScheduler: ConcurrentDispatchQueueScheduler = .init(qos: .userInitiated)
    private var categoriesCache: [TransactionType: [CategoryDomainModel]] = [:]
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
        setupBindings()
        fetchCategories()
    }
}

// MARK: - CategoryRepositoryProtocol
extension CategoryRepository {
    func createCategory(_ category: CategoryDomainModel) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.create { context in
                let categoryEntity: Category = Category(context: context)
                categoryEntity.id = category.id
                categoryEntity.name = category.name
                categoryEntity.color = category.color
                categoryEntity.type = category.type.rawValue
                categoryEntity.isSystem = false
                return categoryEntity
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.fetchCategories()
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
    
    func updateCategory(id: UUID, newName: String?, newColor: String?, newType: TransactionType?) -> Single<CategoryDomainModel?> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.update(Category.self, uuid: id) { categoryEntity in
                newName.map { categoryEntity.name = $0 }
                newColor.map { categoryEntity.color = $0 }
                newType.map { categoryEntity.type = $0.rawValue}
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { category in
                self.fetchCategories()
                single(.success(category))
            }, onFailure: { error in
                single(.failure(error))
            })
        }
    }
    
    func deleteCategory(with id: UUID) -> Completable {
        Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.delete(Category.self, predicate: NSPredicate(format: "id == %@", id as CVarArg))
                .subscribe(on: backgroundScheduler)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: {
                    self.fetchCategories()
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
        }
    }
    
    func getCategories(type: TransactionType?) -> [CategoryDomainModel] {
        guard let type else { return [] }
        return categoriesCache[type] ?? []
    }
}

// MARK: - Private methods
private extension CategoryRepository {
    func setupBindings() {
        currentTransactionType.distinctUntilChanged()
            .subscribe(onNext: { [weak self] transactionType in
                self?.updateCategoriesForCurrentType()
            })
            .disposed(by: disposeBag)
        
        dataInitialized
            .subscribe(onNext: { [weak self] in
                self?.fetchCategories()
            })
            .disposed(by: disposeBag)
    }
    
    func fetchCategories(_ predicate: NSPredicate? = nil) {
        coreDataService.fetch(Category.self, predicate: predicate, sortDescriptors: sortDescriptors)
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] categories in
                self?.cacheCategories(categories)
                self?.updateCategoriesForCurrentType()
            } onFailure: { [weak self] error in
                self?.categoriesError.accept(error)
            }
            .disposed(by: disposeBag)
    }
    
    func cacheCategories(_ categories: [CategoryDomainModel]) {
        var newCache: [TransactionType: [CategoryDomainModel]] = [:]
        
        TransactionType.allCases.forEach { type in
            newCache[type] = []
        }
        
        let groupedCategories: [TransactionType : [CategoryDomainModel]] = Dictionary(grouping: categories, by: { $0.type })
        for (type, categories) in groupedCategories {
            newCache[type] = categories
        }
        
        if categories.isEmpty {
            newCache[currentTransactionType.value] = []
        }
        
        categoriesCache = newCache
    }
    
    func updateCategoriesForCurrentType() {
        let currentType: TransactionType = currentTransactionType.value
        let filteredCategories: [CategoryDomainModel] = categoriesCache[currentType] ?? []
        categories.accept(filteredCategories)
    }
}
