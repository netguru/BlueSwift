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
}

extension ViewController {
    
    func connect() {
        let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4E43-2E205555726F")
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4E43-2E205555726F")
        
        let peripheral = Peripheral(configuration: configuration)
        
        connection.connect(peripheral) { _ in
            print("Connected")
        }
    }
    
    func advertise() {
        let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4e43-2e205555726f")
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4e43-2e205555726f")
        
        let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("00001001-4554-2049-4e43-2e205555726f")])
        
        advertisement.advertise(peripheral: peripheral) { _ in
            print("Error during adverisement")
        }
    }
}

