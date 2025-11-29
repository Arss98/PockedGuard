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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = .init()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset = .init(top: Constants.Layout.verticalPadding, left: .zero,
                                        bottom: Constants.Layout.scrollInset, right: .zero)
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var accountLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .semibold)
        label.text = L10n.Finance.Categories.accounts
        return label
    }()
    
    private lazy var accountsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.Layout.accountsCollectionSpacing
        layout.estimatedItemSize = CGSize(width: Constants.Layout.accountsCellWidth,
                                          height: Constants.Layout.accountsCellHeight)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .init(top: .zero, left: Constants.Layout.padding,
                                    bottom: .zero, right: Constants.Layout.padding)
        
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
        label.text = L10n.Finance.Categories.categories
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
        label.text = L10n.Finance.Categories.templates
        return label
    }()
    
    private lazy var templatesCollectionView: UICollectionView = {
        let layout: LeftAlignedCollectionViewFlowLayout = .init()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.Layout.collectionSpacing
        layout.minimumLineSpacing = Constants.Layout.collectionSpacing
        layout.sectionInset = .init(top: Constants.Layout.spacing / 2, left: Constants.Layout.padding,
                                    bottom: Constants.Layout.spacing / 2, right: Constants.Layout.padding)
        
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
    private var accountsDataSource: UICollectionViewDiffableDataSource<Int, AccountItemType>?
    private var categoriesDataSource: UICollectionViewDiffableDataSource<Int, CategoryItemType>?
    private var templatesDataSource: UICollectionViewDiffableDataSource<Int, TemplatesItemType>?
    private let viewModel: CategoriesViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        setupDataSource()
        setupDelegates()
        setupBindings()
    }
}

// MARK: - Binding methods
private extension CategoriesViewController {
    func setupBindings() {
        setupInputBinding()
        setupOutputBindings()
    }
    
