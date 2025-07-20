//
//  ProfileViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import UIKit

class ProfileViewController: BaseViewController {
    var presenter: ProfilePresenterProtocol
    
    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - ProfileViewProtocol
extension ProfileViewController: ProfileViewProtocol {
}
