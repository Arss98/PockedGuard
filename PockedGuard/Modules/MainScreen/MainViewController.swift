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
    private lazy var financeSegmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.financeItems)
    
    private lazy var accountsCollection: UICollectionView = {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.Layout.financeCardsCollectionSpacing
        layout.estimatedItemSize = CGSize(
            width: Constants.Layout.financeCardsCellWidth,
            height: Constants.Layout.financeCardsCellHeight
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
        let circleDiagramView: CircleDiagramView = .init(segments: self.viewModel.segmentsDiagram.value)
        let hostingController: UIHostingController<CircleDiagramView> = .init(rootView: circleDiagramView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()
    
    private lazy var periodSegmentedControl: CustomSegmentedControl = {
        let segmentedControl: CustomSegmentedControl = .init(items: Constants.SegmentedControl.periodItems)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
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
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = .zero
        tableView.delegate = self
        tableView.dataSource = self
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
        label.text = .Localized.Common.transactionsEmptyLabel.localized
        label.isHidden = true
        return label
    }()
    
    // MARK: - Swipe Gesture Properties
    var viewModel: MainViewModelProtocol
    
    private var isExpanded = false
    private var topConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var sections: [TransactionSection] = []
    
    // MARK: - Init
    init(viewModel: MainViewModelProtocol = MainViewModel()) {
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
        setupBindings()
        setConstraints()
        setupGestures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transactionTableView.isScrollEnabled = isExpanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.isHiddenTabBar = false
    }
}

// MARK: - Bindings methods
private extension MainViewController {
    func setupBindings() {
        bindUIComponents()
        bindViewModelOutputs()
        setupButtonBindings()
    }
    
    func setupButtonBindings() {
        setupLeftBarButtonItem(at: .right, image: .remindingIcon)
            .subscribe(with: self, onNext: { controller, _ in
                controller.remindingNavBarButtonAction()
            })
            .disposed(by: disposeBag)
    }
    
    func bindUIComponents() {
        financeSegmentedControl.selectedIndex
            .map { TransactionType(rawValue: Int16($0)) }
            .bind(to: viewModel.currentTransactionType)
            .disposed(by: disposeBag)
        
        periodSegmentedControl.selectedIndex
            .subscribe(with: self) { controller, index in
                controller.viewModel.handlePeriodSelection(index: index)
            }
            .disposed(by: disposeBag)
        
        accountsCollection.rx.modelSelected(AccountDomainModel.self)
            .bind(to: viewModel.selectedAccount)
            .disposed(by: disposeBag)
    }
    
    func bindViewModelOutputs() {
        viewModel.periodText
            .bind(to: periodLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.sections
            .subscribe(with: self) { controller, sections in
                controller.noTransactionLabel.isHidden = !sections.isEmpty
                controller.sections = sections
                controller.transactionTableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        viewModel.segmentsDiagram
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] segments in
                self?.circleDiagramView.rootView = CircleDiagramView(segments: segments)
            })
            .disposed(by: disposeBag)
        
        viewModel.accounts
            .asDriver(onErrorJustReturn: [])
            .drive(accountsCollection.rx.items(
                cellIdentifier: String(describing: AccountViewCell.self),
                cellType: AccountViewCell.self
            )) { _, model, cell in
                cell.configure(title: model.name, amount: model.balance)
            }
            .disposed(by: disposeBag)
        
        viewModel.showDatePickerTrigger
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .flatMapLatest { controller, _ in
                controller.showDatePicker()
            }
            .subscribe(with: self) { controller, dates in
                controller.viewModel.updateCustomPeriod(start: dates.0, end: dates.1)
            }
            .disposed(by: disposeBag)
        
        DataUpdateService.shared.modalDismissedSubject
            .subscribe(with: self) { controller, _ in
                controller.viewModel.fetchData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].isExpanded ? sections[section].transactions.count : .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TransactionRowCell.self),
            for: indexPath) as? TransactionRowCell else {
            return UITableViewCell()
        }
        
        let section = sections[indexPath.section]
        let isLastCell: Bool = indexPath.row == section.transactions.count - 1
        
        cell.isUserInteractionEnabled = false
        cell.configure(with: section.transactions[indexPath.row])
        cell.updateUI(isLastCell: isLastCell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: TransactionsHeaderView.self)
        ) as? TransactionsHeaderView else { return nil }
        
        header.backgroundConfiguration = UIBackgroundConfiguration.listPlainHeaderFooter()
        header.backgroundConfiguration?.backgroundColor = .appCardAndField
        
        header.configure(
            categoryName: sections[section].categoryName,
            percentage: sections[section].percentage,
            amount: sections[section].transactions.reduce(0) { $0 + $1.amount },
            color: sections[section].transactions.first?.category?.color
        )
        
        let tapGesture = UITapGestureRecognizer()
        header.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(with: self, onNext: { controller, _ in
                controller.toggleSectionExpansion(at: section)
            })
            .disposed(by: disposeBag)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        Constants.Layout.tableCellSpacing
    }
    
    private func toggleSectionExpansion(at section: Int) {
        sections[section].isExpanded.toggle()
        
        if let header = transactionTableView.headerView(forSection: section) as? TransactionsHeaderView {
            header.updateUI(isExpanded: sections[section].isExpanded)
        }
        
        transactionTableView.performBatchUpdates {
            let indexPaths = sections[section].transactions.indices.map {
                IndexPath(row: $0, section: section)
            }
            
            if sections[section].isExpanded {
                transactionTableView.insertRows(at: indexPaths, with: .fade)
            } else {
                transactionTableView.deleteRows(at: indexPaths, with: .fade)
            }
        }
    }
}

