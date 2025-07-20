//
//  DataUpdateService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 19.07.2025.
//

import RxSwift

final class DataUpdateService {
    static let shared = DataUpdateService()
    private init() {}
    
    let modalDismissedSubject = PublishSubject<Void>()
    
    func notifyModalDismissed() {
        modalDismissedSubject.onNext(())
    }
}
