//
//  CategoriesViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

final class CategoriesViewController: BaseViewController {
    // MARK: - UI elements
    private lazy var financeSegmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.financeItems)
    
    private lazy var accountLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .semibold)
        label.text = .Localized.Common.accountLabelTitle.localized
        return label
    }()
    
    private lazy var accountsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.Layout.accountsCollectionSpacing
        layout.estimatedItemSize = CGSize(width: Constants.Layout.accountsCellWidth,
                                          height: Constants.Layout.accountsCellHeight)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(AccountViewCell.self,
                            forCellWithReuseIdentifier: String(describing: AccountViewCell.self))
        collection.register(AddAccountCell.self, forCellWithReuseIdentifier: String(describing: AddAccountCell.self))
        
        return collection
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .Localized.Common.categoryLabelTitle.localized
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight:.semibold)
        label.textColor = .white
        return label
    }()
    
    private lazy var categoriesCollectionLayout: UICollectionViewCompositionalLayout = .init { _, _ in
        let itemSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(Constants.Layout.categoriesCellHeight)
        )
        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
        let groupSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.Layout.categoriesCellHeight)
        )
        let group: NSCollectionLayoutGroup = .horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(Constants.Layout.collectionSpacing)
        
        let section: NSCollectionLayoutSection = .init(group: group)
        section.interGroupSpacing = Constants.Layout.collectionSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: .zero, leading: Constants.Layout.padding,
            bottom: .zero, trailing: Constants.Layout.padding
        )
        
        return section
    }
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: categoriesCollectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(CategoriesViewCell.self,
                            forCellWithReuseIdentifier: String(describing: CategoriesViewCell.self))
        collection.register(AddCategoryCell.self, forCellWithReuseIdentifier: String(describing: AddCategoryCell.self))
        return collection
    }()
    
    private lazy var templateLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .semibold)
        label.text = .Localized.Common.templatesLabelTitle.localized
        return label
    }()
    
    private lazy var templatesCollectionView: UICollectionView = {
        let layout: LeftAlignedCollectionViewFlowLayout = .init()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.Layout.collectionSpacing
        layout.estimatedItemSize = CGSize(width: Constants.Layout.templatesCellSize,
                                          height: Constants.Layout.templatesCellSize)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(TemplatesCellView.self,
                            forCellWithReuseIdentifier: String(describing: TemplatesCellView.self))
        collection.register(AddTemplateCell.self,
                            forCellWithReuseIdentifier: String(describing: AddTemplateCell.self))
        return collection
    }()
    
    private lazy var categoriesCollectionHeight: NSLayoutConstraint = {
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: .zero)
    }()
    
    private lazy var templatesCollectionHeight: NSLayoutConstraint = {
        templatesCollectionView.heightAnchor.constraint(equalToConstant: .zero)
    }()
    
    // MARK: - Properties
    private let viewModel: CategoriesViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        setupBindings()
        setupDelegates()
    }
}

// MARK: - Binding methods
private extension CategoriesViewController {
    func setupBindings() {
        setupInputBindings()
        setupOutputBindings()
    }
    
    func setupInputBindings() {
        financeSegmentedControl.selectedIndex
            .map { TransactionType(rawValue: Int16($0)) }
            .bind(to: viewModel.input.transactionType)
            .disposed(by: disposeBag)
    }
    
