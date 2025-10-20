//
//  CreateTemplateViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.09.2025.
//

import RxSwift
import RxCocoa

final class CreateTemplateViewController: BaseViewController {
    // MARK: - UI elements
    private lazy var dragHandleView: DragHandleView = .init()
    private lazy var financeSegmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.financeItems)
    
    private lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = .init()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .semibold)
        label.text = .Localized.Add.addTemplate.localized
        
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var iconLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .Localized.Common.icon.localized
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .semibold)
        return label
    }()
    
    private lazy var iconsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.minimumInteritemSpacing = Constants.Layout.spacing
        layout.minimumLineSpacing = Constants.Layout.collectionSpacing
        layout.estimatedItemSize = CGSize(width: Constants.Layout.templatesCellSize,
                                          height: Constants.Layout.templatesCellSize)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = .init(top: .zero, left: Constants.Layout.defaultPadding,
                                    bottom: .zero, right: Constants.Layout.defaultPadding)
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        collection.register(TemplatesCellView.self,
                            forCellWithReuseIdentifier: String(describing: TemplatesCellView.self))
        
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
    
    private lazy var categoryExpandedButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.Localized.Common.still.localized, for: .normal)
        button.tintColor = .appForegroundSecondary
        button.titleLabel?.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        return button
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
            top: .zero, leading: Constants.Layout.defaultPadding,
            bottom: .zero, trailing: Constants.Layout.defaultPadding
        )
        
        return section
    }
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: categoriesCollectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        collection.delegate = self
        collection.register(CategoriesViewCell.self,
                            forCellWithReuseIdentifier: String(describing: CategoriesViewCell.self))
        return collection
    }()
    
    private lazy var amountTextField: CustomTextField = {
        let textField: CustomTextField = .init()
        textField.configure(
            with: .Localized.Common.amount.localized,
            placeholder: .Localized.Add.amountPlaceholder.localized,
            keyboardType: .decimalPad,
            titleColor: .white
        )
        return textField
    }()
    
    private lazy var amountShowDescriptionButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.tintColor = .appForegroundSecondary
        return button
    }()
    
    private lazy var amountDescriptionTooltip: InfoTooltipView = {
        let tooltip: InfoTooltipView = .init()
        tooltip.configure(with: .Localized.Add.templateAmountInfo.localized)
        return tooltip
    }()
    
    private lazy var doneButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.Localized.Common.done.localized, for: .normal)
        button.backgroundColor = .appMainBlue
        button.tintColor = .white
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture: UITapGestureRecognizer = .init()
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    // MARK: - Constraints
    private lazy var iconsCollectionHeight: NSLayoutConstraint = {
        iconsCollectionView.heightAnchor.constraint(equalToConstant: .zero)
    }()
    
    private lazy var categoriesCollectionHeight: NSLayoutConstraint = {
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: .zero)
    }()
    
    private lazy var doneButtonBottomConstraint: NSLayoutConstraint = {
        doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.defaultPadding)
    }()
    
    // MARK: - Private properties
    private var categoriesDataSource: UICollectionViewDiffableDataSource<Int, CategoryDomainModel>?
    private let viewModel: CreateTemplateViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CreateTemplateViewModelProtocol) {
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
        setupIconsDataSource()
        setupInitialValues()
        setupBindings()
    }
}

// MARK: - Private methods
private extension CreateTemplateViewController {
    func setupBindings() {
        setupButtonBinding()
        setupOutputBinding()
        setupInputBinding()
        setupKeyboardBinding()
        setupKeyboardHandling()
    }
    
