//
//  CategoriesModuleAssembler.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

final class CategoriesModuleAssembler {
    static func assemble() -> CategoriesViewController {
        let presenter: CategoriesPresenterProtocol = CategoriesPresenter()
        let view: CategoriesViewController = .init(presenter: presenter)
        
        presenter.view = view
        
        return view
    }
}
