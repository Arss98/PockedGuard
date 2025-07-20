//
//  CategoriesPresenter.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

protocol CategoriesViewProtocol: AnyObject {
    var presenter: CategoriesPresenterProtocol { get }
}

protocol CategoriesPresenterProtocol: AnyObject {
    var view: CategoriesViewProtocol? { get set }
}

final class CategoriesPresenter: CategoriesPresenterProtocol {
    weak var view: CategoriesViewProtocol?
}
