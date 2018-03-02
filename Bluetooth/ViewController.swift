//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class ViewController: UIViewController {
    
    let connection = BluetoothConnection()
    let advertisement = BluetoothAdvertisement()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func connect() {
        let characteristic = try! Characteristic(uuid: "58D48B4E-4F41-4E6A-8C4E-23B1B54452A9")
        let service = try! Service(uuid: "58D48B4E-4F40-4E6A-8C4E-23B1B54452A9", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "58D48B4E-4F40-4E6A-8C4E-23B1B54452A9")
        
        let peripheral = Peripheral(configuration: configuration)
        
        connection.connect(peripheral) { _ in
            print("Connected")
        }
    }
    
    func advertise() {
        let characteristic = try! Characteristic(uuid: "58D48B4E-4F41-4E6A-8C4E-23B1B54452A9")
        let service = try! Service(uuid: "58D48B4E-4F40-4E6A-8C4E-23B1B54452A9", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "58D48B4E-4F40-4E6A-8C4E-23B1B54452A9")
        
        let peripheral = Peripheral(configuration: configuration, advertisementData: [.connectable(true), .localName("Test"), .servicesUUIDs("58D48B4E-4F40-4E6A-8C4E-23B1B54452A9")])
        
        advertisement.advertise(peripheral: peripheral) { _ in
            print("Error during adverisement")
        }
    }
}

