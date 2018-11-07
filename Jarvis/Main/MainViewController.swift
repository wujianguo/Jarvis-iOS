//
//  MainViewController.swift
//  Jarvis
//
//  Created by Jianguo Wu on 2018/10/8.
//  Copyright © 2018年 wujianguo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func createTab(vc: UIViewController, name: String, image: UIImage?, tag: Int) -> UINavigationController {
        let navigationController = BaseNavigationController(rootViewController: vc)
        navigationController.tabBarItem.title = name
        navigationController.tabBarItem.image = image
        return navigationController;
    }
    
    func createTab(vc: UIViewController, item: UITabBarItem.SystemItem, tag: Int) -> UINavigationController {
        let navigationController = BaseNavigationController(rootViewController: vc)
        navigationController.tabBarItem = UITabBarItem(tabBarSystemItem: item, tag: tag)
        return navigationController;
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
