//
//  NotificationViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

protocol NotificationViewModelProtocol {
    var notifications: BehaviorRelay<[NotificationDomainModel]> { get }
    var state: PublishRelay<NotificationViewModel.State> { get }
    var createNotificationTapped: PublishSubject<Void> { get }
    var selectedNotification: PublishSubject<NotificationDomainModel> { get }
    func fetchNotifications()
    func getNotification(at indexPath: IndexPath) -> NotificationDomainModel?
    func updateNotificationIsActive(id: UUID, isActive: Bool)
    func deleteNotification(at indexPath: IndexPath)
}

final class NotificationViewModel: NotificationViewModelProtocol {
    // MARK: - Properties
    let notifications: BehaviorRelay<[NotificationDomainModel]> = .init(value: [])
    let state: PublishRelay<State> = .init()
    let createNotificationTapped: PublishSubject<Void> = .init()
    let selectedNotification: PublishSubject<NotificationDomainModel> = .init()
    
    private let coreDataService: CoreDataNotificationProtocol
    private let notificationScheduler: NotificationSchedulerProtocol
    private let disposeBag: DisposeBag = .init()
    
    enum State {
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Init
    init(
        coreDataService: CoreDataNotificationProtocol = CoreDataService.shared,
        notificationScheduler: NotificationSchedulerProtocol = NotificationScheduler()
    ) {
        self.coreDataService = coreDataService
        self.notificationScheduler = notificationScheduler
        setupBinding()
    }
}

// MARK: - Public methods
extension NotificationViewModel {
    func fetchNotifications() {
        self.state.accept(.loading)
        
        coreDataService.fetchNotifications()
            .subscribe(with: self) { viewModel, notifications in
                viewModel.notifications.accept(notifications)
                viewModel.state.accept(.loaded)
            } onError: { viewModel, error in
                viewModel.state.accept(.error(error.localizedDescription))
            }
            .disposed(by: disposeBag)
    }
    
    func getNotification(at indexPath: IndexPath) -> NotificationDomainModel? {
        let currentNotification: [NotificationDomainModel] = notifications.value
        guard indexPath.row < currentNotification.count else { return nil }
        
        return currentNotification[indexPath.row]
    }
    
    func updateNotificationIsActive(id: UUID, isActive: Bool) {
        coreDataService.updateNotification(id: id, newTitle: nil, newNotes: nil, newDate: nil, newIsActive: isActive, newReminderType: nil)
            .subscribe(with: self, onSuccess: { viewModel, updateModel in
                guard let updateModel else { return }
                
                var currentNotification: [NotificationDomainModel] = viewModel.notifications.value
                if let index = currentNotification.firstIndex(where: { $0.id == id }) {
                    currentNotification[index] = updateModel
                    viewModel.notifications.accept(currentNotification)
                }
                
                viewModel.notificationScheduler.updateNotification(
                    id: id,
                    title: updateModel.title,
                    body: updateModel.notes,
                    date: updateModel.date,
                    reminderType: updateModel.reminderType,
                    isActive: isActive
                )
            }, onFailure: { viewModel, error in
                viewModel.state.accept(.error(error.localizedDescription))
            })
            .disposed(by: disposeBag)
    }
    
    func deleteNotification(at indexPath: IndexPath) {
        var currentNotifications = notifications.value
        guard indexPath.row < currentNotifications.count else { return }
        
        let idToDelete: UUID = currentNotifications[indexPath.row].id
        currentNotifications.remove(at: indexPath.row)
        notifications.accept(currentNotifications)
        
        coreDataService.deleteNotification(id: idToDelete)
            .subscribe(with: self, onError: { viewModel, error in
                viewModel.state.accept(.error(error.localizedDescription))
            })
            .disposed(by: disposeBag)
        
        notificationScheduler.removeNotification(id: idToDelete)
    }
}

// MARK: - Private methods
private extension NotificationViewModel {
    func setupBinding() {
        createNotificationTapped
            .subscribe(with: self, onNext: { viewModel, _ in
                viewModel.navigateToCreateNotification()
            })
            .disposed(by: disposeBag)
        
        selectedNotification
            .subscribe(with: self, onNext: { viewModel, model in
                viewModel.navigateToEditNotification(model: model)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigate
    func navigateToCreateNotification() {
        let createView: CreateNotificationViewController = .init()
        AppRouter.shared.push(createView, animated: true)
    }
    
    func navigateToEditNotification(model: NotificationDomainModel) {
        let editView:CreateNotificationViewController = .init(mode: .edit(model))
        AppRouter.shared.push(editView, animated: true)
    }
}
