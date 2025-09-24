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
    var currentTransactionType: BehaviorRelay<TransactionType> { get }
    var dataInitialized: PublishRelay<Void> { get }
    func createCategory(_ category: CategoryDomainModel) -> Completable
    func updateCategory(id: UUID, newName: String?, newColor: String?) -> Single<CategoryDomainModel?>
    func deleteCategory(with id: UUID) -> Completable
}

final class CategoryRepository: CategoryRepositoryProtocol {
    // MARK: - Public properties
    let categories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
    let currentTransactionType: BehaviorRelay<TransactionType> = .init(value: .income)
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
                self.fetchCategoriesByType()
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
    
    func updateCategory(id: UUID, newName: String?, newColor: String?) -> Single<CategoryDomainModel?> {
        Single.create { [weak self] single in
            guard let self else {
                single(.failure(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.update(Category.self, uuid: id) { categoryEntity in
                newName.map { categoryEntity.name = $0 }
                newColor.map { categoryEntity.color = $0 }
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { category in
                self.fetchCategoriesByType()
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
                    self.fetchCategoriesByType()
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
        }
    }
}

// MARK: - Private methods
private extension CategoryRepository {
    func setupBindings() {
        currentTransactionType
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
            } onFailure: { error in
                print("Error fetching all categories: \(error)")
            }
            .disposed(by: disposeBag)
    }
    
    func fetchCategoriesByType() {
        let type: TransactionType = currentTransactionType.value
        let predicate: NSPredicate? = NSPredicate(format: "type == %d", type.rawValue)
        fetchCategories(predicate)
    }
    
    func cacheCategories(_ categories: [CategoryDomainModel]) {
        let groupedCategories: [TransactionType : [CategoryDomainModel]] = Dictionary(grouping: categories, by: { $0.type })
        for (type, categories) in groupedCategories {
            categoriesCache[type] = categories
        }
    }
    
    func updateCategoriesForCurrentType() {
        let currentType: TransactionType = currentTransactionType.value
        let filteredCategories: [CategoryDomainModel] = categoriesCache[currentType] ?? []
        categories.accept(filteredCategories)
    }
}
