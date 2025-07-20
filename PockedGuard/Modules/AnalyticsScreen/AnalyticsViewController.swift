//
//  AnalyticsViewController.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import UIKit

final class AnalyticsViewController: BaseViewController {
    let presenter: AnalyticsPresenterProtocol
    
    init(presenter: AnalyticsPresenterProtocol) {
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

// MARK: - AnalyticsViewProtocol
extension AnalyticsViewController: AnalyticsViewProtocol {
    
}
