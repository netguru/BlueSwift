//
//  ViewController.swift
//  Bluetooth
//
//  Created by Jan Posz on 05.01.2018.
//  Copyright © 2018 Netguru. All rights reserved.
//

import UIKit
import Bluetooth
import CoreBluetooth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let a = Peripheral(configuration: Configuration(services: []))
        
    }
}

