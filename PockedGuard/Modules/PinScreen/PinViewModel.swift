//
//  PinViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import RxSwift
import RxCocoa

protocol PinViewModelProtocol {
    var input: PinViewModel.Input { get }
    var output: PinViewModel.Output { get }
    var state: BehaviorRelay<PinViewModel.PinState> { get }
    func triggerBiometricIfNeeded()
}

final class PinViewModel: PinViewModelProtocol {
    // MARK: - Public properties
    let input: Input = .init()
    let output: Output = .init()
    let state: BehaviorRelay<PinState>
    
    // MARK: - Dependencies
    private let keychainService: KeychainServiceProtocol
    private let biometricService: BiometricAuthenticationServiceProtocol
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Private properties
    private var currentPin: String = ""
    private let pinLength: Int = 4
    
    // MARK: - Init
    init(
        initialState: PinState = .create,
        keychainService: KeychainServiceProtocol = KeychainService.shared,
        biometricService: BiometricAuthenticationServiceProtocol = BiometricAuthenticationService()
    ) {
        self.state = BehaviorRelay(value: initialState)
        self.keychainService = keychainService
        self.biometricService = biometricService
        
        setupBindings()
    }
    
    // MARK: - Public API
    func triggerBiometricIfNeeded() {
        guard state.value.withoutError == .enter else { return }
        requestBiometrics()
    }
}

// MARK: - PinState
extension PinViewModel {
    enum PinState: Equatable {
        case create
        case confirm(firstPin: String)
        case enter
        case changeCurrent
        case changeNew
        case changeConfirm(newPin: String)
        indirect case error(PinError, from: PinState)
        
        var backDestination: PinState? {
            switch self {
            case .confirm:
                return .create
            case .changeConfirm:
                return .changeNew
            case .changeNew:
                return .changeCurrent
                
            case let .error(_, from):
                if case .confirm = from { return .create }
                if case .changeConfirm = from { return .changeNew }
                return from.backDestination
                
            default:
                return nil
            }
        }
        
        var withoutError: PinState {
            if case .error(_, let from) = self { return from }
            return self
        }
    }
}

// MARK: - Bindings
private extension PinViewModel {
    func setupBindings() {
        input.digitEntered
            .subscribe(onNext: { [weak self] in self?.handleDigit($0) })
            .disposed(by: disposeBag)
        
        input.deleteTapped
            .subscribe(onNext: { [weak self] in self?.handleDelete() })
            .disposed(by: disposeBag)
        
        input.biometricsTapped
            .subscribe(onNext: { [weak self] in self?.handleBiometrics() })
            .disposed(by: disposeBag)
        
        input.backTapped
            .subscribe(onNext: { [weak self] in self?.handleBack() })
            .disposed(by: disposeBag)
        
        state
            .subscribe(onNext: { [weak self] in self?.updateTitle(for: $0) })
            .disposed(by: disposeBag)
        
        state
            .map { $0.backDestination != nil }
            .distinctUntilChanged()
            .bind(to: output.visibleBackButton)
            .disposed(by: disposeBag)
    }
}

// MARK: - Input Handling
private extension PinViewModel {
    func handleDigit(_ digit: String) {
        if case .error = state.value {
            state.accept(state.value.withoutError)
            resetCurrentPin()
        }
        
        guard currentPin.count < pinLength else { return }
        currentPin += digit
        output.pinLength.accept(currentPin.count)
        
        if currentPin.count == pinLength {
            processPin()
        }
    }
    
    func handleDelete() {
        guard !currentPin.isEmpty else { return }
        currentPin.removeLast()
        output.pinLength.accept(currentPin.count)
    }
    
    func handleBiometrics() {
        requestBiometrics()
    }
    
    func handleBack() {
        if let destination = state.value.backDestination {
            state.accept(destination)
            resetCurrentPin()
        } else {
            output.dismiss.onNext(())
        }
    }
}

// MARK: - Pin Processing
private extension PinViewModel {
    func processPin() {
        let currentState = state.value.withoutError
        
        switch currentState {
        case .create:
            transition(to: .confirm(firstPin: currentPin))
            
        case .confirm(let firstPin):
            if currentPin == firstPin {
                if keychainService.saveUserPin(currentPin) {
                    requestBiometrics()
                } else {
                    transition(to: .error(.saveError, from: currentState))
                }
            } else {
                transition(to: .error(.pinMismatch, from: currentState))
            }
            
        case .enter:
            if keychainService.verifyUserPin(currentPin) {
                Haptics.success()
                output.navigateToMain.onNext(())
            } else {
                transition(to: .error(.incorrectPin, from: currentState))
            }
            
        case .changeCurrent:
            if keychainService.verifyUserPin(currentPin) {
                transition(to: .changeNew)
            } else {
                transition(to: .error(.incorrectPin, from: currentState))
            }
            
        case .changeNew:
            transition(to: .changeConfirm(newPin: currentPin))
            
        case .changeConfirm(let newPin):
            if currentPin == newPin {
                if keychainService.saveUserPin(currentPin) {
                    output.dismiss.onNext(())
                } else {
                    transition(to: .error(.saveError, from: currentState))
                }
            } else {
                transition(to: .error(.pinMismatch, from: currentState))
            }
            
        default:
            break
        }
    }
    
    func transition(to newState: PinState) {
        state.accept(newState)
        resetCurrentPin()
    }
}

// MARK: - UI Updates
private extension PinViewModel {
    func updateTitle(for state: PinState) {
        let cleanState = state.withoutError
        
        switch cleanState {
        case .create:
            output.titleText.accept(L10n.Pin.createRequired)
        case .confirm, .changeConfirm:
            output.titleText.accept(L10n.Pin.confirmPlaceholder)
        case .changeNew:
            output.titleText.accept(L10n.Pin.changeNew)
        case .changeCurrent:
            output.titleText.accept(L10n.Pin.confirmCurrentPlaceholder)
        case .enter:
            output.titleText.accept(L10n.Pin.enterPlaceholder)
        default:
            break
        }
    }
    
    func requestBiometrics() {
        biometricService.isBiometricAvailable { [weak self] available in
            guard available else { return }
            self?.biometricService.authenticateWithCompletion { success, error in
                guard success, error == nil else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.output.biometricsNavigateToMain.onNext(())
                }
            }
        }
    }
    
    func resetCurrentPin() {
        currentPin = ""
        output.pinLength.accept(0)
    }
}

// MARK: - Input / Output
extension PinViewModel {
    struct Input {
        let digitEntered: PublishSubject<String> = .init()
        let deleteTapped: PublishSubject<Void> = .init()
        let biometricsTapped: PublishSubject<Void> = .init()
        let backTapped: PublishSubject<Void> = .init()
    }
    
    struct Output {
        let pinLength: BehaviorRelay<Int> = .init(value: 0)
        let dismiss: PublishSubject<Void> = .init()
        let navigateToMain: PublishSubject<Void> = .init()
        let biometricsNavigateToMain: PublishSubject<Void> = .init()
        let titleText: BehaviorRelay<String> = .init(value: "")
        let visibleBackButton: BehaviorRelay<Bool> = .init(value: false)
    }
}

// MARK: - Errors
enum PinError: LocalizedError, Equatable {
    case pinMismatch, incorrectPin, saveError
    
    var errorDescription: String? {
        switch self {
        case .pinMismatch:
            return L10n.Pin.mismatch
        case .incorrectPin:
            return L10n.Pin.incorrect
        case .saveError:
            return L10n.Pin.saveError
        }
    }
}
