//
//  UINavigationController.swift
//  HelpCambio
//
//  Created by André Alves on 24/11/18.
//  Copyright © 2018 André Alves. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
}

extension BaseNavigationController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    navigationController.navigationBar.tintColor = .white
    let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    viewController.navigationItem.backBarButtonItem = item
  }
}
