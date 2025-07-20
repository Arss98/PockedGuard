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
        label.font = .systemFont(ofSize: Constants.commonTextFontSize, weight: .regular)
        label.text = .Localized.Notification.frequency.localized
        
        return label
    }()
    
    private lazy var periodButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle(.Localized.Notification.once.localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.commonTextFontSize,
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
        label.font = .systemFont(ofSize: Constants.commonTextFontSize, weight: .regular)
        
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
        label.font = .systemFont(ofSize: Constants.commonTextFontSize, weight: .regular)
        
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
        button.layer.cornerRadius = Constants.buttonCornerRadius
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
    init(mode: CreateNotificationViewModel.Mode = .add) {
        self.viewModel = CreateNotificationViewModel(mode: mode)
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
        setupBinding()
        setupKeyboardNavigation()
    }
}

// MARK: - Binding methods
private extension CreateNotificationViewController {
    func setupInitialValues() {
        if case .edit = viewModel.mode {
            headingTextField.text = viewModel.title.value
            descriptionTextField.text = viewModel.notes.value
            timePicker.date = viewModel.date.value
            datePicker.date = viewModel.date.value
            periodButton.setTitle(viewModel.reminderType.value.localizedTitle, for: .normal)
        }
    }
    
    func setupBinding() {
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.showActivityIndicator(isLoading)
            })
            .disposed(by: disposeBag)
        
        headingTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        descriptionTextField.textFieldRx.text.orEmpty
            .debounce(.microseconds(300), scheduler: MainScheduler.instance)
            .bind(to: viewModel.notes)
            .disposed(by: disposeBag)
        
        timePicker.rx.date
            .bind(to: viewModel.time)
            .disposed(by: disposeBag)
        
        datePicker.rx.date
            .bind(to: viewModel.date)
            .disposed(by: disposeBag)
        
        headingTextField.textFieldRx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] in
                self?.headingTextField.errorText = ""
            })
            .disposed(by: disposeBag)
        
        descriptionTextField.textFieldRx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] in
                self?.descriptionTextField.errorText = ""
            })
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.validateAndSave()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { AppRouter.shared.pop(animated: true) },
                       onError: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        periodButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<ReminderType> in
                guard let self else { return .empty() }
                return self.showSelectionSheet()
                    .compactMap { $0 }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self else { return }
                self.periodButton.setTitle(type.localizedTitle, for: .normal)
                self.viewModel.reminderType.accept(type)
            })
            .disposed(by: disposeBag)
    }
    
    func validateAndSave() -> Observable<Void> {
        if headingTextField.text?.isEmpty == true {
            headingTextField.errorText = .Localized.Common.textEmpty.localized
            return .empty()
        }
        
        if descriptionTextField.text?.isEmpty == true {
            descriptionTextField.errorText = .Localized.Common.textEmpty.localized
            return .empty()
        }
        
        return viewModel.saveNotification()
            .andThen(.just(()))
    }
    
    func setupKeyboardNavigation() {
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
                                                  constant: Constants.verticalPadding),
            headingTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: Constants.defaultPadding),
            headingTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -Constants.defaultPadding),
            
            descriptionTextField.topAnchor.constraint(equalTo: headingTextField.bottomAnchor,
                                                      constant: Constants.verticalPadding),
            descriptionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: Constants.defaultPadding),
            descriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                           constant: -Constants.defaultPadding),
            
            periodStackView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor,
                                                 constant: Constants.verticalPadding),
            periodStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: Constants.defaultPadding),
            periodStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -Constants.defaultPadding),
            
            timeStackView.topAnchor.constraint(equalTo: periodStackView.bottomAnchor,
                                               constant: Constants.spacing),
            timeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.defaultPadding),
            timeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -Constants.defaultPadding),
            
            dateStackView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor,
                                               constant: Constants.spacing),
            dateStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: Constants.defaultPadding),
            dateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -Constants.defaultPadding),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.defaultPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -Constants.defaultPadding),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Constants.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let commonTextFontSize: CGFloat = 14
    static let defaultPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 24
    static let spacing: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 10
    static let buttonHeight: CGFloat = 52
}
