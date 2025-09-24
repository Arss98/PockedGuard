//
//  CreateCategoryViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 24.09.2025.
//

import RxSwift
import RxCocoa

protocol CreateCategoryViewModelProtocol {
    var input: CreateCategoryViewModel.Input { get }
    var output: CreateCategoryViewModel.Output { get }
    var mode: CreateCategoryViewModel.Mode { get }
}

final class CreateCategoryViewModel: CreateCategoryViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    let mode: Mode
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let dataProvider: DataProviderProtocol
    
    enum Mode {
        case add
        case edit(CategoryDomainModel)
    }
    
    init(mode: Mode = .add, dataProvider: DataProviderProtocol) {
        self.mode = mode
        self.dataProvider = dataProvider
        self.input = .init()
        self.output = .init()
        setInitialValues()
    }
}

// MARK: - Private methods
private extension CreateCategoryViewModel {
    func setInitialValues() {
        
    }
}

// MARK: - Input, Output
extension CreateCategoryViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
    }
    
    struct Output {
        let dismiss: PublishSubject<Void> = .init()
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
    }
}
