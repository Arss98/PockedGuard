//
//  NotificationViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

protocol NotificationViewModelProtocol {
    var input: NotificationViewModel.Input { get }
    var output: NotificationViewModel.Output { get }
    func getNotification(at indexPath: IndexPath) -> NotificationDomainModel?
    func updateNotificationIsActive(id: UUID, isActive: Bool)
}

final class NotificationViewModel: NotificationViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let dataProvider: DataProviderProtocol
    private let notificationScheduler: NotificationSchedulerProtocol
    private let disposeBag: DisposeBag = .init()
    
    enum State {
        case loading
        case loaded
        case error(Error)
    }
    
    // MARK: - Init
    init(
        dataProvider: DataProviderProtocol,
        notificationScheduler: NotificationSchedulerProtocol = NotificationScheduler()
    ) {
        self.dataProvider = dataProvider
        self.notificationScheduler = notificationScheduler
        self.input = .init()
        self.output = .init()
        setupBinding()
    }
}

// MARK: - Public methods
extension NotificationViewModel {
    func setupBinding() {
        input.deleteNotification
            .subscribe(with: self) { viewModel, indexPath in
                viewModel.deleteNotification(at: indexPath)
            }
            .disposed(by: disposeBag)
        
        dataProvider.notifications.notifications
            .map { $0.sorted(by: { $0.id.uuidString < $1.id.uuidString }) }
            .distinctUntilChanged { old, new in
                guard old.count == new.count else { return false }
                return zip(old, new).allSatisfy { oldItem, newItem in
                    oldItem.id == newItem.id &&
                    oldItem.title == newItem.title &&
                    oldItem.notes == newItem.notes &&
                    oldItem.date == newItem.date &&
                    oldItem.reminderType == newItem.reminderType
                }
            }
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { viewModel, notifications in
                viewModel.output.notifications.accept(notifications)
            }
            .disposed(by: disposeBag)
    }
    
    func getNotification(at indexPath: IndexPath) -> NotificationDomainModel? {
        let currentNotification: [NotificationDomainModel] = output.notifications.value
        guard indexPath.row < currentNotification.count else { return nil }
        
        return currentNotification[indexPath.row]
    }
    
    func updateNotificationIsActive(id: UUID, isActive: Bool) {
        dataProvider.notifications.updateNotification(id: id, newTitle: nil, newNotes: nil, newDate: nil, newIsActive: isActive, newReminderType: nil)
            .subscribe(with: self, onSuccess: { viewModel, updatedNotification in
                guard let updatedNotification else {
                    viewModel.output.state.accept(.error(CustomError.notificationUpdateFailed))
                    return
                }
                
                do {
                   try viewModel.notificationScheduler.updateNotification(
                        id: id,
                        title: updatedNotification.title,
                        body: updatedNotification.notes,
                        date: updatedNotification.date,
                        reminderType: updatedNotification.reminderType,
                        isActive: isActive
                    )
                    viewModel.output.state.accept(.loaded)
                } catch {
                    viewModel.output.state.accept(.error(CustomError.notificationUpdateFailed))
                }
            }, onFailure: { viewModel, error in
                viewModel.output.state.accept(.error(CustomError.notificationUpdateFailed))
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private methods
private extension NotificationViewModel {
    func deleteNotification(at indexPath: IndexPath) {
        output.state.accept(.loading)
        
        let currentNotifications = output.notifications.value
        guard indexPath.row < currentNotifications.count else { return }
        
        let idToDelete: UUID = currentNotifications[indexPath.row].id
        output.notifications.accept(currentNotifications.filter { $0.id != idToDelete })
        
        dataProvider.notifications.deleteNotification(with: idToDelete)
            .subscribe(with: self, onCompleted: { viewModel in
                viewModel.notificationScheduler.removeNotification(id: idToDelete)
                viewModel.output.state.accept(.loaded)
            }, onError: { viewModel, error in
                viewModel.output.state.accept(.error(CustomError.notificationDeleteFailed))
            })
            .disposed(by: disposeBag)
        
        notificationScheduler.removeNotification(id: idToDelete)
    }
}

// MARK: - Input, Output
extension NotificationViewModel {
    struct Input {
        let createNotificationTapped: PublishSubject<Void> = .init()
        let selectedNotification: PublishSubject<NotificationDomainModel> = .init()
        let deleteNotification: PublishSubject<IndexPath> = .init()
    }
    
    struct Output {
        let notifications: BehaviorRelay<[NotificationDomainModel]> = .init(value: [])
        let state: PublishRelay<State> = .init()
        private let _notification: BehaviorRelay<[NotificationDomainModel]> = .init(value: [])
    }
}

// MARK: - Error
private enum CustomError: Error, LocalizedError {
    case notificationUpdateFailed
    case notificationFetchFailed
    case notificationDeleteFailed
    
    var errorDescription: String? {
        switch self {
        case .notificationUpdateFailed:
            return L10n.Error.Notifications.updateFailed
        case .notificationFetchFailed:
            return L10n.Error.Notifications.fetchFailed
        case .notificationDeleteFailed:
            return L10n.Error.Notifications.deleteFailed
        }
    }
}
