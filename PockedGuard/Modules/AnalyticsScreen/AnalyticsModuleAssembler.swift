//
//  AnalyticsModuleAssembler.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

final class AnalyticsModuleAssembler {
    static func assemble() -> AnalyticsViewController {
        let presenter: AnalyticsPresenterProtocol = AnalyticsPresenter()
        let view: AnalyticsViewController = .init(presenter: presenter)
        
        presenter.view = view
        
        return view
    }
}
