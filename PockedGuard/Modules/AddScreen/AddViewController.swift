//
//  AddViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa

final class AddViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var templatesInfoLabel: TemplatesInfoView = {
        let label: TemplatesInfoView = .init(frame: .zero)
        label.alpha = .zero
        return label
    }()
    
    private lazy var accountsCollection: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.financeCardsCollectionSpacing
        layout.estimatedItemSize = CGSize(width: Constants.financeCardsCellWidth,
                                          height: Constants.financeCardsCellHeight)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(AccountViewCell.self,
                            forCellWithReuseIdentifier: String(describing: AccountViewCell.self))
        
        return collection
    }()
    
    private lazy var dragHandleView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .appForegroundSecondary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.dragHandleHeight / 2
        return view
    }()
    
    private lazy var financeSegmentedControl: CustomSegmentedControl = {
        let segmentedControl: CustomSegmentedControl = .init(items: Constants.financeSegmentedControlItems)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private lazy var closeButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appForegroundSecondary
        
        let dateString: String = DateFormatter.ruDateTimeShort.string(from: Date())
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: dateString)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: .zero, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var amountTextField: UITextField = {
        let textField: UITextField = .init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: Constants.amountTextFieldFontSize, weight: .semibold)
        textField.textColor = .white
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        
        let placeholderText: String = .Localized.Add.amountPlaceholder.localized
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: Constants.amountTextFieldFontSize, weight: .semibold)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }()
    
    private lazy var descriptionTextField: UITextField = {
        let textField: UITextField = .init()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .appForegroundSecondary
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        
        let placeholderText: String = .Localized.Add.descriptionPlaceholder.localized
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appForegroundSecondary,
            .font: UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }()
    
    private lazy var templatesLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.text = .Localized.Add.templatesTitle.localized
        return label
    }()
    
    private lazy var helpButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.tintColor = .appForegroundSecondary
        return button
    }()
    
    private lazy var templatesStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [templatesLabel, helpButton])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var templatesCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.spacing
        layout.estimatedItemSize = CGSize(width: Constants.templatesCellSize, height: Constants.templatesCellSize)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(TemplatesCellView.self,
                            forCellWithReuseIdentifier: String(describing: TemplatesCellView.self))
        
        return collection
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
        label.textColor = .white
        label.text = .Localized.Add.categoryTitle.localized
        return label
    }()
    
    private lazy var categoriesCollectionLayout: UICollectionViewCompositionalLayout = .init { _, _ in
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(Constants.categoriesCellHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.categoriesCellHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = .fixed(Constants.spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Constants.spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: .zero, leading: Constants.defaultPadding,
            bottom: .zero, trailing: Constants.defaultPadding
        )
        
        return section
    }
    
    private lazy var categoryCollectionView: UICollectionView = {
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: categoriesCollectionLayout)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        collection.isUserInteractionEnabled = true
        collection.register(CategoriesViewCell.self,
                            forCellWithReuseIdentifier: String(describing: CategoriesViewCell.self))
        
        return collection
    }()
    
    private lazy var doneButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = .appMainBlue
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.setTitle(.Localized.Common.done.localized, for: .normal)
        
        return button
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture: UITapGestureRecognizer = .init()
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
        return gesture
    }()
    
    // MARK: - Properties
    private let viewModel: AddViewModelProtocol
    
    // MARK: - Init
    init(viewModel: AddViewModelProtocol = AddViewModel()) {
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
        setupBindings()
    }
}

