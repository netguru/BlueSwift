//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class AdvertisementViewController: UIViewController {

    let advertisement = BluetoothAdvertisement.shared
    let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4e43-2e205555726f")
    
    private lazy var advertiseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start advertising", for: .normal)
        button.addTarget(self, action: #selector(advertise), for: .touchUpInside)
        return button
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Update data", for: .normal)
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        return button
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .bezel
        return textField
    }()
    
    private lazy var textView = UITextView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textField, updateButton, advertiseButton, textView])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textColor = UIColor.black
        view.backgroundColor = UIColor.white
        view.addSubview(stackView)
        let constraints = [stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                           stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           textView.heightAnchor.constraint(equalToConstant: 300),
                           textView.widthAnchor.constraint(equalToConstant: 300)]
        NSLayoutConstraint.activate(constraints)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        advertisement.stopAdvertising()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func advertise() {
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4e43-2e205555726f")
        
        let peripheral = Peripheral(configuration: configuration, advertisementData: [.localName("Test"), .servicesUUIDs("00001001-4554-2049-4e43-2e205555726f")])
        
        advertisement.advertise(peripheral: peripheral) { _ in
            print("Error during adverisement")
        }
        
        advertisement.writeRequestCallback = { [weak self] characteristic, data in
            guard var text = self?.textView.text, let data = data else { return }
            text = text + "\nWrote: " + (String(data: data, encoding: .utf8) ?? "(Error encoding.)")
            self?.textView.text = text
        }
        
        advertisement.readRequestCallback = { [weak self] characteristic -> Data in
            guard var text = self?.textView.text else { return Data() }
            text = text + "\nReceived read request."
            self?.textView.text = text
            return "Hello world".data(using: .utf8, allowLossyConversion: false)!
        }
    }
    
    @objc func update() {
        let command = Command.utf8String("Hello world")
        advertisement.update(command, characteristic: characteristic) { error in
            print("Updated")
        }
    }
}
