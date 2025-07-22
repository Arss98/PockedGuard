//
//  ProfileCoordinator.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 20.07.2025.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController? = .init()
    
    func start() {
        showProfileScreen()
    }
}

// MARK: - Private methods
private extension ProfileCoordinator {
    func showProfileScreen() {
        let viewModel: ProfileViewModelProtocol = ProfileViewModel()
        let viewController: ProfileViewController = .init(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