// MARK: - Binding methods
private extension AddViewController {
    func saveTransaction() {
        viewModel.saveTransaction()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] in
                DataUpdateService.shared.notifyModalDismissed()
                self?.dismiss(animated: true)
            } onError: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func setupBindings() {
        financeSegmentedControl.selectedIndex
            .subscribe { [weak self] value in
                self?.viewModel.fetchData(by: .init(rawValue: Int16(value)))
                self?.viewModel.transactionType.accept(.init(rawValue: Int16(value)))
            }
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription, handler: {
                    self?.dismiss(animated: true)
                })
            })
            .disposed(by: disposeBag)
        
        setupButtonBindings()
        setupTextFiledBindings()
        setupCollectionBindings()
        setupSelectionCollectionCellBindings()
        setupKeyboardBinings()
    }
    
    func setupButtonBindings() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        helpButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else  { return }
                self.templatesInfoLabel.isVisible.toggle()
                self.view.bringSubviewToFront(self.templatesInfoLabel)
            })
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveTransaction()
            })
            .disposed(by: disposeBag)
    }
    
    func setupTextFiledBindings() {
        amountTextField.rx.text.orEmpty
            .map { Double($0.filter { $0.isNumber }) ?? 0 }
            .bind(to: viewModel.amount)
            .disposed(by: disposeBag)
        
        descriptionTextField.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: viewModel.notes)
            .disposed(by: disposeBag)
    }
    
    func setupCollectionBindings() {
        viewModel.accounts
            .asDriver(onErrorJustReturn: [])
            .drive(accountsCollection.rx.items(
                cellIdentifier: String(describing: AccountViewCell.self),
                cellType: AccountViewCell.self)) { row, model, cell in
                    cell.configure(title: model.name, amount: model.balance)
                }
                .disposed(by: disposeBag)
        
        viewModel.templates
            .asDriver(onErrorJustReturn: [])
            .drive(templatesCollectionView.rx.items(
                cellIdentifier: String(describing: TemplatesCellView.self),
                cellType: TemplatesCellView.self)) { row, model, cell in
                    cell.configure(with: model.icon)
                }
                .disposed(by: disposeBag)
        
        viewModel.categories
            .asDriver(onErrorJustReturn: [])
            .drive( categoryCollectionView.rx.items(
                cellIdentifier: String(describing: CategoriesViewCell.self),
                cellType: CategoriesViewCell.self)) { row, model, cell in
                    cell.configure(title: model.name, color: model.color)
                }
                .disposed(by: disposeBag)
        
        accountsCollection.rx.modelSelected(AccountDomainModel.self)
            .bind(to: viewModel.selectedAccount)
            .disposed(by: disposeBag)
        
        templatesCollectionView.rx.modelSelected(TemplatesDomainModel.self)
            .bind(to: viewModel.selectedTemplate)
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDomainModel.self)
            .bind(to: viewModel.selectedCategory)
            .disposed(by: disposeBag)
    }
    
    func setupSelectionCollectionCellBindings() {
        viewModel.selectedAccount
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] account in
                guard let self, let account else { return }
                
                let accounts = self.viewModel.accounts.value
                guard !accounts.isEmpty else { return }
                
                if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                    let indexPath = IndexPath(row: index, section: .zero)
                    self.accountsCollection.selectItem(at: indexPath, animated: true, scrollPosition: [.centeredVertically, .centeredHorizontally])
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedCategory
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] category in
                guard let self, let category else { return }
                
                let categories = self.viewModel.categories.value
                guard !categories.isEmpty else { return }
                
                if let index = categories.firstIndex(where: { $0.id == category.id }) {
                    let indexPath = IndexPath(row: index, section: .zero)
                    self.categoryCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [.centeredVertically, .centeredHorizontally])
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupKeyboardBinings() {
        tapGesture.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
                self?.templatesInfoLabel.isVisible = false
            }
            .disposed(by: disposeBag)
        
        amountTextField.rx.controlEvent(.editingDidEnd)
            .subscribe { [weak self] _ in
                guard let self,
                      let text = self.amountTextField.text else { return }
                
                let cleanedText = text.replacingOccurrences(of: "₽", with: "").trimmingCharacters(in: .whitespaces)
                
                if !cleanedText.isEmpty {
                    self.amountTextField.text = "\(cleanedText) ₽"
                } else {
                    self.amountTextField.text = ""
                }            }
            .disposed(by: disposeBag)
        
        descriptionTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location: CGPoint = touch.location(in: view)
        
        if helpButton.frame.contains(location) || accountsCollection.frame.contains(location)
            || templatesCollectionView.frame.contains(location)
            || categoryCollectionView.frame.contains(location) {
            return false
        }
        
        return true
    }
}

