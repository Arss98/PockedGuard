//
//  PinViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 21.11.2025.
//

import SwiftUI
import RxSwift
import RxCocoa

final class PinViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var dotsView: DotsView = .init()
    private lazy var pinKeyboardView: PinKeyboardView = .init()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .regular)
        label.numberOfLines = Constants.Text.titleNumberOfLines
        label.textAlignment = .center
        return label
    }()
    
    private lazy var errorLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appErrorRed
        label.font = .systemFont(ofSize: Constants.Text.errorFontSize, weight: .regular)
        label.textAlignment = .center
        label.alpha = .zero
        return label
    }()
    
    private lazy var keyboardHosting: UIHostingController<PinKeyboardView> = {
        let hosting: UIHostingController<PinKeyboardView> = .init(rootView: self.pinKeyboardView)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        return hosting
    }()
    
    private lazy var backButton: UIBarButtonItem = {
        let button: UIBarButtonItem = .init()
        button.style = .plain
        button.image = UIImage(systemName: "chevron.left")
        
        button.rx.tap
            .bind(to: viewModel.input.backTapped)
            .disposed(by: disposeBag)
        
        return button
    }()
    
    // MARK: - Private properties
    private let viewModel: PinViewModelProtocol
    
    // MARK: - Init
    init(viewModel: PinViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.triggerBiometricIfNeeded()
    }
}

// MARK: - Private methods
private extension PinViewController {
    func setupBindings() {
        setupInputBiniding()
        setupOutputBinding()
    }
    
    func setupInputBiniding() {
        pinKeyboardView.digitSubject
            .bind(to: viewModel.input.digitEntered)
            .disposed(by: disposeBag)
        
        pinKeyboardView.deleteSubject
            .bind(to: viewModel.input.deleteTapped)
            .disposed(by: disposeBag)
        
        pinKeyboardView.biometricSubject
            .bind(to: viewModel.input.biometricsTapped)
            .disposed(by: disposeBag)
    }
    
    func setupOutputBinding() {
        viewModel.state
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .error(let error, _):
                    self?.showError(error.errorDescription)
                default:
                    self?.hideError()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.pinLength
            .subscribe { [weak self] length in
                self?.dotsView.filledCount = length
            }
            .disposed(by: disposeBag)
        
        viewModel.output.titleText
            .subscribe(onNext: { [weak self] title in
                self?.updateTitleText(title)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.visibleBackButton
            .subscribe(onNext: { [weak self] isVisible in
                self?.updateBackButtonVisibility(isVisible)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Animation methods
private extension PinViewController {
    func showError(_ error: String?) {
        guard errorLabel.text != error else { return }
        
        Haptics.error()
        
        UIView.transition(
            with: errorLabel,
            duration: Constants.Animation.defaultDuration,
            options: .transitionCrossDissolve
        ) {
            self.errorLabel.text = error
            self.errorLabel.alpha = 1
        }
        
        dotsView.isErrorState = true
        dotsView.shake()
    }
    
    func hideError() {
        UIView.animate(withDuration: Constants.Animation.defaultDuration, delay: .zero, options: .curveEaseOut, animations: {
            self.errorLabel.alpha = .zero
            self.dotsView.isErrorState = false
            self.dotsView.filledCount = self.viewModel.output.pinLength.value
        }) { _ in
            self.errorLabel.text = nil
        }
    }
    
    func updateTitleText(_ text: String) {
        guard titleLabel.text != text else { return }
        
        UIView.transition(
            with: titleLabel,
            duration: Constants.Animation.duration,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.titleLabel.text = text
        }
    }
    
    func updateBackButtonVisibility(_ isVisible: Bool) {
        guard navigationItem.leftBarButtonItem != (isVisible ? backButton : nil) else { return }
        
        UIView.animate(withDuration: Constants.Animation.defaultDuration, delay: .zero, options: .curveEaseOut) {
            self.navigationItem.leftBarButtonItem = isVisible ? self.backButton : nil
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
    }
}

// MARK: - UI Setting
private extension PinViewController {
    func setupUI() {
        addChild(keyboardHosting)
        [titleLabel, errorLabel, dotsView, keyboardHosting.view].forEach { view.addSubview($0) }
        keyboardHosting.didMove(toParent: self)
    }
    
    func setConstraints() {
        let width: CGFloat = view.bounds.width
        let keyboardHeight: CGFloat = PinKeyboardView.calculateHeight(for: width)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: Constants.Layout.titleTopPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.Layout.defaultPadding * 2),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.Layout.defaultPadding * 2),
            
            errorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                            constant: Constants.Layout.defaultPadding / 2),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: Constants.Layout.errorLabelHeight),
            
            dotsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor,
                                          constant: Constants.Layout.defaultPadding),
            
            keyboardHosting.view.topAnchor.constraint(equalTo: dotsView.bottomAnchor,
                                                      constant: Constants.Layout.verticalSpacing),
            keyboardHosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardHosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardHosting.view.heightAnchor.constraint(equalToConstant: keyboardHeight)
        ])
    }
}

#Preview {
    PinViewController(viewModel: PinViewModel())
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let titleTopPadding: CGFloat = 96
        static let defaultPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 50
        static let errorLabelHeight: CGFloat = 24
    }
    
    enum Text {
        static let titleFontSize: CGFloat = 18
        static let titleNumberOfLines: Int = 2
        static let errorFontSize: CGFloat = 14
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.4
        static let defaultDuration: TimeInterval = 0.35
    }
}
