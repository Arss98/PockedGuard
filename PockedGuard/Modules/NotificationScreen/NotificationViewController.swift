//
//  NotificationViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 25.06.2025.
//

import RxSwift
import RxCocoa

final class NotificationViewController: BaseViewController {
    // MARK: - UI Elements
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, NotificationDomainModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, NotificationDomainModel>
    private var dataSource: DataSource?
    
    private lazy var collectionLayout: UICollectionViewCompositionalLayout = .init { _, _ in
        let itemSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Constants.Layout.estimatedCellHeight))
        
        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
        let groupSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Constants.Layout.estimatedCellHeight))
        
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: .zero, leading: Constants.Layout.padding, bottom: .zero, trailing: Constants.Layout.padding)
        let section: NSCollectionLayoutSection = .init(group: group)
        section.interGroupSpacing = Constants.Layout.minimumLineSpacing
        
        return section
    }
    
    private lazy var notificationCollectionView: UICollectionView = {
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.rx.setDelegate(self).disposed(by: disposeBag)
        collection.contentInset.top = Constants.Layout.collectionViewTopInset
        collection.register(NotificationViewCell.self, forCellWithReuseIdentifier: String(describing: NotificationViewCell.self))
        
        return collection
    }()
    
    private lazy var isEmptyLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.Text.fontSize, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = .zero
        label.isHidden = true
        label.text = .Localized.Notification.emptyLabel.localized
        label.numberOfLines = Constants.Text.numberOfLines
        
        return label
    }()
    
    private lazy var createNotificationButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.Localized.Notification.createTitle.localized, for: .normal)
        button.backgroundColor = .appMainBlue
        button.tintColor = .white
        button.layer.cornerRadius = Constants.Layout.buttonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: NotificationViewModelProtocol
    
    // MARK: - Init
    init(viewModel: NotificationViewModelProtocol) {
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
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.isHiddenTabBar = true
    }
}

// MARK: - UICollectionViewDelegate
extension NotificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let notification: NotificationDomainModel = self.viewModel.getNotification(at: indexPath) else {
            return
        }
        
        viewModel.input.selectedNotification.onNext(notification)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider:  { [weak self] _ in
            self?.makeContextMenuAction(for: indexPath)
        })
    }
    
    func makeContextMenuAction(for indexPath: IndexPath) -> UIMenu {
        let editAction: UIAction = .init(
            title: .Localized.Common.edit.localized,
            image: UIImage(systemName: "pencil")) { [weak self] _ in
                guard let self,
                      let notification: NotificationDomainModel = self.viewModel.getNotification(at: indexPath) else {
                    return
                }
                self.viewModel.input.selectedNotification.onNext(notification)
            }
        
        let deleteAction: UIAction = .init(
            title: .Localized.Common.delete.localized,
            image: UIImage(systemName: "trash"),
            attributes: .destructive) { [weak self] _ in
                self?.viewModel.input.deleteNotification.onNext(indexPath)
            }
        
        return UIMenu(children: [editAction, deleteAction])
    }
}

// MARK: - Private methods
private extension NotificationViewController {
    func setupUI() {
        title = .Localized.Notification.title.localized
        [notificationCollectionView, createNotificationButton].forEach { view.addSubview($0) }
        notificationCollectionView.addSubview(isEmptyLabel)
    }
    
    func setupDataSource() {
        dataSource = DataSource(collectionView: notificationCollectionView)
        { [weak self] collectionView, indexPath, notification in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: NotificationViewCell.self),
                for: indexPath) as? NotificationViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(title: notification.title, description: notification.notes, isActive: notification.isActive) { [weak self] isOn in
                self?.viewModel.updateNotificationIsActive(id: notification.id, isActive: isOn)
            }
            
            return cell
        }
    }
    
    func applySnapshot(notifications: [NotificationDomainModel]) {
        guard let dataSource else { return }
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(notifications)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func setupBinding() {
        viewModel.output.state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { controller, state in
                switch state {
                case .loading:
                    controller.showActivityIndicator()
                case .loaded:
                    controller.showActivityIndicator(false)
                case .error(let error):
                    controller.showErrorAlert(message: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.notifications
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { controller, notifications in
                controller.applySnapshot(notifications: notifications)
                controller.showEmptyLabel(isShow: notifications.isEmpty)
            }
            .disposed(by: disposeBag)
        
        createNotificationButton.rx.tap
            .bind(to: viewModel.input.createNotificationTapped)
            .disposed(by: disposeBag)
    }
    
    func showEmptyLabel(isShow: Bool) {
        UIView.animate(withDuration: Constants.Animation.duration) {
            self.isEmptyLabel.alpha = isShow ? 1 : 0
            self.isEmptyLabel.isHidden = !isShow
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            notificationCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            notificationCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            isEmptyLabel.centerYAnchor.constraint(equalTo: notificationCollectionView.centerYAnchor),
            isEmptyLabel.centerXAnchor.constraint(equalTo: notificationCollectionView.centerXAnchor),
            isEmptyLabel.widthAnchor.constraint(equalToConstant: Constants.Layout.widthEmtpyLabel),
            
            createNotificationButton.topAnchor.constraint(equalTo: notificationCollectionView.bottomAnchor,
                                                          constant: Constants.Layout.padding),
            createNotificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                              constant: Constants.Layout.padding),
            createNotificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                               constant: -Constants.Layout.padding),
            createNotificationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                             constant: -Constants.Layout.padding),
            createNotificationButton.heightAnchor.constraint(equalToConstant: Constants.Layout.buttonHeight)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let padding: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 52
        static let minimumLineSpacing: CGFloat = 12
        static let estimatedCellHeight: CGFloat = 62
        static let collectionViewTopInset: CGFloat = 12
        static let widthEmtpyLabel: CGFloat = 320
    }
    
    enum Text {
        static let fontSize: CGFloat = 16
        static let numberOfLines: Int = 3
    }
    
    enum Animation {
        static let duration: TimeInterval = 0.3
    }
}
