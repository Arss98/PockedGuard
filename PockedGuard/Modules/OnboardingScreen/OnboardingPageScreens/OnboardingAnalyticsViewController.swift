//
//  OnboardingAnalyticsViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 09.10.2025.
//

import UIKit

final class OnboardingAnalyticsViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var backgroundView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "backgroundOnboardingAnalytics")
        return imageView
    }()
    
    private lazy var diagramImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "diagramOnboardingAnalytics")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var chartImageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "chartOnboardingAnalytics")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .medium)
        label.text = .Localized.Common.analytics.localized
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: Constants.Text.descriptionFontSize, weight: .regular)
        label.text = .Localized.Onboarding.analyticsDescription.localized
        return label
    }()
    
    // MARK: - LIfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
    }
}

// MARK: - UI Setup methods
private extension OnboardingAnalyticsViewController {
    func setupUI() {
        view.backgroundColor = .appBackground
        [backgroundView, chartImageView, diagramImageView, titleLabel, descriptionLabel].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            diagramImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: Constants.Layout.padding * 2),
            diagramImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            diagramImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            chartImageView.topAnchor.constraint(equalTo: diagramImageView.centerYAnchor,
                                                constant: Constants.Layout.padding),
            chartImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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
