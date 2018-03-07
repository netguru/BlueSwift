//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class AdvertisementViewController: UIViewController {

    let advertisement = BluetoothAdvertisement.shared
    
    private lazy var advertiseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start advertising", for: .normal)
        button.addTarget(self, action: #selector(advertise), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(advertiseButton)
        let constraints = [advertiseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                           advertiseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func advertise() {
        let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4e43-2e205555726f")
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4e43-2e205555726f")
        
        let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("00001001-4554-2049-4e43-2e205555726f")])
        
        advertisement.advertise(peripheral: peripheral) { _ in
            print("Error during adverisement")
        }
        
        advertisement.writeRequestCallback = { characteristic, data in
            print("Tried to write data")
        }
        
        advertisement.readRequestCallback = { characteristic -> Data in
            print("Tried to read data")
            return Data()
        }
    }
}
