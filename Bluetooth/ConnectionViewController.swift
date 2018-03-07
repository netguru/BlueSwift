//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Bluetooth

class ConnectionViewController: UIViewController {
    
    let connection = BluetoothConnection.shared
    let characteristic = try! Characteristic(uuid: "00001002-4554-2049-4E43-2E205555726F")
    var peripheral: Peripheral<Connectable>?

    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start connection", for: .normal)
        button.addTarget(self, action: #selector(connect), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(connectButton)
        let constraints = [connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                           connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func connect() {
        let service = try! Service(uuid: "00001001-4554-2049-4e43-2e205555726f", characteristics: [characteristic])
        let configuration = try! Configuration(services: [service], advertisement: "00001001-4554-2049-4E43-2E205555726F")
        peripheral = Peripheral(configuration: configuration)
        connection.connect(peripheral!) { [weak self] _ in
            print("Connected")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
                self?.testRead()
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
                self?.testWrite()
            })
        }
    }
    
    func testWrite() {
        let command = Command.int8(3)
        peripheral?.write(command: command, characteristic: characteristic, handler: { error in
            print("Did write")
        })
    }
    
    func testRead() {
        peripheral?.read(characteristic, handler: { data, error in
            print("Did read")
        })
    }
}
