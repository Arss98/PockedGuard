//
//  CreateNotificationViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

protocol CreateNotificationViewModelProtocol {
    var title: BehaviorRelay<String> { get }
    var notes: BehaviorRelay<String> { get }
    var time: BehaviorRelay<Date> { get }
    var date: BehaviorRelay<Date> { get }
    var reminderType: BehaviorRelay<ReminderType> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    var mode: CreateNotificationViewModel.Mode { get }
    func saveNotification() -> Completable
}

final class CreateNotificationViewModel: CreateNotificationViewModelProtocol {
    // MARK: - Properties
    let title: BehaviorRelay<String> = .init(value: "")
    let notes: BehaviorRelay<String> = .init(value: "")
    let time: BehaviorRelay<Date> = .init(value: Date())
    let date: BehaviorRelay<Date> = .init(value: Date())
    let reminderType: BehaviorRelay<ReminderType> = .init(value: .once)
    let isLoading: BehaviorRelay<Bool> = .init(value: false)
    let mode: Mode
    
    private let combainedDateTime: BehaviorRelay<Date> = .init(value: Date())
    private let coreDataService: CoreDataNotificationProtocol
    private let notificationScheduler: NotificationSchedulerProtocol
    private var notificationToEdit: NotificationDomainModel?
    private let disposeBag: DisposeBag = .init()
    
    enum Mode {
        case add
        case edit(NotificationDomainModel)
    }
    
    // MARK: - Init
    init(
        mode: Mode,
        coreDataService: CoreDataNotificationProtocol = CoreDataService.shared,
        notificationScheduler: NotificationSchedulerProtocol = NotificationScheduler()
    ) {
        self.coreDataService = coreDataService
        self.notificationScheduler = notificationScheduler
        self.mode = mode
        setInitialValues()
        setupCombineDateTime()
    }
}

// MARK: - Public methods
extension CreateNotificationViewModel {
    func saveNotification() -> Completable {
        isLoading.accept(true)
        
        let operation: Completable = {
            switch mode {
            case .add: return addNotification()
            case .edit(let notification): return updateNotification(notification: notification)
            }
        }()
        
        return operation
            .do(onDispose: { [weak self] in
                self?.isLoading.accept(false)
            })
            .andThen(Completable.deferred { [weak self] in
                self?.isLoading.accept(false)
                return .empty()
            })
            .catch { [weak self] error in
                self?.isLoading.accept(false)
                throw error
            }
    }
}

// MARK: - Private methods
private extension CreateNotificationViewModel {
    func setInitialValues() {
        if case .edit(let notification) = mode {
            self.notificationToEdit = notification
            title.accept(notification.title)
            notes.accept(notification.notes)
            date.accept(notification.date)
            reminderType.accept(notification.reminderType)
        }
    }
    
    func addNotification() -> Completable {
        let notification: NotificationDomainModel = .init(
            id: UUID(),
            title: title.value,
            notes: notes.value,
            date: combainedDateTime.value,
            isActive: true,
            reminderType: reminderType.value
        )
        
        return coreDataService.addNotification(notification)
            .andThen(Completable.create { [weak self] completable in
                guard let self else { return Disposables.create() }
                self.notificationScheduler.scheduleNotification(
                    id: notification.id,
                    title: notification.title,
                    body: notification.notes,
                    date: notification.date,
                    reminderType: notification.reminderType,
                    isActive: notification.isActive
                )
                completable(.completed)
                return Disposables.create()
            })
    }
    
    func updateNotification(notification: NotificationDomainModel) -> Completable {
        coreDataService.updateNotification(
            id: notification.id,
            newTitle: title.value,
            newNotes: notes.value,
            newDate: combainedDateTime.value,
            newIsActive: nil,
            newReminderType: reminderType.value
        )
        .asCompletable()
        .andThen(Completable.create { [weak self] completable in
            guard let self else { return Disposables.create() }
            self.notificationScheduler.updateNotification(
                id: notification.id,
                title: self.title.value,
                body: self.notes.value,
                date: self.combainedDateTime.value,
                reminderType: self.reminderType.value,
                isActive: true
            )
            completable(.completed)
            return Disposables.create()
        })
    }
    
    func setupCombineDateTime() {
        Observable.combineLatest(date, time) { date, time in
            Calendar.current.date(
                bySettingHour: Calendar.current.component(.hour, from: time),
                minute: Calendar.current.component(.minute, from: time),
                second: .zero,
                of: date
            ) ?? Date()
        }
        .bind(to: combainedDateTime)
        .disposed(by: disposeBag)
    }
}
