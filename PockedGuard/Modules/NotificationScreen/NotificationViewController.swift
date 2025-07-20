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
    private lazy var collectionLayout: UICollectionViewCompositionalLayout = .init { _, _ in
        let itemSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Constants.estimatedCellHeight))
        
        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
        let groupSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(Constants.estimatedCellHeight))
        
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: .zero, leading: Constants.defaultPadding, bottom: .zero, trailing: Constants.defaultPadding)
        let section: NSCollectionLayoutSection = .init(group: group)
        section.interGroupSpacing = Constants.minimumLineSpacing
        
        return section
    }
    
    private lazy var notificationCollectionView: UICollectionView = {
        let collection: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.rx.setDelegate(self).disposed(by: disposeBag)
        collection.contentInset.top = Constants.collectionViewTopInset
        collection.register(NotificationViewCell.self, forCellWithReuseIdentifier: String(describing: NotificationViewCell.self))
        
        return collection
    }()
    
    private lazy var isEmptyLabel: UILabel = {
        let label: UILabel = .init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = .zero
        label.isHidden = true
        label.text = .Localized.Notification.emptyLabel.localized
        label.numberOfLines = Constants.numberOfLines
        
        return label
    }()
    
    private lazy var createNotificationButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(.Localized.Notification.createTitle.localized, for: .normal)
        button.backgroundColor = .appMainBlue
        button.tintColor = .white
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: NotificationViewModelProtocol
    
    // MARK: - Init
    init(viewModel: NotificationViewModelProtocol = NotificationViewModel()) {
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
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchNotifications()
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.isHiddenTabBar = true
    }
}

// MARK: - UICollectionViewDelegate
extension NotificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: .Localized.Common.delete.localized)
        { [weak self] _, _, completion in
            guard let self else { return }
            self.viewModel.deleteNotification(at: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
                guard let self, let notification = self.viewModel.getNotification(at: indexPath) else { return }
                self.viewModel.selectedNotification.onNext(notification)
            }
        
        let deleteAction: UIAction = .init(
            title: .Localized.Common.delete.localized,
            image: UIImage(systemName: "trash"),
            attributes: .destructive) { [weak self] _ in
                self?.viewModel.deleteNotification(at: indexPath)
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
    
    func setupBinding() {
        viewModel.state
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { controller, state in
                switch state {
                case .loading:
                    controller.showActivityIndicator()
                case .loaded:
                    controller.showActivityIndicator(false)
                case .error(let error):
                    controller.showErrorAlert(message: error)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.notifications
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] notificationList in
                notificationList.isEmpty ? self?.showEmptyLabel(isShow: true) : self?.showEmptyLabel(isShow: false)
            })
            .disposed(by: disposeBag)
        
        viewModel.notifications
            .asDriver(onErrorJustReturn: [])
            .drive(notificationCollectionView.rx.items) { [weak self] collectionView, row, model in
                guard let self, let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: NotificationViewCell.self),
                    for: IndexPath(row: row, section: .zero)) as? NotificationViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(title: model.title, description: model.notes, isActive: model.isActive) { [weak self] isOn in
                    self?.viewModel.updateNotificationIsActive(id: model.id, isActive: isOn)
                }
                return cell
            }
            .disposed(by: disposeBag)
        
        notificationCollectionView.rx.modelSelected(NotificationDomainModel.self)
            .bind(to: viewModel.selectedNotification)
            .disposed(by: disposeBag)
        
        createNotificationButton.rx.tap
            .bind(to: viewModel.createNotificationTapped)
            .disposed(by: disposeBag)
    }
    
    func showEmptyLabel(isShow: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
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
            isEmptyLabel.widthAnchor.constraint(equalToConstant: Constants.widthEmtpyLabel),
            
            createNotificationButton.topAnchor.constraint(equalTo: notificationCollectionView.bottomAnchor,
                                                          constant: Constants.defaultPadding),
            createNotificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                              constant: Constants.defaultPadding),
            createNotificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                               constant: -Constants.defaultPadding),
            createNotificationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                             constant: -Constants.defaultPadding),
            createNotificationButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}

// MARK: - Constants
private enum Constants {
    static let defaultPadding: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 10
    static let buttonHeight: CGFloat = 52
    static let minimumLineSpacing: CGFloat = 12
    static let estimatedCellHeight: CGFloat = 62
    static let collectionViewTopInset: CGFloat = 12
    static let fontSize: CGFloat = 16
    static let animationDuration: TimeInterval = 0.3
    static let numberOfLines: Int = 3
    static let widthEmtpyLabel: CGFloat = 320
}
