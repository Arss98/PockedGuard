//
//  OnboardingWelcomeViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 09.10.2025.
//

import UIKit

final class OnboardingWelcomeViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var backgroundView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "backgroundOnboardingWelcome")
        return imageView
    }()
    
    private lazy var nameImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "pockedGuard")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var logoImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "onboardingWelcome")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .medium)
        label.text = L10n.Onboarding.Welcome.title
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: Constants.Text.descriptionFontSize, weight: .regular)
        label.text = L10n.Onboarding.Welcome.description
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
private extension OnboardingWelcomeViewController {
    func setupUI() {
        view.backgroundColor = .appBackground
        [backgroundView, nameImageView, logoImageView, titleLabel, descriptionLabel].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            nameImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: Constants.Layout.padding),
            nameImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            logoImageView.topAnchor.constraint(equalTo: nameImageView.bottomAnchor,
                                               constant: Constants.Layout.padding),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.Layout.smallPadding),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -Constants.Layout.smallPadding),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor,
                                                  constant: -Constants.Layout.smallPadding),
            
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
        static let padding: CGFloat = 52
        static let smallPadding: CGFloat = 32
        static let bottomPadding: CGFloat = 116
    }
}
