//
//  CreateCategoryViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 24.09.2025.
//

import RxSwift
import RxCocoa

final class CreateCategoryViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var dragHandleView: DragHandleView = .init()
    private lazy var financeSegmentedControl: CustomSegmentedControl = .init(items:  Constants.SegmentedControl.financeItems)
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.titleFontSize, weight: .semibold)
        label.text = .Localized.Add.addCategory.localized
        
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var categoryNameTextField: CustomTextField = {
        let textfield: CustomTextField = .init()
        textfield.configure(
            with: .Localized.Add.categoryNameLabel.localized,
            placeholder: .Localized.Add.categoryNamePlaceholder.localized,
            titleColor: .white
        )
        return textfield
    }()
    
    private lazy var colorCategoryLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .Localized.Add.colorCategoryTitle.localized
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .semibold)
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.minimumLineSpacing = Constants.Layout.minimumLineSpacing
        layout.scrollDirection = .horizontal
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.allowsMultipleSelection = false
        collection.register(CategoryColorCell.self,
                            forCellWithReuseIdentifier: String(describing: CategoryColorCell.self))
        collection.register(AddColorCell.self,
                            forCellWithReuseIdentifier: String(describing: AddColorCell.self))
        return collection
    }()
    
    private lazy var colorPicker: UIColorPickerViewController = {
        let picker: UIColorPickerViewController = .init()
        picker.supportsAlpha = true
        picker.delegate = self
        picker.overrideUserInterfaceStyle = .dark
        return picker
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
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    private lazy var doneButtonBottomConstraint: NSLayoutConstraint = {
        doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -Constants.Layout.defaultPadding)
    }()
    
    // MARK: - Private properties
    private let viewModel: CreateCategoryViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CreateCategoryViewModelProtocol) {
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
        setupInitialValues()
        setupBinding()
        setupKeyboardHandling()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layout = colorCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = calculateItemSize()
        }
    }
}

// MARK: - Private methods
private extension CreateCategoryViewController {
    func setupBinding() {
        setupOutputBinding()
        setupCollectionBinding()
        setupInputBinding()
        setupButtonBinding()
        setupKeyboardBinding()
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
    }
    
    func setupCollectionBinding() {
        viewModel.output.colors
            .asDriver(onErrorJustReturn: [])
            .drive(colorCollectionView.rx.items) { [weak self] collectionView, row, item in
                guard let self else { return UICollectionViewCell() }
                switch item {
                case .color(let color):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: CategoryColorCell.self),
                        for: IndexPath(row: row, section: .zero)) as? CategoryColorCell else {
                        return UICollectionViewCell()
                    }
                    cell.configure(with: color)
                    cell.hexColor
                        .bind(to: self.viewModel.input.selectedColor)
                        .disposed(by: cell.disposeBag)
                    return cell
                case .add:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: String(describing: AddColorCell.self),
                        for: IndexPath(row: row, section: .zero)) as? AddColorCell else {
                        return UICollectionViewCell()
                    }
                    cell.addColorTap
                        .subscribe(onNext: {
                            self.present(self.colorPicker, animated: true) {
                                self.deselectCollectionItems()
                            }
                        })
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        colorCollectionView.rx.methodInvoked(#selector(UICollectionView.layoutSubviews))
            .withLatestFrom(viewModel.input.selectedColor.compactMap { $0 })
            .subscribe(onNext: { [weak self] color in
                self?.selectFirstCollectionItem()
            })
            .disposed(by: disposeBag)
    }
    
    func setupInputBinding() {
        financeSegmentedControl.selectedIndex
            .compactMap { TransactionType(rawValue: Int16($0)) }
            .distinctUntilChanged()
            .bind(to: viewModel.input.transactionType)
            .disposed(by: disposeBag)
        
        categoryNameTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.categoryName)
            .disposed(by: disposeBag)
    }
    
    func setupButtonBinding() {
        closeButton.rx.tap
            .bind(to: viewModel.output.dismiss)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
                self?.viewModel.input.saveAction.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func setupKeyboardBinding() {
        categoryNameTextField.textFieldRx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CreateCategoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location: CGPoint = touch.location(in: view)
        if colorCollectionView.frame.contains(location)  { return false }
        
        return true
    }
}

// MARK: - UIColorPickerViewControllerDelegate
extension CreateCategoryViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor: UIColor = viewController.selectedColor
        if let hexColor: String = selectedColor.toHex() {
            viewModel.addCustomColor(hexColor)
            showToast(message: .Localized.Alert.addColorMessage.localized)
        }
    }
}

// MARK: - Keyboard setting
private extension CreateCategoryViewController {
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
        }
    }
}

// MARK: - UI setup methods
private extension CreateCategoryViewController {
    func setupUI() {
        [dragHandleView, titleLabel, closeButton, financeSegmentedControl,
         categoryNameTextField, colorCategoryLabel, colorCollectionView, doneButton]
            .forEach { view.addSubview($0) }
    }
    
    func setupInitialValues() {
        if case .edit = viewModel.mode {
            categoryNameTextField.text = viewModel.input.categoryName.value
            titleLabel.text = .Localized.Add.editCategory.localized
        }
        
        let initialIndex: Int = Int(viewModel.input.transactionType.value.rawValue)
        financeSegmentedControl.setSelectedIndex(initialIndex)
    }
    
    func deselectCollectionItems() {
        if let selectedItems: [IndexPath] = colorCollectionView.indexPathsForSelectedItems {
            selectedItems.forEach { colorCollectionView.deselectItem(at: $0, animated: false) }
        }
    }
    
    func selectFirstCollectionItem() {
        if colorCollectionView.numberOfItems(inSection: 0) > 0 {
            let indexPath = IndexPath(item: 0, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
    }
    
    func calculateItemSize() -> CGSize {
        let numberOfItems: CGFloat = CGFloat(viewModel.output.colors.value.count)
        let totalSpacing: CGFloat = Constants.Layout.defaultPadding * 2
        let interItemSpacing: CGFloat = Constants.Layout.minimumLineSpacing * (numberOfItems - 1)
        
        let availableWidth: CGFloat = view.frame.width - totalSpacing - interItemSpacing
        let itemWidth: CGFloat = availableWidth / numberOfItems
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            dragHandleView.topAnchor.constraint(equalTo: view.topAnchor,
                                                constant: Constants.Layout.spacing),
            dragHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: dragHandleView.bottomAnchor,
                                            constant: Constants.Layout.spacing),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -Constants.Layout.defaultPadding),
            
            financeSegmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                         constant: Constants.Layout.defaultPadding),
            financeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            financeSegmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.segmentControlWidth),
            
            categoryNameTextField.topAnchor.constraint(equalTo: financeSegmentedControl.bottomAnchor,
                                                       constant: Constants.Layout.defaultPadding * 2),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                           constant: Constants.Layout.defaultPadding),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                            constant: -Constants.Layout.defaultPadding),
            
            colorCategoryLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor,
                                                    constant: Constants.Layout.spacing * 2),
            colorCategoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorCategoryLabel.bottomAnchor,
                                                     constant: Constants.Layout.spacing),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                         constant: Constants.Layout.defaultPadding),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -Constants.Layout.defaultPadding),
            colorCollectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.circleSize),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.Layout.defaultPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.Layout.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight),
            doneButtonBottomConstraint
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
        static let circleSize: CGFloat = 36
        static let minimumLineSpacing: CGFloat = 11
    }
    
    enum SegmentedControl {
        static let financeItems: [String] = [
            .Localized.Common.expenses.localized,
            .Localized.Common.income.localized
        ]
    }
}
