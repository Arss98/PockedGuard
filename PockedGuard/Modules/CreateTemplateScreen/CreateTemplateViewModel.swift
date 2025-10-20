//
//  CreateTemplateViewModel.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.09.2025.
//

import RxSwift
import RxCocoa

protocol CreateTemplateViewModelProtocol {
    var input: CreateTemplateViewModel.Input { get }
    var output: CreateTemplateViewModel.Output { get }
    var mode: CreateTemplateViewModel.Mode { get }
    func didSelectCategory(indexPath: IndexPath)
    func confirmReplacement(replacing oldTemplateId: UUID)
}

final class CreateTemplateViewModel: CreateTemplateViewModelProtocol {
    // MARK: - Public properties
    let input: Input
    let output: Output
    let mode: Mode
    
    // MARK: - Private properties
    private let disposeBag: DisposeBag = .init()
    private let cacheCategories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
    private let dataProvider: DataProviderProtocol
    
    enum Mode {
        case add
        case edit(TemplateDomainModel)
    }
    
    init(mode: Mode = .add,
         initialTransactionType: TransactionType = .expense,
         dataProvider: DataProviderProtocol) {
        self.mode = mode
        self.dataProvider = dataProvider
        self.input = .init(transactionType: .init(value: initialTransactionType))
        self.output = .init()
        setInitialValues()
        setupBindind()
        setupCategoriesBinding()
    }
}

// MARK: - Public methods
extension CreateTemplateViewModel {
    func didSelectCategory(indexPath: IndexPath) {
        let category = output.categories.value[indexPath.row]
        input.selectedCategory.accept(category)
    }
    
    func confirmReplacement(replacing oldTemplateId: UUID) {
        output.isLoading.accept(true)
        
        do {
            try validateValues()
            
            let newTemplate = TemplateDomainModel(
                id: UUID(),
                icon: input.selectedIcon.value,
                amount: Double(input.amount.value),
                type: input.transactionType.value,
                category: input.selectedCategory.value
            )
            
            dataProvider.template.deleteTemplate(with: oldTemplateId)
                .andThen(dataProvider.template.createTemplate(newTemplate))
                .subscribe(onCompleted: { [weak self] in
                    self?.output.dismiss.onNext(())
                    self?.output.isLoading.accept(false)
                }, onError: { [weak self] error in
                    self?.output.error.onNext(error)
                    self?.output.isLoading.accept(false)
                })
                .disposed(by: disposeBag)
        } catch {
            output.error.onNext(error)
            output.isLoading.accept(false)
        }
    }
}

// MARK: - Setup Binding and initial value
private extension CreateTemplateViewModel {
    func setInitialValues() {
        let nameIcon: [String] = {
            (1...10).map { "icon\($0)" }
        }()
        output.icons.accept(nameIcon)
        
        if case .edit(let template) = mode {
            input.selectedCategory.accept(template.category)
            input.selectedIcon.accept(template.icon)
        }
    }
    
    func setupBindind() {
        dataProvider.categories.categories
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: cacheCategories)
            .disposed(by: disposeBag)
        
        dataProvider.categories.categoriesError
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: output.error)
            .disposed(by: disposeBag)
        
        input.transactionType
            .compactMap { $0 }
            .bind(to: dataProvider.categories.currentTransactionType)
            .disposed(by: disposeBag)
        
        input.saveAction
            .subscribe(onNext: { [weak self] in
                self?.saveTemplate()
            })
            .disposed(by: disposeBag)
    }
    
    func setupCategoriesBinding() {
        input.categoryCollectionExpanded
            .distinctUntilChanged()
            .map { expanded in
                expanded ?
                String.Localized.Common.wrap.localized :
                String.Localized.Common.still.localized
            }
            .bind(to: output.categoryButtonTitle)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            cacheCategories.distinctUntilChanged(),
            input.categoryCollectionExpanded.distinctUntilChanged()
        )
        .map { (categories, expanded) -> [CategoryDomainModel] in
            if expanded {
                return categories
            } else {
                return Array(categories.prefix(4))
            }
        }
        .bind(to: output.categories)
        .disposed(by: disposeBag)
    }
}

// MARK: - Private methods
private extension CreateTemplateViewModel {
    func validateValues() throws {
        guard !input.selectedIcon.value.isEmpty else { throw CustomError.emptySelectedIcon }
        guard input.selectedCategory.value != nil || !input.amount.value.isEmpty else { throw CustomError.emptySelectedCategoryOrAmount }
    }
    
    func saveTemplate() {
        output.isLoading.accept(true)
        
        if let duplicateTemplate = checkForDuplicateIcon() {
            self.output.isLoading.accept(false)
            self.output.duplicateIconAlert.onNext(duplicateTemplate)
            return
        }
        
        do {
            try validateValues()
            
            let operation: Completable = {
                switch mode {
                case .add: createTemplate()
                case .edit(let template): updateTemplate(template)
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
    
    func createTemplate() -> Completable {
        let template: TemplateDomainModel = .init(
            id: UUID(),
            icon: input.selectedIcon.value,
            amount: Double(input.amount.value),
            type: input.transactionType.value,
            category: input.selectedCategory.value
        )
        
        return dataProvider.template.createTemplate(template)
    }
    
    func updateTemplate(_ template: TemplateDomainModel) -> Completable {
        dataProvider.template.updateTemplate(
            id: template.id,
            newIcon:  input.selectedIcon.value,
            newType: input.transactionType.value,
            newAmount: Double(input.amount.value),
            newCategoryID: input.selectedCategory.value?.id
        )
        .asCompletable()
    }
    
    func checkForDuplicateIcon() -> TemplateDomainModel? {
        let templates: [TemplateDomainModel] = dataProvider.template.getTemplates(type: input.transactionType.value)
        let duplicateTemplate: TemplateDomainModel? = templates.first { $0.icon == self.input.selectedIcon.value }
        
        guard let duplicateTemplate = duplicateTemplate else { return nil }
        
        switch mode {
        case .add:
            return duplicateTemplate
        case .edit(let currentTemplate):
            return duplicateTemplate.id != currentTemplate.id ? duplicateTemplate : nil
        }
    }
}

// MARK: - Input, Output
extension CreateTemplateViewModel {
    struct Input {
        let saveAction: PublishSubject<Void> = .init()
        let transactionType: BehaviorRelay<TransactionType>
        let selectedIcon: BehaviorRelay<String> = .init(value: "")
        let selectedCategory: BehaviorRelay<CategoryDomainModel?> = .init(value: nil)
        let categoryCollectionExpanded: BehaviorRelay<Bool> = .init(value: false)
        let amount: BehaviorRelay<String> = .init(value: "")
    }
    
    struct Output {
        let dismiss: PublishSubject<Void> = .init()
        let error: PublishSubject<Error> = .init()
        let isLoading: BehaviorRelay<Bool> = .init(value: false)
        let icons: BehaviorRelay<[String]> = .init(value: [])
        let categories: BehaviorRelay<[CategoryDomainModel]> = .init(value: [])
        let categoryButtonTitle: BehaviorRelay<String?> = .init(value: nil)
        let duplicateIconAlert: PublishSubject<TemplateDomainModel> = .init()
    }
}

// MARK: - Erros
private enum CustomError: Error, LocalizedError {
    case emptySelectedIcon
    case emptySelectedCategoryOrAmount
    
    var errorDescription: String? {
        switch self {
        case .emptySelectedIcon: return .Localized.Error.emptyTemplateIcon.localized
        case .emptySelectedCategoryOrAmount: return .Localized.Error.emptyTemplateCategoryOrAmount.localized
        }
    }
}
