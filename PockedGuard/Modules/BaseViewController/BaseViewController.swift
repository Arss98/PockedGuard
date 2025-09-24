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
        view.backgroundColor = .black.withAlphaComponent(Constants.activityBackgroundAlpha)
        view.layer.cornerRadius = Constants.cornerRadius
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
        [activityIndicatorBackground].forEach { view.addSubview($0) }
        activityIndicatorBackground.addSubview(activityIndicator)
    }
    
    func setupNavigationBar() {
        let apearance: UINavigationBarAppearance = .init()
        apearance.backgroundColor = .appBackground
        apearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = apearance
        navigationController?.navigationBar.scrollEdgeAppearance = apearance
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            activityIndicatorBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorBackground.widthAnchor.constraint(equalToConstant: Constants.activityBackgroundSize),
            activityIndicatorBackground.heightAnchor.constraint(equalToConstant: Constants.activityBackgroundSize),
            
            activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorBackground.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorBackground.centerYAnchor)
        ])
    }
}

// MARK: - Public ui setting methods
extension BaseViewController {
    enum BarButtonPosition {
        case left
        case right
    }
    
    func setupLeftBarButtonItem(at position: BarButtonPosition = .left, image: UIImage, tintColor: UIColor = .white) -> ControlEvent<Void> {
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
        
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.activityIndicatorBackground.alpha = isActive ? 1 : 0
            self?.activityIndicatorBackground.isHidden = !isActive
        }
        
        isActive ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    func showErrorAlert(
        title: String? = .Localized.Error.title.localized,
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let alert: UIAlertController = .init(title: title, message: message, preferredStyle: .alert)
        let action: UIAlertAction = .init(title: .Localized.Common.ok.localized, style: .default) { _ in
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
            
            let cancelAction: UIAlertAction = .init(title: .Localized.Common.cancel.localized, style: .cancel) { _ in
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
}

// MARK: - Constants
private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let activityBackgroundAlpha: CGFloat = 0.2
    static let activityBackgroundSize: CGFloat = 64
    static let cornerRadius: CGFloat = 12
}
