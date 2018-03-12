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
    lazy var characteristic = try! Characteristic(uuid: "1104FD87-820F-438A-B757-7AC2C15C2D56")
    lazy var otherCharacteristic = try! Characteristic(uuid: "1204FD87-820F-438A-B757-7AC2C15C2D56")
    lazy var service = try! Service(uuid: "1004FD87-820F-438A-B757-7AC2C15C2D56", characteristics: [characteristic, otherCharacteristic])
    lazy var peripheral: Peripheral<Advertisable> = {
        let configuration = try! Configuration(services: [service], advertisement: "1004FD87-820F-438A-B757-7AC2C15C2D56")
        return Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("1004FD87-820F-438A-B757-7AC2C15C2D56")])
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