    func setupButtonBinding() {
        closeButton.rx.tap
            .bind(to: viewModel.output.dismiss)
            .disposed(by: disposeBag)
        
        categoryExpandedButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let toggleExpanded: Bool = !self.viewModel.input.categoryCollectionExpanded.value
                self.viewModel.input.categoryCollectionExpanded.accept(toggleExpanded)
            })
            .disposed(by: disposeBag)
        
        amountShowDescriptionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else  { return }
                
                let isVisible = !self.amountDescriptionTooltip.isVisible
                self.amountDescriptionTooltip.isVisible = isVisible
                self.view.bringSubviewToFront(self.amountDescriptionTooltip)
                
                self.amountShowDescriptionButton.tintColor = isVisible ? .appSelectedBlue : .appForegroundSecondary
            })
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
                self?.viewModel.input.saveAction.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func setupOutputBinding() {
        viewModel.output.error
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .subscribe(with: self) { controller, isLoading in
                controller.showActivityIndicator(isLoading)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.icons
            .asDriver(onErrorJustReturn: [])
            .drive(iconsCollectionView.rx.items(
                cellIdentifier: String(describing: TemplatesCellView.self),
                cellType: TemplatesCellView.self)) { row, icon, cell in
                    cell.configure(with: icon)
                }
                .disposed(by: disposeBag)
        
        viewModel.output.icons
            .subscribe(onNext: { [weak self] _ in
                self?.updateIconsCollectionViewHeight()
                
                if case .edit(let template) = self?.viewModel.mode {
                    if let iconIndex = self?.viewModel.output.icons.value.firstIndex(of: template.icon) {
                        let indexPath = IndexPath(item: iconIndex, section: .zero)
                        self?.iconsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.categories
            .subscribe(onNext: { [weak self] categories in
                self?.applyCategoriesSnapshot(categories: categories)
                self?.updateCategoriesCollectionViewHeight(numberOfItems: categories.count)
                
                if case .edit(let template) = self?.viewModel.mode,
                   let category = template.category,
                   let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) {
                    let indexPath = IndexPath(item: categoryIndex, section: .zero)
                    self?.categoriesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.categoryButtonTitle
            .asDriver(onErrorJustReturn: .Localized.Common.still.localized)
            .drive(categoryExpandedButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.output.duplicateIconAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] duplicateTemplate in
                self?.showDuplicateIconAlert(for: duplicateTemplate)
            })
            .disposed(by: disposeBag)
    }
    
    func setupInputBinding() {
        financeSegmentedControl.selectedIndex
            .compactMap { TransactionType(rawValue: Int16($0)) }
            .bind(to: viewModel.input.transactionType)
            .disposed(by: disposeBag)
        
        iconsCollectionView.rx.modelSelected(String.self)
            .bind(to: viewModel.input.selectedIcon)
            .disposed(by: disposeBag)
        
        amountTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.amount)
            .disposed(by: disposeBag)
    }
    
    func setupKeyboardBinding() {
        amountTextField.textFieldRx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
                self?.amountDescriptionTooltip.isVisible = false
                self?.amountShowDescriptionButton.tintColor = .appForegroundSecondary
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CreateTemplateViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UITextField) && !(touch.view is UIButton) && !(touch.view is UICollectionViewCell)
    }
}

// MARK: - Setup Collection and UICollectionViewDelegate methods
extension CreateTemplateViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectCategory(indexPath: indexPath)
    }
    
    private func setupIconsDataSource() {
        categoriesDataSource = .init(collectionView: categoriesCollectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: CategoriesViewCell.self),
                for: indexPath) as? CategoriesViewCell else { return UICollectionViewCell() }
            cell.configure(title: item.name, color: item.color)
            return cell
        }
    }
    
    private func applyCategoriesSnapshot(categories: [CategoryDomainModel]) {
        guard let categoriesDataSource else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, CategoryDomainModel>()
        snapshot.appendSections([.zero])
        snapshot.appendItems(categories)
        categoriesDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateIconsCollectionViewHeight() {
        let numberOfRows: CGFloat = Constants.Layout.iconsCollectionNumberOfRows
        let height = numberOfRows * Constants.Layout.templatesCellSize + (numberOfRows - 1) * Constants.Layout.collectionSpacing
        
        iconsCollectionHeight.constant = height
    }
    
    private func updateCategoriesCollectionViewHeight(numberOfItems: Int) {
        let rows: CGFloat = ceil(CGFloat(numberOfItems) / 2)
        let height: CGFloat = max(0, rows * Constants.Layout.categoriesCellHeight + (rows - 1) * Constants.Layout.collectionSpacing)
        categoriesCollectionHeight.constant = height
        
        UIView.animate(withDuration: Constants.Animation.duration) {
            self.scrollView.layoutIfNeeded()
        }
    }
}

// MARK: - Keyboard setting
private extension CreateTemplateViewController {
    func setupKeyboardHandling() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                      let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
                
                let keyboardHeight = keyboardFrame.height
                
                self.updateLayoutForKeyboard(
                    height: keyboardHeight - Constants.Layout.defaultPadding,
                    duration: duration,
                    curve: curve
                )
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self,
                      let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                      let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
                
                self.updateLayoutForKeyboard(height: Constants.Layout.defaultPadding, duration: duration, curve: curve)
            })
            .disposed(by: disposeBag)
    }
    
    func updateLayoutForKeyboard(height: CGFloat, duration: TimeInterval, curve: UInt) {
        doneButtonBottomConstraint.constant = -height
        
        UIView.animate(withDuration: duration, delay: .zero, options: UIView.AnimationOptions(rawValue: curve)) {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: max(0, scrollView.contentSize.height - scrollView.frame.size.height))
        scrollView.setContentOffset(bottomOffset, animated: animated)
    }
}