    func setupInputBinding() {
        financeSegmentedControl.selectedIndex
            .compactMap { TransactionType(rawValue: Int16($0)) }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: viewModel.input.transactionType)
            .disposed(by: disposeBag)
    }
    
    func setupOutputBindings() {
        viewModel.output.accounts
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] accounts in
                self?.applyAccountSnapshot(accounts: accounts)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.categories
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] categories in
                self?.applyCategoriesSnapshot(categories: categories)
                self?.updateCategoriesCollectionViewHeight(numberOfItems: categories.count)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.templates
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] templates in
                self?.applyTemplatesSnapchot(templates: templates)
                self?.updateTemplatesCollectionViewHeight(numberOfItems: templates.count)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                self?.showActivityIndicator(isLoading)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showSystemCategoryAlert
            .subscribe(onNext: { [weak self] data in
                self?.showSystemCategoryAlert(category: data.category, action: data.action)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showPrimaryAccountAlert
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { controller, account in
                controller.showPrimaryAccountAlert(account: account)
            }
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
            let editAction: UIAction = .init(title: L10n.Common.edit,
                                      image: UIImage(systemName: "pencil")) { _ in
                self?.viewModel.input.editAccountTapped.onNext(account)
            }
            
            let setupPrimary: UIAction = .init(title: L10n.Categories.setPrimary,
                                               image: UIImage(systemName: "checkmark.circle.fill")) { _ in
                self?.viewModel.input.isPrimaryAccountTapped.onNext(account)
            }
            
            let deleteAction: UIAction = .init(title: L10n.Common.delete,
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                self?.viewModel.input.deleteAccountTapped.onNext(account.id)
            }
            
            return UIMenu(title: "", children: [editAction, setupPrimary, deleteAction])
        }
    }
    
    private func createCategoryContextMenu(_ category: CategoryDomainModel) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction: UIAction = .init(title: L10n.Common.edit,
                                      image: UIImage(systemName: "pencil")) { _ in
                self?.viewModel.input.categoryAction.onNext((category, .edit))
            }
            
            let deleteAction: UIAction = .init(title: L10n.Common.delete,
                                        image: UIImage(named: "trash"),
                                        attributes: .destructive) { _ in
                self?.viewModel.input.categoryAction.onNext((category, .delete))
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func createTemplateContextMenu(_ template: TemplateDomainModel) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction: UIAction = .init(title: L10n.Common.edit,
                                      image: UIImage(systemName: "pencil")) { _ in
                self?.viewModel.input.editTemplateTapped.onNext(template)
            }
            
            let deleteAction: UIAction = .init(title: L10n.Common.delete,
                                        image: UIImage(systemName: "trash"),
                                        attributes: .destructive) { _ in
                self?.viewModel.input.deleteTemplateTapped.onNext(template.id)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}

// MARK: - UICollectionViewDiffableDataSource methods
private extension CategoriesViewController {
    func setupDataSource() {
        setupAccountDataSource()
        setupCategoriesDataSource()
        setupTemplatesDataSource()
    }
    
    func setupAccountDataSource() {
        accountsDataSource = .init(collectionView: accountsCollectionView)
        { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .account(let account):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AccountViewCell.self),
                    for: indexPath) as? AccountViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(title: account.name, amount: account.balance, currency: account.currency)
                cell.isUserInteractionEnabled = false
                return cell
            case .add:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AddAccountCell.self),
                    for: indexPath) as? AddAccountCell else {
                    return UICollectionViewCell()
                }
                cell.addAccountTap
                    .bind(to: self.viewModel.input.addAccountTapped)
                    .disposed(by: cell.disposeBag)
                return cell
            }
        }
    }
    
    func applyAccountSnapshot(accounts: [AccountItemType]) {
        guard let accountsDataSource else { return }
        
        var snapshot: NSDiffableDataSourceSnapshot<Int, AccountItemType> = .init()
        snapshot.appendSections([.zero])
        snapshot.appendItems(accounts)
        accountsDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setupCategoriesDataSource() {
        categoriesDataSource = .init(collectionView: categoriesCollectionView)
        { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .category(let category):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: CategoriesViewCell.self),
                    for: indexPath) as? CategoriesViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(title: category.name, color: category.color)
                cell.isUserInteractionEnabled = false
                return cell
            case .add:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AddCategoryCell.self),
                    for: indexPath) as? AddCategoryCell else {
                    return UICollectionViewCell()
                }
                cell.addCategoryTap
                    .bind(to: self.viewModel.input.addCategoryTapped)
                    .disposed(by: cell.disposeBag)
                return cell
            }
        }
    }
    
    func applyCategoriesSnapshot(categories: [CategoryItemType]) {
        guard let categoriesDataSource else { return }
        
        var snapshot: NSDiffableDataSourceSnapshot<Int, CategoryItemType> = .init()
        snapshot.appendSections([.zero])
        snapshot.appendItems(categories)
        categoriesDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setupTemplatesDataSource() {
        templatesDataSource = .init(collectionView: templatesCollectionView)
        { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell()}
            switch item {
            case .template(let template):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: TemplatesCellView.self),
                    for: indexPath) as? TemplatesCellView else {
                    return UICollectionViewCell()
                }
                cell.configure(with: template.icon)
                cell.isUserInteractionEnabled = false
                return cell
            case .add:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AddTemplateCell.self),
                    for: indexPath) as? AddTemplateCell else {
                    return UICollectionViewCell()
                }
                cell.addTemplateTap
                    .bind(to: self.viewModel.input.addTemplateTapped)
                    .disposed(by: cell.disposeBag)
                return cell
            }
        }
    }
    
    func applyTemplatesSnapchot(templates: [TemplatesItemType]) {
        guard let templatesDataSource else { return }
        
        var snapshot: NSDiffableDataSourceSnapshot<Int, TemplatesItemType> = .init()
        snapshot.appendSections([.zero])
        snapshot.appendItems(templates)
        templatesDataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Alert Methods
private extension CategoriesViewController {
    func showSystemCategoryAlert(category: CategoryDomainModel, action: CategoriesViewModel.CategoryAction) {
        let actionTitle: String
        switch action {
        case .delete: actionTitle = L10n.Common.delete
        case .edit: actionTitle = L10n.Common.edit
        }
        
        showConfirmationAlert(
            title: L10n.Alerts.SystemCategory.title,
            message: L10n.Alerts.SystemCategory.message(category.name, actionTitle),
            confirmAction: { [weak self] in
                self?.viewModel.input.confirmCategoryAction.onNext((category, action))
            }
        )
    }
    
    func showPrimaryAccountAlert(account: AccountDomainModel) {
        showConfirmationAlert(
            title: L10n.Alerts.PrimaryAccount.title,
            message: L10n.Alerts.PrimaryAccount.message(account.name),
            confirmAction: { [weak self] in
                self?.viewModel.input.confirmSetPrimaryAccount.onNext(account)
            }
        )
    }
}

// MARK: - UI Setup
private extension CategoriesViewController {
    func setupUI() {
        title = L10n.Finance.Categories.title
        
        view.addSubview(financeSegmentedControl)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [accountLabel, accountsCollectionView, categoryLabel,
         categoriesCollectionView, templateLabel, templatesCollectionView].forEach { contentView.addSubview($0) }
    }
    
    func updateCategoriesCollectionViewHeight(numberOfItems: Int) {
        let rows: CGFloat = ceil(CGFloat(numberOfItems) / 2)
        let height: CGFloat = max(0, rows * Constants.Layout.categoriesCellHeight + (rows - 1) * Constants.Layout.collectionSpacing)
    
        UIView.animate(withDuration: Constants.Animation.duration) {
            self.categoriesCollectionHeight.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    func updateTemplatesCollectionViewHeight(numberOfItems: Int) {
        guard let layout = templatesCollectionView.collectionViewLayout as? LeftAlignedCollectionViewFlowLayout,
              numberOfItems > 0 else {
            templatesCollectionHeight.constant = 0
            return
        }
        
        let itemsPerRow: CGFloat = 5
        let rows: CGFloat = ceil(CGFloat(numberOfItems) / itemsPerRow)
        let itemHeight: CGFloat = layout.itemSize.height
        let totalLineSpacing: CGFloat = layout.minimumLineSpacing * (rows - 1)
        let totalSectionInset: CGFloat = layout.sectionInset.top + layout.sectionInset.bottom
        
        let height: CGFloat = (rows * itemHeight) + totalLineSpacing + totalSectionInset
        
        UIView.animate(withDuration: Constants.Animation.duration) {
            self.templatesCollectionHeight.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            financeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            financeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.segmentControlWidth),
            financeSegmentedControl.heightAnchor.constraint(equalToConstant: Constants.Layout.segmentedControlHeight),
            
            scrollView.topAnchor.constraint(equalTo: financeSegmentedControl.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            accountLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                  constant: Constants.Layout.padding),
            accountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                   constant: -Constants.Layout.padding),
            
            accountsCollectionView.topAnchor.constraint(equalTo: accountLabel.bottomAnchor,
                                                        constant: Constants.Layout.collectionSpacing),
            accountsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            accountsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            accountsCollectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.accountsCollectionViewHeight),
            
            categoryLabel.topAnchor.constraint(equalTo: accountsCollectionView.bottomAnchor,
                                               constant: Constants.Layout.verticalPadding),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.Layout.padding),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,
                                                          constant: Constants.Layout.spacing),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoriesCollectionHeight,
            
            templateLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor,
                                               constant: Constants.Layout.verticalPadding),
            templateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.Layout.padding),
            
            templatesCollectionView.topAnchor.constraint(equalTo: templateLabel.bottomAnchor,
                                                         constant: Constants.Layout.spacing),
            templatesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            templatesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            templatesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                            constant: -Constants.Layout.padding * 2),
            templatesCollectionHeight
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let segmentControlWidth: CGFloat = 216
        static let segmentedControlHeight: CGFloat = 44
        static let padding: CGFloat = 16
        static let verticalPadding: CGFloat = 24
        static let spacing: CGFloat = 10
        static let collectionSpacing: CGFloat = 12
        static let categoriesCellHeight: CGFloat = 44
        static let templatesCellSize: CGFloat = 60
        static let accountsCellHeight: CGFloat = 54
        static let accountsCollectionViewHeight: CGFloat = 60
        static let accountsCellWidth: CGFloat = 160
        static let accountsCollectionSpacing: CGFloat = 8
        static let scrollInset: CGFloat = 48
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.3
    }
    
    enum Text {
        static let fontSize: CGFloat = 16
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            L10n.Finance.expenses,
            L10n.Finance.income
        ]
    }
}
