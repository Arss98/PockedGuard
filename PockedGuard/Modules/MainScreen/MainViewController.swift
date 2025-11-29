//
//  MainViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import RxSwift
import RxCocoa
import SwiftUI

final class MainViewController: BaseViewController {
    // MARK: - UI Elements
    private lazy var periodSegmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.periodItems)
    
    private lazy var financeSegmentedControl: CustomSegmentedControl = {
        let segmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.financeItems)
        segmentedControl.widthAnchor.constraint(equalToConstant: Constants.Layout.segmentControlWidth).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: Constants.Layout.segmentedControlHeight).isActive = true
        return segmentedControl
    }()
    
    private lazy var accountsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.Layout.accountsCollectionSpacing
        layout.estimatedItemSize = CGSize(
            width: Constants.Layout.accountsCellWidth,
            height: Constants.Layout.accountsCellHeight
        )
        
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(AccountViewCell.self,
                            forCellWithReuseIdentifier: String(describing: AccountViewCell.self))
        
        return collection
    }()
    
    private lazy var circleDiagramView: UIHostingController<CircleDiagramView> = {
        let circleDiagramView: CircleDiagramView = .init()
        let hostingController: UIHostingController<CircleDiagramView> = .init(rootView: circleDiagramView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()
    
    private lazy var previousPeriodButton: UIButton = {
        let button: UIButton = .init(type: .system)
        let image: UIImage? = .init(systemName: "chevron.left")
        let configuration: UIImage.SymbolConfiguration = .init(pointSize: Constants.Layout.periodButtonSize)
        button.setImage(image?.withConfiguration(configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    
    private lazy var nextPeriodButton: UIButton = {
        let button: UIButton = .init(type: .system)
        let image: UIImage? = .init(systemName: "chevron.right")
        let configuration: UIImage.SymbolConfiguration = .init(pointSize: Constants.Layout.periodButtonSize)
        button.setImage(image?.withConfiguration(configuration), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    
    private lazy var periodLabel: UILabel = {
        let label: UILabel = .init()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var transactionsBackgroundView: UIView = {
        let view: UIView = .init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appBackground
        view.layer.cornerRadius = Constants.Layout.transactionsBackgroundCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = Constants.Layout.transactionsBackgroundShadowOffset
        view.layer.shadowRadius = Constants.Layout.transactionsBackgroundShadowRadius
        view.layer.shadowOpacity = Constants.Layout.transactionsBackgroundShadowOpacity
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var transactionTableView: UITableView = {
        let tableView: UITableView = .init()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = .zero
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TransactionRowCell.self,
                           forCellReuseIdentifier: String(describing: TransactionRowCell.self))
        tableView.register(TransactionsHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: String(describing: TransactionsHeaderView.self))
        
        return tableView
    }()
    
    private lazy var dragHandleView: UIView = {
        let view: UIView = .init()
        view.backgroundColor = .appForegroundSecondary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.Layout.dragHandleHeight / 2
        return view
    }()
    
    private lazy var noTransactionLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .regular)
        label.textAlignment = .center
        label.text = L10n.Finance.Transactions.empty
        label.isHidden = true
        return label
    }()
    
    private lazy var topConstraintPeriodSegmentedControl: NSLayoutConstraint = {
        periodSegmentedControl.topAnchor.constraint(equalTo: periodLabel.bottomAnchor,
                                                    constant: Constants.Layout.defaultPadding)
    }()
    
    private lazy var tableViewHeightConstraint: NSLayoutConstraint = {
        transactionTableView.heightAnchor.constraint(equalTo: transactionsBackgroundView.heightAnchor, multiplier: Constants.Layout.multiplier)
    }()
    
    // MARK: - Properties
    private var viewModel: MainViewModelProtocol
    private var transactionDataSource: UITableViewDiffableDataSource<TransactionSection, TransactionDomainModel>?
    private var isExpanded = false
    
    // MARK: - Init
    init(viewModel: MainViewModelProtocol) {
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
        setupTransactionDataSource()
        setConstraints()
        setupGestures()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transactionTableView.isScrollEnabled = isExpanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toggleIsHiddenBar(false)
    }
}

// MARK: - Bindings methods
private extension MainViewController {
    func setupBindings() {
        inputBindings()
        outputBindings()
    }
    
    func inputBindings() {
        setupBarButtonItem(at: .right, image: .remindingIcon)
            .bind(to: viewModel.output.showNotification)
            .disposed(by: disposeBag)
        
        financeSegmentedControl.selectedIndex
            .compactMap { TransactionType(rawValue: Int16($0)) }
            .bind(to: viewModel.input.transactionType)
            .disposed(by: disposeBag)
        
        periodSegmentedControl.selectedIndex
            .subscribe(with: self) { controller, index in
                controller.viewModel.handlePeriodSelection(index: index)
            }
            .disposed(by: disposeBag)
        
        previousPeriodButton.rx.tap
            .bind(to: viewModel.input.previousPeriod)
            .disposed(by: disposeBag)
        
        nextPeriodButton.rx.tap
            .bind(to: viewModel.input.nextPeriod)
            .disposed(by: disposeBag)
        
        accountsCollectionView.rx.modelSelected(AccountDomainModel.self)
            .bind(to: viewModel.input.selectedAccount)
            .disposed(by: disposeBag)
        
        viewModel.input.showDatePickerTrigger
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .flatMapLatest { controller, _ in
                controller.showDatePicker()
            }
            .subscribe(with: self) { controller, dates in
                controller.viewModel.output.period.accept(.custom(start: dates.0, end: dates.1))
            }
            .disposed(by: disposeBag)
    }
    
    func outputBindings() {
        viewModel.output.sections
            .subscribe(with: self) { controller, sections in
                controller.noTransactionLabel.isHidden = !sections.isEmpty
                controller.applyTransactionSnapshot(with: sections)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.output.segmentsDiagram,
            viewModel.output.currencySymbol
        )
        .asDriver(onErrorJustReturn: ([], "₽"))
        .drive(onNext: { [weak self] segments, currencySymbol in
            self?.circleDiagramView.rootView = CircleDiagramView(segments: segments, currencySymbol: currencySymbol)
        })
        .disposed(by: disposeBag)
        
        viewModel.output.accounts
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { controller, accounts in
                guard let selectedAccount = controller.viewModel.input.selectedAccount.value,
                      let index = accounts.firstIndex(where: { $0.id == selectedAccount.id }) else { return }
                
                let indexPath = IndexPath(row: index, section: .zero)
                controller.accountsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.accounts
            .asDriver(onErrorJustReturn: [])
            .drive(accountsCollectionView.rx.items(
                cellIdentifier: String(describing: AccountViewCell.self),
                cellType: AccountViewCell.self
            )) { _, model, cell in
                cell.configure(title: model.name, amount: model.balance, currency: model.currency)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.period
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { controller, period in
                controller.periodLabel.text = period.description
                
                if case .custom = period {
                    controller.setPeriodButtonsVisibility(false)
                } else {
                    controller.setPeriodButtonsVisibility(true)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { controller, error in
                controller.showErrorAlert(message: error.localizedDescription)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { controller, bool in
                controller.showActivityIndicator(bool)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDiffableDataSource, UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    private func setupTransactionDataSource() {
        transactionDataSource = .init(tableView: transactionTableView) { tableView, indexPath, transaction in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: TransactionRowCell.self),
                for: indexPath) as? TransactionRowCell else { return UITableViewCell() }
            
            cell.configure(with: transaction)
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    private func applyTransactionSnapshot(with sections: [TransactionSection]) {
        guard let transactionDataSource else { return }
        
        var snapshot: NSDiffableDataSourceSnapshot<TransactionSection, TransactionDomainModel> = .init()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.transactions, toSection: section)
        }
        
        transactionDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: TransactionsHeaderView.self)
        ) as? TransactionsHeaderView else { return nil }
        
        guard let dataSource = transactionDataSource else { return nil }
        let snapshot = dataSource.snapshot()
        let sectionIdentifiers = snapshot.sectionIdentifiers
        let currentSection = sectionIdentifiers[section]
        
        header.backgroundConfiguration = UIBackgroundConfiguration.listPlainHeaderFooter()
        header.backgroundConfiguration?.backgroundColor = .appBackground
        
        header.configure(
            categoryName: currentSection.categoryName,
            percentage: currentSection.percentage,
            amount: currentSection.transactions.reduce(.zero) { $0 + $1.amount },
            color: currentSection.transactions.first?.category?.color,
            currencySymbol: currentSection.currencySymbol
        )
        
        return header
    }
}

// MARK: - Setup Methods
private extension MainViewController {
    func setupUI() {
        navigationItem.titleView = financeSegmentedControl
        
        addChild(circleDiagramView)
        [accountsCollectionView, circleDiagramView.view, previousPeriodButton, nextPeriodButton, periodLabel,
         periodSegmentedControl, transactionsBackgroundView].forEach { view.addSubview($0) }
        circleDiagramView.didMove(toParent: self)
        
        [dragHandleView, transactionTableView, noTransactionLabel].forEach { transactionsBackgroundView.addSubview($0) }
    }
    
    func toggleIsHiddenBar(_ isHidden: Bool) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.isHiddenTabBar = isHidden
        
        navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }
    
    func setPeriodButtonsVisibility(_ isVisible: Bool) {
        UIView.animate(withDuration: Constants.Animation.duration) {
            self.previousPeriodButton.alpha = isVisible ? 1 : 0
            self.nextPeriodButton.alpha = isVisible ? 1 : 0
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            accountsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            accountsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            accountsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -Constants.Layout.defaultPadding),
            accountsCollectionView.heightAnchor.constraint(equalToConstant: Constants.Layout.accountsCellHeight),
            
            previousPeriodButton.centerYAnchor.constraint(equalTo: circleDiagramView.view.centerYAnchor),
            previousPeriodButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: Constants.Layout.defaultPadding / 2),
            previousPeriodButton.widthAnchor.constraint(equalToConstant: Constants.Layout.periodButtonSize),
            
            circleDiagramView.view.topAnchor.constraint(equalTo: accountsCollectionView.bottomAnchor,
                                                        constant: Constants.Layout.defaultVerticalPadding),
            circleDiagramView.view.leadingAnchor.constraint(equalTo: previousPeriodButton.trailingAnchor,
                                                        constant: Constants.Layout.defaultPadding / 2),
            circleDiagramView.view.trailingAnchor.constraint(equalTo: nextPeriodButton.leadingAnchor,
                                                        constant: -Constants.Layout.defaultPadding / 2),
            
            nextPeriodButton.centerYAnchor.constraint(equalTo: circleDiagramView.view.centerYAnchor),
            nextPeriodButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -Constants.Layout.defaultPadding / 2),
            nextPeriodButton.widthAnchor.constraint(equalToConstant: Constants.Layout.periodButtonSize),
            
            periodLabel.topAnchor.constraint(equalTo: circleDiagramView.view.bottomAnchor,
                                             constant: Constants.Layout.defaultVerticalPadding),
            periodLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            topConstraintPeriodSegmentedControl,
            periodSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                            constant: Constants.Layout.defaultPadding),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                             constant: -Constants.Layout.defaultPadding),
            periodSegmentedControl.heightAnchor.constraint(equalToConstant: Constants.Layout.segmentedControlHeight),
            
            transactionsBackgroundView.topAnchor.constraint(equalTo: periodSegmentedControl.bottomAnchor,
                                                            constant: Constants.Layout.defaultPadding),
            transactionsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            transactionsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            dragHandleView.topAnchor.constraint(equalTo: transactionsBackgroundView.topAnchor,
                                                constant: Constants.Layout.dragHandlePadding),
            dragHandleView.centerXAnchor.constraint(equalTo: transactionsBackgroundView.centerXAnchor),
            dragHandleView.widthAnchor.constraint(equalToConstant: Constants.Layout.dragHandleWidth),
            dragHandleView.heightAnchor.constraint(equalToConstant: Constants.Layout.dragHandleHeight),
            
            noTransactionLabel.topAnchor.constraint(equalTo: dragHandleView.bottomAnchor,
                                                    constant: Constants.Layout.defaultPadding),
            noTransactionLabel.leadingAnchor.constraint(equalTo: transactionsBackgroundView.leadingAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            noTransactionLabel.trailingAnchor.constraint(equalTo: transactionsBackgroundView.trailingAnchor,
                                                         constant: -Constants.Layout.defaultPadding),
            
            transactionTableView.topAnchor.constraint(equalTo: dragHandleView.bottomAnchor,
                                                      constant: Constants.Layout.dragHandlePadding),
            transactionTableView.leadingAnchor.constraint(equalTo: transactionsBackgroundView.leadingAnchor,
                                                          constant: Constants.Layout.defaultPadding),
            transactionTableView.trailingAnchor.constraint(equalTo: transactionsBackgroundView.trailingAnchor,
                                                           constant: -Constants.Layout.defaultPadding),
            transactionTableView.bottomAnchor.constraint(equalTo: transactionsBackgroundView.bottomAnchor,
                                                         constant: -Constants.Layout.defaultPadding),
            tableViewHeightConstraint
        ])
    }
}

// MARK: - Gesture Handling
private extension MainViewController {
    func setupGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        
        transactionsBackgroundView.addGestureRecognizer(swipeUp)
        transactionsBackgroundView.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up: expandView()
        case .down: collapseView()
        default: break
        }
    }
    
    func expandView() {
        toggleIsHiddenBar(true)
        animateView(expanded: true, topAnchor: view.safeAreaLayoutGuide.topAnchor, alphas: (0, 0, 0))
    }
    
    func collapseView() {
        toggleIsHiddenBar(false)
        animateView(expanded: false, topAnchor: periodLabel.bottomAnchor, alphas: (1, 1, 1))
    }
    
    func animateView(
        expanded: Bool,
        topAnchor: NSLayoutYAxisAnchor,
        alphas: (accounts: CGFloat, diagram: CGFloat, label: CGFloat)
    ) {
        isExpanded = expanded
        
        UIView.animate(
            withDuration: Constants.Animation.duration, delay: .zero,
            options: [.curveEaseInOut, .allowUserInteraction], animations: {
                self.updateViewConstraints(topAnchor: topAnchor, alphas: alphas)
            }
        )
    }
    
    func updateViewConstraints(
        topAnchor: NSLayoutYAxisAnchor,
        alphas: (accounts: CGFloat, diagram: CGFloat, label: CGFloat)
    ) {
        topConstraintPeriodSegmentedControl.isActive = false
        tableViewHeightConstraint.isActive = false
        
        topConstraintPeriodSegmentedControl = periodSegmentedControl.topAnchor.constraint(
            equalTo: topAnchor, constant: Constants.Layout.defaultPadding)
        tableViewHeightConstraint = transactionTableView.heightAnchor.constraint(equalTo: transactionsBackgroundView.heightAnchor, multiplier: Constants.Layout.multiplier)
    
        topConstraintPeriodSegmentedControl.isActive = true
        tableViewHeightConstraint.isActive = true
        
        accountsCollectionView.alpha = alphas.accounts
        circleDiagramView.view.alpha = alphas.diagram
        periodLabel.alpha = alphas.label
        
        view.layoutIfNeeded()
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let defaultVerticalPadding: CGFloat = 20
        static let accountsCellHeight: CGFloat = 60
        static let accountsCellWidth: CGFloat = 160
        static let accountsCollectionSpacing: CGFloat = 8
        static let dragHandleWidth: CGFloat = 40
        static let dragHandleHeight: CGFloat = 5
        static let dragHandlePadding: CGFloat = 10
        static let transactionsBackgroundCornerRadius: CGFloat = 22
        static let transactionsBackgroundShadowRadius: CGFloat = 6
        static let transactionsBackgroundShadowOpacity: Float = 0.4
        static let transactionsBackgroundShadowOffset = CGSize(width: 0, height: -4)
        static let multiplier: CGFloat = 0.95
        static let periodButtonSize: CGFloat = 44
        static let segmentControlWidth: CGFloat = 216
        static let segmentedControlHeight: CGFloat = 44
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
        
        static let periodItems: [String] = [
            L10n.Period.day,
            L10n.Period.week,
            L10n.Period.month,
            L10n.Period.title
        ]
    }
}

