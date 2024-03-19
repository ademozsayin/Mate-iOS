////
////  SceneDelegate.swift
////  WeatherApp
////
////  Created by Adem Özsayın on 26.02.2024.
////
//
//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(
//        _ scene: UIScene,
//        willConnectTo session: UISceneSession,
//        options connectionOptions: UIScene.ConnectionOptions
//    ) {
//   
//        guard let scene = (scene as? UIWindowScene) else { return }
//        let window = UIWindow(windowScene: scene)
//        let splashModule = SplashRouter.createModule()
//        window.makeKeyAndVisible()
//        window.rootViewController = splashModule
//        self.window = window
//    }
//
//    func sceneDidDisconnect(_ scene: UIScene) {}
//
//    func sceneDidBecomeActive(_ scene: UIScene) {}
//
//    func sceneWillResignActive(_ scene: UIScene) {}
//
//    func sceneWillEnterForeground(_ scene: UIScene) {}
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
//    }
//}
//