    func setupOutputBindings() {
        viewModel.output.accounts
            .asDriver(onErrorJustReturn: [])
            .drive(accountsCollectionView.rx.items) { [weak self] collectionView, row, item in
                guard let self else { return UICollectionViewCell() }
                switch item {
                case .account(let account):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: AccountViewCell.self),
                        for: IndexPath(row: row, section: .zero)) as? AccountViewCell else {
                        return UICollectionViewCell()
                    }
                    cell.configure(title: account.name, amount: account.balance, currency: account.currency)
                    cell.isUserInteractionEnabled = false
                    return cell
                case .add:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: AddAccountCell.self),
                        for: IndexPath(row: row, section: .zero)) as? AddAccountCell else {
                        return UICollectionViewCell()
                    }
                    cell.addAccountTap
                        .bind(to: self.viewModel.input.addAccountTapped)
                        .disposed(by: self.disposeBag)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.output.templates
            .asDriver(onErrorJustReturn: [])
            .drive(templatesCollectionView.rx.items) { [weak self] collectionView, row, item in
                guard let self else { return UICollectionViewCell()}
                switch item {
                case .template(let template):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: TemplatesCellView.self),
                        for: IndexPath(row: row, section: .zero)) as? TemplatesCellView else {
                        return UICollectionViewCell()
                    }
                    cell.configure(with: template.icon)
                    cell.isUserInteractionEnabled = false
                    return cell
                case .add:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: AddTemplateCell.self),
                        for: IndexPath(row: row, section: .zero)) as? AddTemplateCell else {
                        return UICollectionViewCell()
                    }
                    cell.addTemplateTap
                        .bind(to: self.viewModel.input.addTemplateTapped)
                        .disposed(by: self.disposeBag)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.output.categories
            .asDriver(onErrorJustReturn: [])
            .drive(categoriesCollectionView.rx.items) { [weak self] collectionView, row, item in
                guard let self else { return UICollectionViewCell() }
                switch item {
                case .category(let category):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: CategoriesViewCell.self),
                        for: IndexPath(row: row, section: .zero)) as? CategoriesViewCell else {
                        return UICollectionViewCell()
                    }
                    cell.configure(title: category.name, color: category.color)
                    cell.isUserInteractionEnabled = false
                    return cell
                case .add:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: AddCategoryCell.self),
                        for: IndexPath(row: row, section: .zero)) as? AddCategoryCell else {
                        return UICollectionViewCell()
                    }
                    cell.addCategoryTap
                        .bind(to: self.viewModel.input.addCategoryTapped)
                        .disposed(by: self.disposeBag)
                    return cell
                }
            }
            .disposed(by: disposeBag)

        
        viewModel.output.accounts
            .subscribe { [weak self] _ in
                self?.accountsCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        viewModel.output.categories
            .subscribe { [weak self] _ in
                self?.updateCategoriesCollectionViewHeight()
            }
            .disposed(by: disposeBag)
        
        viewModel.output.templates
            .subscribe { [weak self] _ in
                self?.updateTemplatesCollectionViewHeight()
            }
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                self?.showActivityIndicator(isLoading)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showSystemCategoryAlert
            .subscribe(onNext: { [weak self] data in
                self?.showSystemCategoryAlert(category: data.category, action: data.action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate
extension CategoriesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath: IndexPath = indexPaths.first else { return nil }
        
        if collectionView == accountsCollectionView {
            let account: AccountItemType = viewModel.output.accounts.value[indexPath.item]
            switch account {
            case .account(let account): return createAccountContextMenu(account)
            case .add: return nil
            }
        }
        
        else if collectionView == categoriesCollectionView {
            let category: CategoryItemType = viewModel.output.categories.value[indexPath.item]
            switch category {
            case .category(let category): return createCategoryContextMenu(category)
            case .add: return nil
            }
        }
        
        else if collectionView == templatesCollectionView {
            let template: TemplatesItemType = viewModel.output.templates.value[indexPath.item]
            switch template {
            case .template(let template): return createTemplateContextMenu(template)
            case .add: return nil
            }
        }
        
        return nil
    }
    
    private func setupDelegates() {
        accountsCollectionView.delegate = self
        categoriesCollectionView.delegate = self
        templatesCollectionView.delegate = self
    }
    
    private func createAccountContextMenu(_ account: AccountDomainModel) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: .Localized.Common.edit.localized,
                                      image: UIImage(systemName: "pencil")) { _ in
                self?.viewModel.input.editAccountTapped.onNext(account)
            }
            
            let deleteAction = UIAction(title: .Localized.Common.delete.localized,
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                self?.viewModel.input.deleteAccountTapped.onNext(account.id)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func createCategoryContextMenu(_ category: CategoryDomainModel) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: .Localized.Common.edit.localized,
                                      image: UIImage(systemName: "pencil")) { _ in
                self?.viewModel.input.categoryAction.onNext((category, .edit))
            }
            
            let deleteAction = UIAction(title: .Localized.Common.delete.localized,
                                        image: UIImage(named: "trash"),
                                        attributes: .destructive) { _ in
                self?.viewModel.input.categoryAction.onNext((category, .delete))
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func createTemplateContextMenu(_ template: TemplateDomainModel) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: .Localized.Common.edit.localized,
                                      image: UIImage(systemName: "pencil")) { _ in
                self?.viewModel.input.editTemplateTapped.onNext(template)
            }
            
            let deleteAction = UIAction(title: .Localized.Common.delete.localized,
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                self?.viewModel.input.deleteTemplateTapped.onNext(template.id)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - Alert Methods
private extension CategoriesViewController {
    func showSystemCategoryAlert(category: CategoryDomainModel, action: CategoriesViewModel.CategoryAction) {
        let actionTitle: String
        switch action {
        case .delete: actionTitle = .Localized.Common.delete.localized
        case .edit: actionTitle = .Localized.Common.edit.localized
        }
        
        let alert: UIAlertController = .init(
            title: .Localized.Alert.systemCategoryTitle.localized,
            message: String(format: .Localized.Alert.systemCategoryMessage.localized, category.name, actionTitle),
            preferredStyle: .alert
        )
        
        let cancelAction: UIAlertAction = .init(
            title: String.Localized.Common.cancel.localized,
            style: .cancel
        )
        
        let confirmAction: UIAlertAction = .init(
            title: String.Localized.Common.resume.localized,
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.input.confirmCategoryAction.onNext((category, action))
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UI Setup
private extension CategoriesViewController {
    func setupUI() {
        title = .Localized.Common.categoriesTitle.localized
        [financeSegmentedControl, accountLabel, accountsCollectionView, categoryLabel,
         categoriesCollectionView, templateLabel, templatesCollectionView].forEach { view.addSubview($0) }
    }
    
    func updateCategoriesCollectionViewHeight() {
        let numberOfItems: Int = viewModel.output.categories.value.count
        let rows: CGFloat = ceil(CGFloat(numberOfItems) / 2)
        let height: CGFloat = rows * Constants.Layout.categoriesCellHeight + (rows - 1) * Constants.Layout.collectionSpacing
        
        categoriesCollectionHeight.constant = height
        view.layoutIfNeeded()
    }
    
    func updateTemplatesCollectionViewHeight() {
        let numberOfItems = viewModel.output.templates.value.count
        let rows = ceil(CGFloat(numberOfItems) / 5)
        let height = rows * Constants.Layout.templatesCellSize + (rows - 1) * Constants.Layout.collectionSpacing
        
        templatesCollectionHeight.constant = height
        view.layoutIfNeeded()
    }
    
    func setConstraints() {
        categoriesCollectionHeight.isActive = true
        templatesCollectionHeight.isActive = true
        
        NSLayoutConstraint.activate([
            financeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            financeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.segmentControlWidth),
            
            accountLabel.topAnchor.constraint(equalTo: financeSegmentedControl.bottomAnchor,
                                              constant: Constants.Layout.verticalPadding),
            accountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                  constant: Constants.Layout.padding),
            accountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                   constant: -Constants.Layout.padding),
            
            accountsCollectionView.topAnchor.constraint(equalTo: accountLabel.bottomAnchor,
                                                        constant: Constants.Layout.collectionSpacing),
            accountsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                            constant: Constants.Layout.padding),
            accountsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                             constant: -Constants.Layout.padding),
            accountsCollectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.accountsCellHeight),
            
            categoryLabel.topAnchor.constraint(equalTo: accountsCollectionView.bottomAnchor,
                                               constant: Constants.Layout.verticalPadding),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.Layout.padding),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,
                                                          constant: Constants.Layout.spacing),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            templateLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor,
                                               constant: Constants.Layout.verticalPadding),
            templateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.Layout.padding),
            
            templatesCollectionView.topAnchor.constraint(equalTo: templateLabel.bottomAnchor,
                                                         constant: Constants.Layout.spacing),
            templatesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                             constant: Constants.Layout.padding),
            templatesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                              constant: -Constants.Layout.padding)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let segmentControlWidth: CGFloat = 216
        static let padding: CGFloat = 16
        static let verticalPadding: CGFloat = 24
        static let spacing: CGFloat = 10
        static let collectionSpacing: CGFloat = 12
        static let categoriesCellHeight: CGFloat = 44
        static let templatesCellSize: CGFloat = 60
        static let accountsCellHeight: CGFloat = 60
        static let accountsCellWidth: CGFloat = 160
        static let accountsCollectionSpacing: CGFloat = 8
    }
    
    enum Text {
        static let fontSize: CGFloat = 16
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            .Localized.Common.expenses.localized,
            .Localized.Common.income.localized
        ]
    }
}
