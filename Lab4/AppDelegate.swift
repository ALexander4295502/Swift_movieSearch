//
//  AppDelegate.swift
//  Lab4
//
//  Created by Alexander on 2017/2/15.
//  Copyright © 2017年 Zheng Yuan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    public var favoriteDbPathInDocument:String = String()
    public var commentDbPathInDocument:String = String()
    func prepareDbForUse(){
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        favoriteDbPathInDocument = rootPath.appending("/movieFavorites.db")
        if !FileManager.default.fileExists(atPath: favoriteDbPathInDocument){
            let dbPathInBundle:String = Bundle.main.path(forResource: "movieFavorites", ofType: "db")!
            do{
                try FileManager.default.copyItem(atPath: dbPathInBundle, toPath: favoriteDbPathInDocument)
            } catch let error as NSError{
                print("Error occurred while copying file to document \(error)")
            }
        }
        
        commentDbPathInDocument = rootPath.appending("/movieComment.db")
        if !FileManager.default.fileExists(atPath: commentDbPathInDocument){
            let dbPathInBundle:String = Bundle.main.path(forResource: "movieComment", ofType: "db")!
            do{
                try FileManager.default.copyItem(atPath: dbPathInBundle, toPath: commentDbPathInDocument)
            } catch let error as NSError{
                print("Error occurred while copying file to document \(error)")
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.prepareDbForUse()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.prepareDbForUse()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

