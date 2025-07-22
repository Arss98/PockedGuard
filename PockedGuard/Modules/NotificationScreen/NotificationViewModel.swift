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
    func fetchNotifications()
    func getNotification(at indexPath: IndexPath) -> NotificationDomainModel?
    func updateNotificationIsActive(id: UUID, isActive: Bool)
}

final class NotificationViewModel: NotificationViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let coreDataService: CoreDataNotificationProtocol
    private let notificationScheduler: NotificationSchedulerProtocol
    private let disposeBag: DisposeBag = .init()
    
    enum State {
        case loading
        case loaded
        case error(Error)
    }
    
    // MARK: - Init
    init(
        coreDataService: CoreDataNotificationProtocol = CoreDataService.shared,
        notificationScheduler: NotificationSchedulerProtocol = NotificationScheduler()
    ) {
        self.coreDataService = coreDataService
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
    }
    
    func fetchNotifications() {
        self.output.state.accept(.loading)
        
        coreDataService.fetchNotifications()
            .subscribe(with: self) { viewModel, notifications in
                viewModel.output.notifications.accept(notifications)
                viewModel.output.state.accept(.loaded)
            } onError: { viewModel, error in
                viewModel.output.state.accept(.error(CustomError.notificationFetchFailed))
            }
            .disposed(by: disposeBag)
    }
    
    func getNotification(at indexPath: IndexPath) -> NotificationDomainModel? {
        let currentNotification: [NotificationDomainModel] = output.notifications.value
        guard indexPath.row < currentNotification.count else { return nil }
        
        return currentNotification[indexPath.row]
    }
    
    func updateNotificationIsActive(id: UUID, isActive: Bool) {
        coreDataService.updateNotification(id: id, newTitle: nil, newNotes: nil, newDate: nil, newIsActive: isActive, newReminderType: nil)
            .subscribe(with: self, onSuccess: { viewModel, updateModel in
                guard let updateModel else { return }
                
                var currentNotification: [NotificationDomainModel] = viewModel.output.notifications.value
                if let index = currentNotification.firstIndex(where: { $0.id == id }) {
                    currentNotification[index] = updateModel
                    viewModel.output.notifications.accept(currentNotification)
                }
                
                do {
                   try viewModel.notificationScheduler.updateNotification(
                        id: id,
                        title: updateModel.title,
                        body: updateModel.notes,
                        date: updateModel.date,
                        reminderType: updateModel.reminderType,
                        isActive: isActive
                    )
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
        var currentNotifications = output.notifications.value
        guard indexPath.row < currentNotifications.count else { return }
        
        let idToDelete: UUID = currentNotifications[indexPath.row].id
        currentNotifications.remove(at: indexPath.row)
        output.notifications.accept(currentNotifications)
        
        coreDataService.deleteNotification(id: idToDelete)
            .subscribe(with: self, onError: { viewModel, error in
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
            return .Localized.Error.notificationUpdateFailed.localized
        case .notificationFetchFailed:
            return .Localized.Error.notificationFetchFailed.localized
        case .notificationDeleteFailed:
            return .Localized.Error.notificationDeleteFailed.localized
        }
    }
}
