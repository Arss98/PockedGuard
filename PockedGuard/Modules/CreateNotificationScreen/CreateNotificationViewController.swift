//
//  CreateNotificationViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

final class CreateNotificationViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var headingTextField: CustomTextField = {
        let textField: CustomTextField = .init()
        textField.configure(
            with: .Localized.Notification.reminderTitle.localized,
            placeholder: .Localized.Notification.titlePlaceholder.localized)
        return textField
    }()
    
    private lazy var descriptionTextField: CustomTextField = {
        let textField: CustomTextField = .init()
        textField.configure(
            with: .Localized.Notification.reminderText.localized,
            placeholder: .Localized.Notification.textPlaceholder.localized)
        return textField
    }()
    
    private lazy var periodLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.text = .Localized.Notification.frequency.localized
        
        return label
    }()
    
    private lazy var periodButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle(.Localized.Notification.once.localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.Text.fontSize,
                                              weight: .regular)
        return button
    }()
    
    private lazy var periodStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [periodLabel, periodButton])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var timeLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.text = .Localized.Notification.time.localized
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        
        return label
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let picker: UIDatePicker = .init()
        picker.datePickerMode = .time
        picker.tintColor = .white
        picker.locale = Locale(identifier: "RU_ru")
        picker.overrideUserInterfaceStyle = .dark
        picker.preferredDatePickerStyle = .compact
        
        return picker
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [timeLabel, timePicker])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        
        return stackView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label: UILabel = .init()
        label.textColor = .white
        label.text = .Localized.Notification.startDate.localized
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker: UIDatePicker = .init()
        picker.datePickerMode = .date
        picker.tintColor = .appSelectedBlue
        picker.locale = Locale(identifier: "RU_ru")
        picker.overrideUserInterfaceStyle = .dark
        return picker
    }()
    
    private lazy var dateStackView: UIStackView = {
        let stackView: UIStackView = .init(arrangedSubviews: [dateLabel, datePicker])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
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
        return gesture
    }()
    
    // MARK: - Properties
    private let viewModel: CreateNotificationViewModelProtocol
    
    // MARK: - Init
    init(viewModel: CreateNotificationViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        setupInitialValues()
        setupInputBinding()
        setupOutputBindings()
        setupKeyboardBindings()
    }
}

// MARK: - Binding methods
private extension CreateNotificationViewController {
    func setupInitialValues() {
        if case .edit = viewModel.mode {
            headingTextField.text = viewModel.input.title.value
            descriptionTextField.text = viewModel.input.notes.value
            timePicker.date = viewModel.input.date.value
            datePicker.date = viewModel.input.date.value
            periodButton.setTitle(viewModel.input.reminderType.value.localizedTitle, for: .normal)
            
            title = .Localized.Notification.edit.localized
        }
    }
    
    func setupInputBinding() {
        headingTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.title)
            .disposed(by: disposeBag)
        
        descriptionTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.notes)
            .disposed(by: disposeBag)
        
        timePicker.rx.date
            .bind(to: viewModel.input.time)
            .disposed(by: disposeBag)
        
        datePicker.rx.date
            .bind(to: viewModel.input.date)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.input.saveAction)
            .disposed(by: disposeBag)
        
        periodButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<ReminderType?> in
                guard let self else { return .empty() }
                return self.showSelectionSheet(localizedTitleProvider: { $0.localizedTitle })
            }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self else { return }
                self.periodButton.setTitle(type.localizedTitle, for: .normal)
                self.viewModel.input.reminderType.accept(type)
            })
            .disposed(by: disposeBag)
    }
    
    func setupOutputBindings() {
        viewModel.output.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.showActivityIndicator(isLoading)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    func setupKeyboardBindings() {
        headingTextField.textFieldRx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.descriptionTextField.setupFirstResponser()
            })
            .disposed(by: disposeBag)
        
        descriptionTextField.textFieldRx.controlEvent(.editingDidEndOnExit)
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

// MARK: - Private methods
private extension CreateNotificationViewController {
    func setupUI() {
        title = .Localized.Notification.createTitle.localized
        [headingTextField, descriptionTextField, periodStackView, timeStackView, dateStackView, doneButton].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            headingTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: Constants.Layout.verticalPadding),
            headingTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: Constants.Layout.defaultPadding),
            headingTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -Constants.Layout.defaultPadding),
            
            descriptionTextField.topAnchor.constraint(equalTo: headingTextField.bottomAnchor,
                                                      constant: Constants.Layout.verticalPadding),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: Constants.Layout.defaultPadding),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                           constant: -Constants.Layout.defaultPadding),
            
            periodStackView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor,
                                                 constant: Constants.Layout.verticalPadding),
            periodStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Constants.Layout.defaultPadding),
            periodStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -Constants.Layout.defaultPadding),
            
            timeStackView.topAnchor.constraint(equalTo: periodStackView.bottomAnchor,
                                               constant: Constants.Layout.spacing),
            timeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.Layout.defaultPadding),
            timeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -Constants.Layout.defaultPadding),
            
            dateStackView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor,
                                               constant: Constants.Layout.spacing),
            dateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.Layout.defaultPadding),
            dateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -Constants.Layout.defaultPadding),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.Layout.defaultPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.Layout.defaultPadding),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Constants.Layout.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 24
        static let spacing: CGFloat = 12
        static let buttonCornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 52
    }
    
    enum Text {
        static let fontSize: CGFloat = 14
    }
}
