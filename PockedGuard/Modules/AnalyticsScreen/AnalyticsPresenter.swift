//
//  AnalyticsPresenter.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

protocol AnalyticsViewProtocol: AnyObject {
    var presenter: AnalyticsPresenterProtocol { get }
}

protocol AnalyticsPresenterProtocol: AnyObject {
    var view: AnalyticsViewProtocol? { get set }
}

final class AnalyticsPresenter: AnalyticsPresenterProtocol {
    weak var view: AnalyticsViewProtocol?
}
