//
//  ProfileModuleAssembler.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

final class ProfileModuleAssembler {
    static func assemble() -> ProfileViewController {
        let presenter: ProfilePresenterProtocol = ProfilePresenter()
        let view: ProfileViewController = .init(presenter: presenter)
        
        presenter.view = view
        
        return view
    }
}

