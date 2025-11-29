//
//  BaseViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa
import SwiftUI

class BaseViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var activityIndicatorBackground: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(Constants.Layout.activityBackgroundAlpha)
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        view.isHidden = true
        
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView = .init(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .appForegroundSecondary
        activityIndicator.stopAnimating()
        
        return activityIndicator
    }()
    
    private lazy var toastLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .appCardFieldSecondary
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .medium)
        label.layer.cornerRadius = Constants.Layout.cornerRadius
        label.clipsToBounds = true
        label.alpha = .zero
        return label
    }()
    
    // MARK: - Properties
    let disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setConstraints()
    }
}

// MARK: - Methods
private extension BaseViewController {
    func setupUI() {
        view.backgroundColor = .appBackground
        [activityIndicatorBackground, toastLabel].forEach { view.addSubview($0) }
        activityIndicatorBackground.addSubview(activityIndicator)
        toastLabel.bringSubviewToFront(view)
    }
    
    func setupNavigationBar() {
        let apearance: UINavigationBarAppearance = .init()
        apearance.backgroundColor = .appBackground
        apearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        let buttonApearance: UIBarButtonItemAppearance = .init()
        buttonApearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        buttonApearance.normal.backgroundImage = nil
        
        apearance.buttonAppearance = buttonApearance
        
        navigationController?.navigationBar.standardAppearance = apearance
        navigationController?.navigationBar.scrollEdgeAppearance = apearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            activityIndicatorBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorBackground.widthAnchor.constraint(equalToConstant: Constants.Layout.activityBackgroundSize),
            activityIndicatorBackground.heightAnchor.constraint(equalToConstant: Constants.Layout.activityBackgroundSize),
            
            activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorBackground.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorBackground.centerYAnchor),
            
            toastLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.Layout.defaultPadding),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.Layout.defaultPadding),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Layout.toastLabelHeight)
        ])
    }
}

// MARK: - Public ui setting methods
extension BaseViewController {
    enum BarButtonPosition {
        case left
        case right
    }
    
    func setupBarButtonItem(at position: BarButtonPosition = .left, image: UIImage?, tintColor: UIColor = .white) -> ControlEvent<Void> {
        let button: UIBarButtonItem = .init()
        button.image = image
        button.tintColor = tintColor
        
        switch position {
        case .left:
            navigationItem.leftBarButtonItem = button
        case .right:
            navigationItem.rightBarButtonItem = button
        }
        
        let tapControlEvent: ControlEvent<Void> = button.rx.tap
        
        return tapControlEvent
    }
}

// MARK: - Show Display methods
extension BaseViewController {
    func showActivityIndicator(_ isActive: Bool = true) {
        view.bringSubviewToFront(activityIndicatorBackground)
        view.isUserInteractionEnabled = !isActive
        
        UIView.animate(withDuration: Constants.Animation.animationDuration) { [weak self] in
            self?.activityIndicatorBackground.alpha = isActive ? 1 : 0
            self?.activityIndicatorBackground.isHidden = !isActive
        }
        
        isActive ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func showErrorAlert(
        title: String? = L10n.Error.title,
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let alert: UIAlertController = .init(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        let action: UIAlertAction = .init(title: L10n.Common.ok, style: .default) { _ in
            handler?()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showDatePicker() -> Observable<(Date, Date)> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            let datePicker: CalendarDatePicker = .init { start, end in
                observer.on(.next((start, end)))
            }
            
            let hostingVC: UIHostingController<CalendarDatePicker> = .init(rootView: datePicker)
            
            let alert: UIAlertController = .init()
            alert.modalPresentationStyle = .formSheet
            alert.setValue(hostingVC, forKey: "contentViewController")
            
            self.present(alert, animated: true)
            
            return Disposables.create()
        }
    }
    
    func showSelectionSheet<T: CaseIterable & RawRepresentable>(
        title: String? = nil,
        localizedTitleProvider: @escaping (T) -> String
    ) -> Observable<T?> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            let sheet: UIAlertController = .init(title: title, message: nil, preferredStyle: .actionSheet)
            sheet.overrideUserInterfaceStyle = .dark
            
            T.allCases.forEach { type in
                let action: UIAlertAction = .init(title: localizedTitleProvider(type), style: .default) { _ in
                    observer.on(.next(type))
                    observer.on(.completed)
                }
                sheet.addAction(action)
            }
            
            let cancelAction: UIAlertAction = .init(title: L10n.Common.cancel, style: .cancel) { _ in
                observer.on(.next(nil))
                observer.on(.completed)
            }
            
            sheet.addAction(cancelAction)
            self.present(sheet, animated: true)
            
            return Disposables.create {
                sheet.dismiss(animated: true)
            }
        }
    }
    
    func showConfirmationAlert(
        title: String,
        message: String,
        confirmButtonTitle: String = L10n.Common.continue,
        confirmButtonStyle: UIAlertAction.Style = .destructive,
        confirmAction: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.overrideUserInterfaceStyle = .dark
        
        let cancelAction = UIAlertAction(
            title: L10n.Common.cancel,
            style: .cancel
        )
        
        let confirmAction = UIAlertAction(
            title: confirmButtonTitle,
            style: confirmButtonStyle
        ) { _ in
            confirmAction()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
    
    func showToast(message: String) {
        toastLabel.text = message
        showToastAnimation()
    }
    
    private func showToastAnimation() {
        UIView.animate(withDuration: Constants.Animation.showAnimationDuration, delay: .zero, options: .curveEaseInOut) {
            self.toastLabel.alpha = 1
        } completion: { _ in self.hideToastAnimation() }
    }

    private func hideToastAnimation() {
        UIView.animate(withDuration: Constants.Animation.animationDuration, delay: .zero, options: .curveEaseInOut) {
            self.toastLabel.alpha = 0
        } completion: { _ in self.toastLabel.text = nil }
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let activityBackgroundAlpha: CGFloat = 0.2
        static let activityBackgroundSize: CGFloat = 64
        static let cornerRadius: CGFloat = 12
        static let defaultPadding: CGFloat = 16
        static let toastLabelHeight: CGFloat = 52
    }
    
    enum Animation {
        static let animationDuration: TimeInterval = 0.3
        static let showAnimationDuration: TimeInterval = 1.0
    }
    
    enum Text {
        static let fontSize: CGFloat = 16
    }
}
