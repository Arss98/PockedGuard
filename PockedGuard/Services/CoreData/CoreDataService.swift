//
//  CoreDataService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.06.2025.
//

import Foundation
import CoreData
import RxSwift

// MARK: - Core Data Errors
enum CoreDataError: Error {
    case entityNotFound(entityType: Any.Type)
    case relatedEntityNotFound
    case saveError(Error)
    case fetchError(Error)
    case deleteFailed
    case invalidContext
    case accountNotFound
    case categoryNotFound
}

protocol CoreDataServiceProtocol {
    func create<T: NSManagedObject>(_ operation: @escaping (NSManagedObjectContext) -> T) -> Completable
    func fetch<T: NSManagedObject & DomainConvertible>(_ type: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Single<[T.DomainModel]>
    func fetchEntityByID<T: NSManagedObject>(_ type: T.Type, id: UUID, in context: NSManagedObjectContext) throws -> T
    func update<T: NSManagedObject & DomainConvertible>(_ type: T.Type, uuid: UUID, changes: @escaping (T) -> Void) -> Single<T.DomainModel>
    func delete<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate?) -> Completable
    func performBackgroundTask<T>(_ operation: @escaping (NSManagedObjectContext) throws -> T) -> Single<T>
    func initializeDefaultData() -> Completable
}

protocol DomainConvertible {
    associatedtype DomainModel
    func toDomain() -> DomainModel
}

final class CoreDataService: CoreDataServiceProtocol {
    // MARK: - CoreData stack
    private let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load persistent store: \(error)")
            }
        }
        
        self.backgroundContext = container.newBackgroundContext()
        self.backgroundContext.automaticallyMergesChangesFromParent = true
        self.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.backgroundContext.undoManager = nil
    }
    
    convenience init(modelName: String = "PockedGuard") {
        let container = NSPersistentContainer(name: modelName)
        self.init(container: container)
    }
    
    // MARK: - Context Management
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func performBackgroundTask<T>(_ operation: @escaping (NSManagedObjectContext) throws -> T) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(CoreDataError.invalidContext))
                return Disposables.create()
            }
            
            self.persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                do {
                    let result = try operation(context)
                    
                    if context.hasChanges {
                        try context.save()
                    }
                    
                    single(.success(result))
                } catch {
                    context.rollback()
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - CRUD Operations
extension CoreDataService {
    func create<T: NSManagedObject>(_ operation: @escaping (NSManagedObjectContext) -> T) -> Completable {
        return performBackgroundTask { context in
            _ = operation(context)
            if context.hasChanges {
                try context.save()
            }
        }
        .asCompletable()
    }
    
    func fetch<T: NSManagedObject & DomainConvertible>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> Single<[T.DomainModel]> {
        return performBackgroundTask { context in
            let request = NSFetchRequest<T>(entityName: String(describing: type))
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            
            let results = try context.fetch(request)
            return results.map { $0.toDomain() }
        }
    }
    
    func fetchEntityByID<T: NSManagedObject>(_ type: T.Type, id: UUID, in context: NSManagedObjectContext) throws -> T {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: type))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let results = try context.fetch(fetchRequest)
        
        guard let entity = results.first else {
            throw CoreDataError.entityNotFound(entityType: type)
        }
        
        return entity
    }
    
    func update<T: NSManagedObject & DomainConvertible>(_ type: T.Type, uuid: UUID, changes: @escaping (T) -> Void) -> Single<T.DomainModel> {
        return performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
            fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            
            guard let objectInContext = try context.fetch(fetchRequest).first else {
                throw CoreDataError.entityNotFound(entityType: type)
            }
            
            changes(objectInContext)
            
            return objectInContext.toDomain()
        }
    }

    func delete<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil) -> Completable {
        return performBackgroundTask { context in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
            request.predicate = predicate
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
            }
        }.asCompletable()
    }
    
    func initializeDefaultData() -> Completable {
        createDefaultCategories().andThen(createDefaultAccount())
    }
}

// MARK: - Create default entity
private extension CoreDataService {
    func createDefaultAccount() -> Completable {
        return performBackgroundTask { context in
            let account: Account = Account(context: context)
            account.id = UUID()
            account.isPrimary = true
            account.name = L10n.Finance.defaultAccount
            account.balance = 0
            account.currency = "RUB"
            account.date = Date()
            
            if context.hasChanges {
                try context.save()
            }
        }
        .asCompletable()
    }
    
    func createDefaultCategories() -> Completable {
        return performBackgroundTask { context in
            let incomeCategories: [(nameKey: String, color: String)] = [
                (L10n.IncomeCategories.salary, "#4CAF50"),
                (L10n.IncomeCategories.investments, "#2196F3"),
                (L10n.IncomeCategories.gifts, "#FF9800"),
                (L10n.IncomeCategories.other, "#607D8B")
            ]
            
            for category in incomeCategories {
                let categoryEntity = Category(context: context)
                categoryEntity.id = UUID()
                categoryEntity.name = category.nameKey
                categoryEntity.color = category.color
                categoryEntity.type = TransactionType.income.rawValue
                categoryEntity.isSystem = true
            }
            
            let expenseCategories: [(nameKey: String, color: String)] = [
                (L10n.TransactionCategories.health, "#FF5252"),
                (L10n.TransactionCategories.products, "#4CAF50"),
                (L10n.TransactionCategories.clothes, "#2196F3"),
                (L10n.TransactionCategories.leisure, "#FF9800"),
                (L10n.TransactionCategories.housing, "#9C27B0"),
                (L10n.TransactionCategories.other, "#607D8B")
            ]
            
            for category in expenseCategories {
                let categoryEntity = Category(context: context)
                categoryEntity.id = UUID()
                categoryEntity.name = category.nameKey
                categoryEntity.color = category.color
                categoryEntity.type = TransactionType.expense.rawValue
                categoryEntity.isSystem = true
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
        .asCompletable()
    }
}
