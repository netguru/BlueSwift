//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import BlueSwift

class ConnectionViewController: UIViewController {

    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    private var loadingState: LoadingState = .connected {
        didSet {
            let activityIndicator: UIActivityIndicatorView
            if #available(iOS 13, *) {
                activityIndicator = UIActivityIndicatorView(style: .medium)
            } else {
                activityIndicator = UIActivityIndicatorView(style: .gray)
            }
            activityIndicator.startAnimating()

            switch self.loadingState {
            case .loading:
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
                title = "Connecting"
            case .connected:
                navigationItem.rightBarButtonItem = nil
                title = "Connected"
            case .error(_):
                navigationItem.rightBarButtonItem = nil
                title = "Connection error"
            }
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
        loadingState = .loading
        connection.connect(peripheral) { [weak self] error in
            if let error = error {
                self?.loadingState = .error(error)
                self?.title = "Connection failure"
                return
            } else {
                self?.title = "Connected"
                self?.loadingState = .connected
            }
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
        peripheral.write(command: command, characteristic: otherCharacteristic) { error in
            print("Did write")
        }
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
        connection.disconnect(peripheral)
    }
    
    @IBAction func hideKeyboard() {
        view.endEditing(true)
    }
}

internal extension ConnectionViewController {

    /// Enum representing current state of connecting to the peripheral.
    enum LoadingState {
        case loading
        case connected
        case error(Error)
    }
}