// MARK: - Setup Methods
private extension MainViewController {
    func setupUI() {
        navigationItem.titleView = financeSegmentedControl
        
        addChild(circleDiagramView)
        [accountsCollection, circleDiagramView.view, periodLabel, periodSegmentedControl, transactionsBackgroundView].forEach { view.addSubview($0) }
        circleDiagramView.didMove(toParent: self)
        
        [dragHandleView, transactionTableView, noTransactionLabel].forEach { transactionsBackgroundView.addSubview($0) }
    }
    
    func setConstraints() {
        topConstraint = transactionsBackgroundView.topAnchor.constraint(
            equalTo: periodSegmentedControl.bottomAnchor,
            constant: Constants.Layout.defaultPadding
        )
        
        heightConstraint = transactionsBackgroundView.heightAnchor.constraint(
            equalToConstant: view.bounds.height * 0.4
        )
        
        NSLayoutConstraint.activate([
            topConstraint,
            heightConstraint,
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
            
            accountsCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.defaultPadding),
            accountsCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: Constants.Layout.defaultPadding),
            accountsCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -Constants.Layout.defaultPadding),
            accountsCollection.heightAnchor.constraint(equalToConstant: Constants.Layout.financeCardsCellHeight),
            
            circleDiagramView.view.topAnchor.constraint(equalTo: accountsCollection.bottomAnchor, constant: Constants.Layout.defaultVerticalPadding),
            circleDiagramView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.circleDiagramViewPadding),
            circleDiagramView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.circleDiagramViewPadding),
            
            periodLabel.topAnchor.constraint(equalTo: circleDiagramView.view.bottomAnchor, constant: Constants.Layout.defaultVerticalPadding),
            periodLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            periodSegmentedControl.topAnchor.constraint(equalTo: periodLabel.bottomAnchor, constant: Constants.Layout.defaultPadding),
            periodSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.defaultPadding),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.defaultPadding),
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
        animateView(expanded: true,
                    topAnchor: view.safeAreaLayoutGuide.topAnchor,
                    height: view.bounds.height - view.safeAreaInsets.top,
                    alphas: (0, 0, 0, 0))
    }
    
    func collapseView() {
        animateView(expanded: false,
                    topAnchor: periodSegmentedControl.bottomAnchor,
                    height: view.bounds.height * 0.4,
                    alphas: (1, 1, 1, 1))
    }
    
    func animateView(
        expanded: Bool,
        topAnchor: NSLayoutYAxisAnchor,
        height: CGFloat,
        alphas: (accounts: CGFloat, diagram: CGFloat, label: CGFloat, control: CGFloat)
    ) {
        isExpanded = expanded
        
        UIView.animate(
            withDuration: Constants.Animation.duration,
            delay: .zero,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.updateViewConstraints(
                    topAnchor: topAnchor,
                    height: height,
                    alphas: alphas
                )
            },
            completion: { _ in
                self.finalizeViewState(expanded: expanded)
            }
        )
    }
    
    func updateViewConstraints(
        topAnchor: NSLayoutYAxisAnchor,
        height: CGFloat,
        alphas: (accounts: CGFloat, diagram: CGFloat, label: CGFloat, control: CGFloat)
    ) {
        topConstraint.isActive = false
        topConstraint = transactionsBackgroundView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: Constants.Layout.defaultPadding
        )
        topConstraint.isActive = true
        
        heightConstraint.constant = height
        
        accountsCollection.alpha = alphas.accounts
        circleDiagramView.view.alpha = alphas.diagram
        periodLabel.alpha = alphas.label
        periodSegmentedControl.alpha = alphas.control
        
        view.layoutIfNeeded()
    }
    
    func finalizeViewState(expanded: Bool) {
        transactionTableView.isScrollEnabled = expanded
        if !expanded {
            transactionTableView.contentOffset = .zero
        }
    }
}

// MARK: - Button Actions
private extension MainViewController {
    func remindingNavBarButtonAction() {
        let notificationVC: NotificationViewController = .init()
        
        AppRouter.shared.push(notificationVC, animated: true)
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let defaultVerticalPadding: CGFloat = 20
        static let circleDiagramViewPadding: CGFloat = 10
        static let financeCardsCellHeight: CGFloat = 60
        static let financeCardsCellWidth: CGFloat = 160
        static let financeCardsCollectionSpacing: CGFloat = 8
        static let tableCellSpacing: CGFloat = 12
        static let dragHandleWidth: CGFloat = 40
        static let dragHandleHeight: CGFloat = 5
        static let dragHandlePadding: CGFloat = 10
        static let transactionsBackgroundCornerRadius: CGFloat = 22
        static let transactionsBackgroundShadowRadius: CGFloat = 6
        static let transactionsBackgroundShadowOpacity: Float = 0.4
        static let transactionsBackgroundShadowOffset = CGSize(width: 0, height: -4)
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.4
    }
    
    enum Text {
        static let fontSize: CGFloat = 16
    }
    
    enum SegmentedControl {
        static let financeItems = [
            String.Localized.Common.expenses.localized,
            String.Localized.Common.income.localized
        ]
        
        static let periodItems = [
            String.Localized.Period.day.localized,
            String.Localized.Period.week.localized,
            String.Localized.Period.month.localized,
            String.Localized.Common.period.localized
        ]
    }
}
