//
//  OnboardingViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.10.2025.
//

import RxSwift
import RxCocoa

protocol OnboardingViewModelProtocol {
    var input: OnboardingViewModel.Input { get }
    var output: OnboardingViewModel.Output { get }
}

final class OnboardingViewModel: OnboardingViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    
    // MARK: - Init
    init(pages: [UIViewController]) {
        self.input = .init()
        self.output = .init(pages: pages)
        setupBindings()
    }
}

// MARK: - Private methods
private extension OnboardingViewModel {
    func setupBindings() {
        input.currentPageIndex
            .subscribe(onNext: { [weak self] currentIndex in
                self?.updateNavigationState(for: currentIndex)
            })
            .disposed(by: disposeBag)
    }
    
    func updateNavigationState(for index: Int) {
        let totalPages: Int = output.pages.count
        
        output.canGoBack.accept(index > 0)
        
        let isLastPage: Bool = index == totalPages - 1
        output.canGoForward.accept(isLastPage)
    }
}

// MARK: - Input, Output
extension OnboardingViewModel {
    struct Input {
        let currentPageIndex: BehaviorRelay<Int> = .init(value: 0)
        let didFinishOnboarding: PublishSubject<Void> = .init()
    }
    
    struct Output {
        let pages: [UIViewController]
        let canGoBack: BehaviorRelay<Bool> = .init(value: false)
        let canGoForward: BehaviorRelay<Bool> = .init(value: true)
    }
}
