//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class ConnectionViewController: UIViewController {
    
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    private var loading = false {
        didSet {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItem = loading ? UIBarButtonItem(customView: activityIndicator) : nil
            title = loading ? "Connecting" : "Connected"
        }
    }
    
    let connection = BluetoothConnection.shared
    let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4E43-2E205555726F", shouldObserveNotification: true)
    let otherCharacteristic = try! Characteristic(uuid: "00001003-4554-2049-4E43-2E205555726F", shouldObserveNotification: true)
    var peripheral: Peripheral<Connectable>?
    
    @IBAction func connect() {
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic, otherCharacteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4E43-2E205555726F")
        peripheral = Peripheral(configuration: configuration)
        loading = true
        connection.connect(peripheral!) { [weak self] _ in
            self?.loading = false
            print("Connected")
        }
        handleNotifications()
    }
    
    func handleNotifications() {
        characteristic.notifyHandler = { [weak self] data in
            guard
                let data = data,
                let encoded = String(data: data, encoding: .utf8)
            else {
                return
            }
            self?.notifyLabel.text = "Notify result: \(encoded)"
        }
    }
    
    @IBAction func write() {
        let command = Command.utf8String(textField.text!)
        peripheral?.write(command: command, characteristic: otherCharacteristic, handler: { error in
            print("Did write")
        })
    }
    
    @IBAction func read() {
        peripheral?.read(characteristic, handler: { [weak self] data, error in
            guard
                let data = data,
                let encoded = String(data: data, encoding: .utf8)
            else {
                return
            }
            self?.readLabel.text = "Read result: \(encoded)"
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let peripheral = peripheral else { return }
        try? connection.disconnect(peripheral)
    }
    
    @IBAction func hideKeyboard() {
        view.endEditing(true)
    }
}
