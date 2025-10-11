//
//  OnboardingPageViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.10.2025.
//

import RxSwift
import RxCocoa

final class OnboardingPageViewController: UIPageViewController {
    // MARK: - UI Elements
    private lazy var pageDotStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.stackSpacing
        stackView.backgroundColor = .appMaterialsUltrathinDark
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.layoutMargins = Constants.stackInset
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var nextPageButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .white
        button.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        return button
    }()
    
    private lazy var previousPageButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.widthAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        button.heightAnchor.constraint(equalToConstant: Constants.buttonSize).isActive = true
        return button
    }()
    
    private lazy var pageControlStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [previousPageButton, pageDotStackView, nextPageButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Private properties
    private let viewModel: OnboardingViewModelProtocol
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    init(viewModel: OnboardingViewModelProtocol) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageController()
        setupPageControl()
        setupBindings()
    }
}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed,
           let currentViewController: UIViewController = pageViewController.viewControllers?.first,
           let currentIndex: Int = viewModel.output.pages.firstIndex(of: currentViewController) {
            viewModel.input.currentPageIndex.accept(currentIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewModel.output.pages.firstIndex(of: viewController),
              currentIndex > 0 else { return nil }
        return viewModel.output.pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewModel.output.pages.firstIndex(of: viewController),
              currentIndex < viewModel.output.pages.count - 1 else { return nil }
        return viewModel.output.pages[currentIndex + 1]
    }
}

// MARK: - Private methods
private extension OnboardingPageViewController {
    func setupBindings() {
        bindViewModel()
        bindButtons()
    }
    
    func bindViewModel() {
        viewModel.input.currentPageIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] currentIndex in
                self?.updatePageControl(for: currentIndex)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.canGoBack
            .bind(to: previousPageButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.canGoBack
            .map { $0 ? 1.0 : 0.5 }
            .bind(to: previousPageButton.rx.alpha)
            .disposed(by: disposeBag)
        
        viewModel.output.canGoForward
            .subscribe(onNext: { [weak self] isLastPage in
                let imageName: String = isLastPage ? "xmark" : "chevron.right"
                UIView.animate(withDuration: Constants.animatedDuration) {
                    self?.nextPageButton.setImage(UIImage(systemName: imageName), for: .normal)
                    self?.nextPageButton.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindButtons() {
        previousPageButton.rx.tap
            .withLatestFrom(viewModel.input.currentPageIndex)
            .subscribe(onNext: { [weak self] currentIndex in
                guard let self else { return }
                let previousIndex: Int = currentIndex - 1
                if previousIndex >= 0 {
                    let direction: UIPageViewController.NavigationDirection = .reverse
                    self.setViewControllers([self.viewModel.output.pages[previousIndex]],
                                            direction: direction, animated: true)
                    self.viewModel.input.currentPageIndex.accept(previousIndex)
                    
                }
            })
            .disposed(by: disposeBag)
        
        nextPageButton.rx.tap
            .withLatestFrom(viewModel.input.currentPageIndex)
            .subscribe(onNext: { [weak self] currentIndex in
                guard let self else { return }
                let nextIndex: Int = currentIndex + 1
                if nextIndex < self.viewModel.output.pages.count {
                    let direction: UIPageViewController.NavigationDirection = .forward
                    self.setViewControllers([self.viewModel.output.pages[nextIndex]], direction: direction, animated: true)
                    self.viewModel.input.currentPageIndex.accept(nextIndex)
                } else {
                    self.viewModel.input.didFinishOnboarding.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupPageController() {
        dataSource = self
        delegate = self
        
        if let firstViewController = viewModel.output.pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true)
        }
    }
}

// MARK: - UI Setup methods
private extension OnboardingPageViewController {
    func setupUI() {
        view.backgroundColor = .appBackground
        view.addSubview(pageControlStackView)
        
        NSLayoutConstraint.activate([
            pageControlStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            pageControlStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            pageControlStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -Constants.padding),
        ])
    }
    
    func setupPageControl() {
        for (index, _) in viewModel.output.pages.enumerated() {
            let dotView: UIView = .init()
            dotView.backgroundColor = index == 0 ? .white : .gray
            dotView.layer.cornerRadius = Constants.dotCornerRadius
            dotView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dotView.widthAnchor.constraint(equalToConstant: Constants.dotSize),
                dotView.heightAnchor.constraint(equalToConstant: Constants.dotSize)
            ])
            
            pageDotStackView.addArrangedSubview(dotView)
        }
    }
    
    func updatePageControl(for currentIndex: Int) {
        for (index, dotView) in pageDotStackView.arrangedSubviews.enumerated() {
            dotView.backgroundColor = index == currentIndex ? .white : .gray
        }
    }
}

// MARK: - Constants
private enum Constants {
    static let dotSize: CGFloat = 8
    static let dotCornerRadius: CGFloat = 4
    static let padding: CGFloat = 16
    static let stackSpacing: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    static let stackInset: UIEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
    static let buttonSize: CGFloat = 44
    static let animatedDuration: TimeInterval = 0.2
}
