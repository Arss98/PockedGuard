//
//  ProfilePresenter.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

protocol ProfileViewProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol { get }
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
}
