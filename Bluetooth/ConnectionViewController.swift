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
    lazy var characteristic = try! Characteristic(uuid: "1104FD87-820F-438A-B757-7AC2C15C2D56", shouldObserveNotification: true)
    lazy var otherCharacteristic = try! Characteristic(uuid: "1204FD87-820F-438A-B757-7AC2C15C2D56", shouldObserveNotification: true)
    lazy var service = try! Service(uuid: "1004FD87-820F-438A-B757-7AC2C15C2D56", characteristics: [characteristic, otherCharacteristic])
    lazy var peripheral: Peripheral<Connectable> = {
        let configuration = try! Configuration(services: [service], advertisement: "1004FD87-820F-438A-B757-7AC2C15C2D56")
        return Peripheral(configuration: configuration)
    }()
    
    @IBAction func connect() {
        loading = true
        connection.connect(peripheral) { [weak self] _ in
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
        peripheral.write(command: command, characteristic: otherCharacteristic, handler: { error in
            print("Did write")
        })
    }
    
    @IBAction func read() {
        peripheral.read(characteristic, handler: { [weak self] data, error in
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
        try? connection.disconnect(peripheral)
    }
    
    @IBAction func hideKeyboard() {
        view.endEditing(true)
    }
}
