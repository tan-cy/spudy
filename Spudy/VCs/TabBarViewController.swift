//
//  TabBarViewController.swift
//  Spudy
//
//  Created by Lilly on 10/21/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    let homescreen = 2

    override func viewDidLoad() {
        super.viewDidLoad()
            
        // default on load, tab bar will show home screen!
        self.selectedIndex = homescreen
    }

}
