//
//  NotificationRepository.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 15.09.2025.
//

import RxSwift
import RxCocoa

protocol NotificationRepositoryProtocol {
    var notifications: BehaviorRelay<[NotificationDomainModel]> { get }
    func createNotification(_ notification: NotificationDomainModel) -> Completable
    func updateNotification(id: UUID, newTitle: String?, newNotes: String?, newDate: Date?,
                            newIsActive: Bool?, newReminderType: ReminderType?) -> Single<NotificationDomainModel?>
    func deleteNotification(with id: UUID) -> Completable
}

final class NotificationRepository: NotificationRepositoryProtocol {
    // MARK: - Public properties
    let notifications: BehaviorRelay<[NotificationDomainModel]> = .init(value: [])
    
    // MARK: - Private properties
    private let coreDataService: CoreDataServiceProtocol
    private let disposeBag: DisposeBag = .init()
    private let sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "date", ascending: false)]
    private let backgroundScheduler: ConcurrentDispatchQueueScheduler = .init(qos: .userInitiated)
    
    init(coreDataService: CoreDataServiceProtocol) {
        self.coreDataService = coreDataService
        fetchNotifications()
    }
}

// MARK: - NotificationRepositoryProtocol
extension NotificationRepository {
    func createNotification(_ notification: NotificationDomainModel) -> Completable {
        Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.create { context in
                let notificationEntity: NotificationModel = NotificationModel(context: context)
                notificationEntity.id = notification.id
                notificationEntity.title = notification.title
                notificationEntity.notes = notification.notes
                notificationEntity.date = notification.date
                notificationEntity.isActive = notification.isActive
                notificationEntity.reminderType = notification.reminderType.rawValue
                return notificationEntity
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: {
                self.fetchNotifications()
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
    
    func updateNotification(id: UUID, newTitle: String?, newNotes: String?, newDate: Date?, newIsActive: Bool?, newReminderType: ReminderType?) -> Single<NotificationDomainModel?> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.update(NotificationModel.self, uuid: id) { notificationEntity in
                newTitle.map { notificationEntity.title = $0 }
                newNotes.map { notificationEntity.notes = $0 }
                newDate.map { notificationEntity.date = $0 }
                newIsActive.map { notificationEntity.isActive = $0 }
                newReminderType.map { notificationEntity.reminderType = $0.rawValue }
            }
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { notification in
                self.fetchNotifications()
                single(.success(notification))
            }, onFailure: { error in
                single(.failure(error))
            })
        }
    }
    
    func deleteNotification(with id: UUID) -> Completable {
        Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(RepositoryError.deinitialized))
                return Disposables.create()
            }
            
            return self.coreDataService.delete(NotificationModel.self, predicate: NSPredicate(format: "id == %@", id as CVarArg))
                .subscribe(on: backgroundScheduler)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: {
                    self.fetchNotifications()
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
        }
    }
}

// MARK: - Private methods
private extension NotificationRepository {
    func fetchNotifications() {
        coreDataService.fetch(NotificationModel.self, predicate: nil, sortDescriptors: sortDescriptors)
            .subscribe(on: backgroundScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] notifications in
                self?.notifications.accept(notifications)
            } onFailure: { error in
                print("Error fetching notifications: \(error)")
            }
            .disposed(by: disposeBag)
    }
}
