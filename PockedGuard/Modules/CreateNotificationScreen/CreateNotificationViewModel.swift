//
//  CreateNotificationViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

protocol CreateNotificationViewModelProtocol {
    var input: CreateNotificationViewModel.Input { get }
    var output: CreateNotificationViewModel.Output { get }
    var mode: CreateNotificationViewModel.Mode { get }
}

final class CreateNotificationViewModel: CreateNotificationViewModelProtocol {
    // MARK: - public Properties
    let input: Input
    let output: Output
    let mode: Mode
    
    // MARK: - Private properties
    private let combainedDateTime: BehaviorRelay<Date> = .init(value: Date())
    private let dataProvider: DataProviderProtocol
    private let notificationScheduler: NotificationSchedulerProtocol
    private let disposeBag: DisposeBag = .init()
    
    enum Mode {
        case add
        case edit(NotificationDomainModel)
    }
    
    // MARK: - Init
    init(
        mode: Mode,
        dataProvider: DataProviderProtocol ,
        notificationScheduler: NotificationSchedulerProtocol = NotificationScheduler()
    ) {
        self.dataProvider = dataProvider
        self.notificationScheduler = notificationScheduler
        self.mode = mode
        self.input = .init()
        self.output = .init()
        setInitialValues()
        setupBindings()
    }
}

// MARK: - Private methods
private extension CreateNotificationViewModel {
    func setupBindings() {
        input.saveAction
            .subscribe(onNext: { [weak self] in
                self?.saveNotification()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.date, input.time) { date, time in
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
    
    func setInitialValues() {
        if case .edit(let notification) = mode {
            input.title.accept(notification.title)
            input.notes.accept(notification.notes)
            input.date.accept(notification.date)
            input.reminderType.accept(notification.reminderType)
        }
    }
    
    func saveNotification() {
        output.isLoading.accept(true)
        
        do {
            try validateInput()
            
            let operation: Completable = {
                switch mode {
                case .add: return addNotification()
                case .edit(let notification): return updateNotification(notification: notification)
                }
            }()
            
            operation
                .subscribe(
                    onCompleted: { [weak self] in
                        self?.output.isLoading.accept(false)
                        self?.output.didFinish.onNext(())
                    },
                    onError: { [weak self] error in
                        self?.output.isLoading.accept(false)
                        self?.output.error.onNext(error)
                    }
                )
                .disposed(by: disposeBag)
        } catch {
            output.isLoading.accept(false)
            output.error.onNext(error)
        }
    }

    func validateInput() throws {
        guard !input.title.value.isEmpty else { throw CustomError.invalidTitle }
        guard !input.notes.value.isEmpty else { throw CustomError.invalidNotes }
    }
    
    func addNotification() -> Completable {
        let notification: NotificationDomainModel = .init(
            id: UUID(),
            title: input.title.value,
            notes: input.notes.value,
            date: combainedDateTime.value,
            isActive: true,
            reminderType: input.reminderType.value
        )
        
        return dataProvider.notifications.createNotification(notification)
            .andThen(Completable.create { [weak self] completable in
                guard let self else { return Disposables.create() }
                do {
                    try self.notificationScheduler.scheduleNotification(
                        id: notification.id,
                        title: notification.title,
                        body: notification.notes,
                        date: notification.date,
                        reminderType: notification.reminderType,
                        isActive: notification.isActive
                    )
                    completable(.completed)
                } catch {
                    completable(.error(CustomError.notificationSchedulingFailed))
                }
                return Disposables.create()
            })
    }
    
    func updateNotification(notification: NotificationDomainModel) -> Completable {
        dataProvider.notifications.updateNotification(
            id: notification.id,
            newTitle: input.title.value,
            newNotes: input.notes.value,
            newDate: combainedDateTime.value,
            newIsActive: nil,
            newReminderType: input.reminderType.value
        )
        .asCompletable()
        .andThen(Completable.create { [weak self] completable in
            guard let self else { return Disposables.create() }
            do {
                try self.notificationScheduler.updateNotification(
                    id: notification.id,
                    title: self.input.title.value,
                    body: self.input.notes.value,
                    date: self.combainedDateTime.value,
                    reminderType: self.input.reminderType.value,
                    isActive: true
                )
                completable(.completed)
            } catch {
                completable(.error(CustomError.notificationUpdateFailed))
            }
            return Disposables.create()
        })
    }
}

// MARK: - Input, Output
extension CreateNotificationViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
        let title: BehaviorRelay<String> = .init(value: "")
        let notes: BehaviorRelay<String> = .init(value: "")
        let time: BehaviorRelay<Date> = .init(value: Date())
        let date: BehaviorRelay<Date> = .init(value: Date())
        let reminderType: BehaviorRelay<ReminderType> = .init(value: .once)
    }
    
    struct Output {
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
        let didFinish: PublishSubject<Void> = .init()
        let error: PublishSubject<Error> = .init()
    }
}


// MARK: - Error
private enum CustomError: Error, LocalizedError {
    case invalidTitle
    case invalidNotes
    case notificationSchedulingFailed
    case notificationUpdateFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return L10n.Error.titleEmpty
        case .invalidNotes:
            return L10n.Error.descriptionEmpty
        case .notificationSchedulingFailed:
            return L10n.Error.Notifications.schedulingFailed
        case .notificationUpdateFailed:
            return L10n.Error.Notifications.updateFailed
        }
    }
}
