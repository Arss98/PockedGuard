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
    func addCustomColor(_ hexColor: String)
}

final class CreateCategoryViewModel: CreateCategoryViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    let mode: Mode
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let dataProvider: DataProviderProtocol
    private let colorStorageService: ColorStorageServiceProtocol
    
    enum Mode {
        case add
        case edit(CategoryDomainModel)
    }
    
    init(mode: Mode = .add,
         initialTransactionType: TransactionType = .expense,
         dataProvider: DataProviderProtocol,
         colorStorageService: ColorStorageServiceProtocol) {
        self.mode = mode
        self.dataProvider = dataProvider
        self.colorStorageService = colorStorageService
        self.input = .init(transactionType: .init(value: initialTransactionType))
        self.output = .init()
        setInitialValues()
        setupBinding()
    }
}

// MARK: - Public methods
extension CreateCategoryViewModel {
    func addCustomColor(_ hexColor: String) {
        colorStorageService.addColor(hexColor)
        
        let updatedColors: [String] = colorStorageService.getColors()
        let colorItemTypes: [ColorItemType] = updatedColors.map { .color($0) } + [.add]
        output.colors.accept(colorItemTypes)
        
        input.selectedColor.accept(hexColor)
    }
}

// MARK: - Private methods
private extension CreateCategoryViewModel {
    func setupBinding() {
        input.saveAction
            .subscribe(onNext: { [weak self] in
                self?.saveCategory()
            })
            .disposed(by: disposeBag)
    }
    
    func setInitialValues() {
        if case .edit(let category) = mode {
            input.categoryName.accept(category.name)
            input.selectedColor.accept(category.color)
            colorStorageService.addColor(category.color)
        }
        
        let colors: [String] = colorStorageService.getColors()
        let colorItemTypes: [ColorItemType] = colors.map { .color($0) } + [.add]
        output.colors.accept(colorItemTypes)
    }
    
    func validateInputData() throws {
        guard !input.categoryName.value.isEmpty else { throw CustomError.emptyCategoryName }
        guard input.selectedColor.value != nil else { throw CustomError.emptySelectedColor }
        
        if let duplicateError = checkDuplicateCategoryName() { throw duplicateError }
    }
    
    func saveCategory () {
        output.isLoading.accept(true)
        
        do {
            try validateInputData()
            let operation: Completable = {
                switch mode {
                case .add: createCategory()
                case .edit(let category): editCategory(category)
                }
            }()
            
            operation.subscribe { [weak self] in
                self?.output.dismiss.onNext(())
                self?.output.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.output.error.onNext(error)
                self?.output.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
        } catch {
            output.error.onNext(error)
            output.isLoading.accept(false)
        }
    }
    
    func createCategory() -> Completable {
        let category: CategoryDomainModel = .init(
            id: UUID(),
            name: input.categoryName.value,
            color: input.selectedColor.value ?? "",
            isSystem: false,
            type: input.transactionType.value
        )
        
        return dataProvider.categories.createCategory(category)
    }
    
    func editCategory(_ category: CategoryDomainModel) -> Completable {
        dataProvider.categories.updateCategory(
            id: category.id,
            newName: input.categoryName.value,
            newColor: input.selectedColor.value,
            newType: input.transactionType.value
        )
        .asCompletable()
    }
    
    func checkDuplicateCategoryName() -> CustomError? {
        let currentName: String = input.categoryName.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentName.isEmpty else { return nil }
        
        let categories: [CategoryDomainModel] = dataProvider.categories.getCategories(type: input.transactionType.value)
        
        let dublicateCategory: CategoryDomainModel? = categories.first { category in
            let existingName: String = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if existingName.caseInsensitiveCompare(currentName) == .orderedSame {
                if case .edit(let currentCategory) = mode {
                    return category.id != currentCategory.id
                }
                return true
            }
            return false
        }
        
        return dublicateCategory != nil ? .duplicateCategoryName : nil
    }
}

// MARK: - Input, Output
extension CreateCategoryViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
        let categoryName: BehaviorRelay<String> = .init(value: "")
        let transactionType: BehaviorRelay<TransactionType>
        let selectedColor: BehaviorRelay<String?> = .init(value: nil)
    }
    
    struct Output {
        let dismiss: PublishSubject<Void> = .init()
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
        let colors: BehaviorRelay<[ColorItemType]> = .init(value: [])
    }
}

// MARK: - Errors
private enum CustomError: Error, LocalizedError {
    case emptyCategoryName
    case emptySelectedColor
    case duplicateCategoryName
    
    var errorDescription: String? {
        switch self {
        case .emptyCategoryName:
            return .Localized.Error.invalidNameCategory.localized
        case .emptySelectedColor:
            return .Localized.Error.emptyCategoryColor.localized
        case .duplicateCategoryName:
            return .Localized.Error.duplicateCategoryName.localized
        }
    }
}