// MARK: - Private methods
private extension AddViewController {
    func setupUI() {
        [templatesInfoLabel, accountsCollection, dragHandleView, financeSegmentedControl, closeButton, dateLabel,
         amountTextField, descriptionTextField, templatesStackView, templatesCollectionView,
         categoryLabel, categoryCollectionView, doneButton]
            .forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            dragHandleView.topAnchor.constraint(equalTo: view.topAnchor,
                                                constant: Constants.dragHandlePadding),
            dragHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragHandleView.heightAnchor.constraint(equalToConstant: Constants.dragHandleHeight),
            dragHandleView.widthAnchor.constraint(equalToConstant: Constants.dragHandleWidth),
            
            financeSegmentedControl.topAnchor.constraint(equalTo: dragHandleView.topAnchor,
                                                         constant: Constants.defaultPadding),
            financeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.segmentControlWidth),
            
            closeButton.centerYAnchor.constraint(equalTo: financeSegmentedControl.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -Constants.defaultPadding),
            
            dateLabel.topAnchor.constraint(equalTo: financeSegmentedControl.bottomAnchor,
                                           constant: Constants.defaultPadding * 2),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            amountTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor,
                                                 constant: Constants.spacing),
            amountTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor,
                                                      constant: Constants.spacing),
            descriptionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            accountsCollection.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor,
                                                    constant: Constants.defaultPadding * 2),
            accountsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: Constants.defaultPadding),
            accountsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -Constants.defaultPadding),
            accountsCollection.heightAnchor.constraint(equalToConstant: Constants.financeCardsCellHeight),
            
            templatesStackView.topAnchor.constraint(equalTo: accountsCollection.bottomAnchor,
                                                    constant: Constants.spacing * 2),
            templatesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: Constants.defaultPadding),
            templatesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -Constants.defaultPadding),
            
            templatesInfoLabel.trailingAnchor.constraint(equalTo: helpButton.trailingAnchor,
                                                         constant: -Constants.defaultPadding),
            templatesInfoLabel.topAnchor.constraint(equalTo: helpButton.bottomAnchor),
            
            templatesCollectionView.topAnchor.constraint(equalTo: templatesLabel.bottomAnchor,
                                                         constant: Constants.spacing),
            templatesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                             constant: Constants.defaultPadding),
            templatesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                              constant: -Constants.defaultPadding),
            templatesCollectionView.heightAnchor.constraint(equalToConstant: Constants.templatesCeollectionHeight),
            
            categoryLabel.topAnchor.constraint(equalTo: templatesCollectionView.bottomAnchor,
                                               constant: Constants.spacing * 2),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.defaultPadding),
            
            categoryCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,
                                                        constant: Constants.spacing),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            doneButton.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor,
                                            constant: Constants.defaultPadding),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Constants.defaultPadding),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.defaultPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let fontSize: CGFloat = 14
    static let labelFontSize: CGFloat = 16
    static let amountTextFieldFontSize: CGFloat = 42
    static let defaultPadding: CGFloat = 16
    static let segmentControlWidth: CGFloat = 216
    static let dragHandleWidth: CGFloat = 40
    static let dragHandleHeight: CGFloat = 5
    static let dragHandlePadding: CGFloat = 10
    static let spacing: CGFloat = 12
    static let templatesCeollectionHeight: CGFloat = 60
    static let categoriesCellHeight: CGFloat = 44
    static let buttonCornerRadius: CGFloat = 10
    static let buttonHeight: CGFloat = 52
    static let templatesCellSize: CGFloat = 60
    static let financeCardsCellHeight: CGFloat = 60
    static let financeCardsCellWidth: CGFloat = 160
    static let financeCardsCollectionSpacing: CGFloat = 8
    
    static let financeSegmentedControlItems: [String] = [.Localized.Common.expenses.localized,
                                                         .Localized.Common.income.localized]
}
