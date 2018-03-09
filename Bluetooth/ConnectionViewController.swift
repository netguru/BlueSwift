//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class ConnectionViewController: UIViewController {
    
    let connection = BluetoothConnection.shared
    let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4E43-2E205555726F", shouldObserveNotification: true)
    let otherCharacteristic = try! Characteristic(uuid: "00001003-4554-2049-4E43-2E205555726F", shouldObserveNotification: true)
    var peripheral: Peripheral<Connectable>?
    
    private var loading = false {
        didSet {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItem = loading ? UIBarButtonItem(customView: activityIndicator) : nil
            title = loading ? "Connecting" : "Connected"
        }
    }

    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Start connection", for: .normal)
        button.addTarget(self, action: #selector(connect), for: .touchUpInside)
        return button
    }()
    
    private lazy var writeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Write data", for: .normal)
        button.addTarget(self, action: #selector(write), for: .touchUpInside)
        return button
    }()
    
    private lazy var readButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Read data", for: .normal)
        button.addTarget(self, action: #selector(read), for: .touchUpInside)
        return button
    }()
    
    private lazy var notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "Notification text will appear here"
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .bezel
        return textField
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [connectButton, textField, writeButton, readButton, notifyLabel])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(stackView)
        let constraints = [stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                           stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        NSLayoutConstraint.activate(constraints)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let peripheral = peripheral else { return }
        try? connection.disconnect(peripheral)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func connect() {
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic, otherCharacteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4E43-2E205555726F")
        peripheral = Peripheral(configuration: configuration)
        loading = true
        connection.connect(peripheral!) { [weak self] _ in
            self?.loading = false
            print("Connected")
        }
        characteristic.notifyHandler = { [weak self] data in
            guard let data = data else { return }
            self?.notifyLabel.text = String(data: data, encoding: .utf8)
        }
    }
    
    @objc func write() {
        guard let text = textField.text, text.count > 0 else { return }
        let command = Command.utf8String(text)
        peripheral?.write(command: command, characteristic: otherCharacteristic, handler: { error in
            print("Did write")
        })
    }
    
    @objc func read() {
        peripheral?.read(characteristic, handler: { data, error in
            print("Did read")
        })
    }
}
