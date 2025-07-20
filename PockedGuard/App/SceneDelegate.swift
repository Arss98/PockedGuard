//
//  SceneDelegate.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 08.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let viewController: UIViewController = TabBarController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