// MARK: - ShowDuplicateIconAlert methods
private extension CreateTemplateViewController {
    func showDuplicateIconAlert(for duplicateTemplate: TemplateDomainModel) {
        let alert: UIAlertController = .init(
            title: .Localized.Alert.duplicateTemplateIconTitle.localized,
            message: .Localized.Alert.duplicateTemplateIconMessage.localized,
            preferredStyle: .alert
        )
        alert.overrideUserInterfaceStyle = .dark
        
        let replaceAction: UIAlertAction = .init(title: .Localized.Common.replace.localized,style: .destructive) { [weak self] _ in
            self?.viewModel.confirmReplacement(replacing: duplicateTemplate.id)
        }
        
        let cancelAction: UIAlertAction = .init(title: .Localized.Common.cancel.localized, style: .cancel) { [weak self] _ in
            self?.viewModel.output.isLoading.accept(false)
        }
        
        alert.addAction(replaceAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UI setup methods
private extension CreateTemplateViewController {
    func setupUI() {
        [dragHandleView, titleLabel, closeButton, scrollView, doneButton].forEach { view.addSubview($0) }
        [financeSegmentedControl, iconLabel, iconsCollectionView, categoryLabel,
         categoryExpandedButton, categoriesCollectionView, amountTextField,
         amountShowDescriptionButton, amountDescriptionTooltip]
            .forEach { scrollView.addSubview($0) }
    }
    
    func setupInitialValues() {
        if case .edit(let template) = viewModel.mode {
            amountTextField.text = viewModel.input.amount.value
            
            if let amount: Double = template.amount, amount > 0 {
                let integerPart: Int = Int(amount)
                amountTextField.text = String(integerPart)
            }
        }
        
        let initialIndex: Int = Int(viewModel.input.transactionType.value.rawValue)
        financeSegmentedControl.setSelectedIndex(initialIndex)
    }
    
    func setConstraints() {
        let contentLayoutGuide: UILayoutGuide = scrollView.contentLayoutGuide
        let frameLayoutGuide: UILayoutGuide = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            dragHandleView.topAnchor.constraint(equalTo: view.topAnchor,
                                                constant: Constants.Layout.spacing),
            dragHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: dragHandleView.bottomAnchor,
                                            constant: Constants.Layout.spacing),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.Layout.defaultButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.Layout.defaultButtonSize),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -Constants.Layout.defaultPadding / 2),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.Layout.defaultPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.Layout.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            doneButtonBottomConstraint, 
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                            constant: Constants.Layout.defaultPadding),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: doneButton.topAnchor),
            
            financeSegmentedControl.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            financeSegmentedControl.centerXAnchor.constraint(equalTo: frameLayoutGuide.centerXAnchor),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.segmentControlWidth),
            financeSegmentedControl.heightAnchor.constraint(equalToConstant: Constants.Layout.segmentedControlHeight),
            
            iconLabel.topAnchor.constraint(equalTo: financeSegmentedControl.bottomAnchor,
                                           constant: Constants.Layout.defaultPadding * 2),
            iconLabel.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor,
                                               constant: Constants.Layout.defaultPadding),
            
            iconsCollectionView.topAnchor.constraint(equalTo: iconLabel.bottomAnchor,
                                                     constant: Constants.Layout.spacing),
            iconsCollectionView.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
            iconsCollectionView.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
            iconsCollectionHeight,
            
            categoryLabel.topAnchor.constraint(equalTo: iconsCollectionView.bottomAnchor,
                                               constant: Constants.Layout.defaultPadding * 2),
            categoryLabel.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor,
                                                   constant: Constants.Layout.defaultPadding),
            
            categoryExpandedButton.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            categoryExpandedButton.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor,
                                                         constant: -Constants.Layout.defaultPadding),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,
                                                          constant: Constants.Layout.spacing),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
            categoriesCollectionHeight,
            
            amountTextField.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor,
                                                 constant: Constants.Layout.defaultPadding * 2),
            amountTextField.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor,
                                                     constant: Constants.Layout.defaultPadding),
            amountTextField.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor,
                                                      constant: -Constants.Layout.defaultPadding),
            amountTextField.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor,
                                                    constant: -Constants.Layout.defaultPadding),
            
            amountShowDescriptionButton.centerYAnchor.constraint(equalTo: amountTextField.topAnchor,
                                                                 constant: Constants.Layout.spacing),
            amountShowDescriptionButton.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor,
                                                      constant: -Constants.Layout.defaultPadding),
            
            amountDescriptionTooltip.topAnchor.constraint(equalTo: amountShowDescriptionButton.bottomAnchor),
            amountDescriptionTooltip.trailingAnchor.constraint(equalTo: amountShowDescriptionButton.leadingAnchor)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Text {
        static let titleFontSize: CGFloat = 18
        static let fontSize: CGFloat = 16
    }
    
    enum Layout {
        static let spacing: CGFloat = 10
        static let defaultPadding: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 52
        static let segmentControlWidth: CGFloat = 216
        static let segmentedControlHeight: CGFloat = 44
        static let circleSize: CGFloat = 36
        static let collectionSpacing: CGFloat = 12
        static let templatesCellSize: CGFloat = 60
        static let iconsCollectionNumberOfRows: CGFloat = 2
        static let categoriesCellHeight: CGFloat = 44
        static let maxCollapsedCategoriesRows: CGFloat = 2
        static let defaultButtonSize: CGFloat = 44
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.3
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            .Localized.Common.expenses.localized,
            .Localized.Common.income.localized
        ]
    }
}
