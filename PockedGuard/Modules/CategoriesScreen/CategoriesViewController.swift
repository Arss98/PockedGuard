//
//  CategoriesViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import UIKit

final class CategoriesViewController: BaseViewController {
    let presenter: CategoriesPresenterProtocol
    
    init(presenter: CategoriesPresenterProtocol) {
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

// MARK: - CategoriesViewProtocol
extension CategoriesViewController: CategoriesViewProtocol {
    
}
