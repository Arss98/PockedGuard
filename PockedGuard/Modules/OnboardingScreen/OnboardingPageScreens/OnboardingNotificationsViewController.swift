//
//  OnboardingNotificationsViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 09.10.2025.
//

import UIKit

final class OnboardingNotificationsViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var backgroundView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "backgroundOnboardingNotification")
        return imageView
    }()
    
    private lazy var templateImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "notificationOnboarding")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .medium)
        label.text = .Localized.Notification.title.localized
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: Constants.Text.descriptionFontSize, weight: .regular)
        label.text = .Localized.Onboarding.templatesDescription.localized
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
    }
}

// MARK: - UI Setup methods
private extension OnboardingNotificationsViewController {
    func setupUI() {
        view.backgroundColor = .appBackground
        [backgroundView, templateImageView, titleLabel, descriptionLabel].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            templateImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                   constant: Constants.Layout.padding * 4),
            templateImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            templateImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor,
                                               constant: -Constants.Layout.padding * 2),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -Constants.Layout.bottomPadding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Text {
        static let titleFontSize: CGFloat = 22
        static let descriptionFontSize: CGFloat = 18
    }
    
    enum Layout {
        static let padding: CGFloat = 16
        static let bottomPadding: CGFloat = 116
    }
}
