//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class AdvertisementViewController: UIViewController {
    
    @IBOutlet weak var notifyTextField: UITextField!
    @IBOutlet weak var readTextField: UITextField!
    @IBOutlet weak var textView: UITextView!

    let advertisement = BluetoothAdvertisement.shared
    lazy var characteristic = try! Characteristic(uuid: "00001002-4554-2049-4e43-2e205555726f")
    lazy var otherCharacteristic = try! Characteristic(uuid: "00001003-4554-2049-4e43-2e205555726f")
    lazy var service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic, otherCharacteristic])
    lazy var peripheral: Peripheral<Advertisable> = {
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4e43-2e205555726f")
        return Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("00001001-4554-2049-4e43-2e205555726f")])
    }()
    
    @IBAction func advertise() {
        advertisement.advertise(peripheral: peripheral) { _ in
            print("Error during adverisement")
        }
        handleRequests()
    }
    
    @IBAction func update() {
        let command = Command.utf8String(notifyTextField.text!)
        advertisement.update(command, characteristic: characteristic) { error in
            print("Notified on central.")
        }
    }
    
    func handleRequests() {
        advertisement.writeRequestCallback = { [weak self] characteristic, data in
            guard
                var text = self?.textView.text,
                let data = data,
                let encoded = String(data: data, encoding: .utf8)
            else {
                return
            }
            text = text + "\nWrote: \(encoded). Characteristic: \(characteristic.uuid)"
            self?.textView.text = text
        }
        
        advertisement.readRequestCallback = { [weak self] characteristic -> Data in
            guard
                var text = self?.textView.text,
                let notifyValue = self?.readTextField.text
            else {
                return Data()
            }
            text = text + "\nReceived read request. Characteristic: \(characteristic.uuid)"
            self?.textView.text = text
            return notifyValue.data(using: .utf8, allowLossyConversion: false)!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        advertisement.stopAdvertising()
    }
    
    @IBAction func hideKeyboard() {
        view.endEditing(true)
    }
}
