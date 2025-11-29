//
//  PinCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import RxSwift

final class PinCoordinator: Coordinator {
    // MARK: - Public properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController?
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let onPinSetupCompleted: () -> Void
    private let onDismissRequested: () -> Void
    private let biometricSuccessDelay: RxTimeInterval = .milliseconds(800)
    private let mode: Mode
    
    enum Mode {
        case createNew
        case authenticate
        case change
    }
    
    // MARK: - Init
    init(
        mode: Mode,
        onPinSetupCompleted: @escaping () -> Void,
        onDismissRequested: @escaping () -> Void = {}
    ) {
        self.mode = mode
        self.onPinSetupCompleted = onPinSetupCompleted
        self.onDismissRequested = onDismissRequested
        self.navigationController = UINavigationController()
        
        setupNavigationBarAppearance()
    }
    
    func start() {
        showPinScreen()
    }
}

// MARK: - Private methods
private extension PinCoordinator {
    func setupNavigationBarAppearance() {
        if mode == .change {
            navigationController?.modalPresentationStyle = .pageSheet
            if let sheet = navigationController?.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
    }
    
    func showPinScreen() {
        let initialState: PinViewModel.PinState
        
        switch mode {
        case .createNew:
            initialState = .create
        case .authenticate:
            initialState = .enter
        case .change:
            initialState = .changeCurrent
        }
        
        let viewModel: PinViewModelProtocol = PinViewModel(initialState: initialState)
        let viewController: PinViewController = .init(viewModel: viewModel)
        
        bindViewModelEvents(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func bindViewModelEvents(viewModel: PinViewModelProtocol) {
        viewModel.output.navigateToMain
            .subscribe(onNext: { [weak self] in
                self?.onPinSetupCompleted()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.biometricsNavigateToMain
            .delay(biometricSuccessDelay, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.onPinSetupCompleted()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.dismiss
            .subscribe(onNext: { [weak self] in
                self?.onDismissRequested()
            })
            .disposed(by: disposeBag)
    }
}

//// SettingsCoordinator.swift
//extension SettingsCoordinator {
//    func showChangePin() {
//        let pinCoordinator = PinCoordinator(
//            mode: .change,
//            onPinSetupCompleted: { [weak self] in
//                // Пин-код успешно изменен - закрываем модально
//                self?.navigationController?.dismiss(animated: true)
//                self?.pinChangeCompleted()
//            },
//            onDismissRequested: { [weak self] in
//                // Пользователь отменил изменение - закрываем модально
//                self?.navigationController?.dismiss(animated: true)
//                self?.pinChangeCancelled()
//            }
//        )
//        
//        addChildCoordinator(pinCoordinator)
//        pinCoordinator.start()
//        
//        // Представляем модально (уже настроено в PinCoordinator как .pageSheet)
//        if let pinNavigationController = pinCoordinator.navigationController {
//            navigationController?.present(pinNavigationController, animated: true)
//        }
//    }
//    
//    private func pinChangeCompleted() {
//        // Уведомляем пользователя об успешном изменении пин-кода
//        showSuccessAlert(message: "Пин-код успешно изменен")
//        removePinCoordinator()
//    }
//    
//    private func pinChangeCancelled() {
//        // Просто удаляем координатор
//        removePinCoordinator()
//    }
//    
//    private func removePinCoordinator() {
//        if let pinCoordinator = childCoordinators.first(where: { $0 is PinCoordinator }) {
//            removeChildCoordinator(pinCoordinator)
//        }
//    }
//    
//    private func showSuccessAlert(message: String) {
//        let alert = UIAlertController(
//            title: "Успешно",
//            message: message,
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        navigationController?.present(alert, animated: true)
//    }
//}
