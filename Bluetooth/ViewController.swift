//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var stackView: UIStackView = {
        let connectionButton = UIButton(type: .custom)
        connectionButton.setTitleColor(UIColor.black, for: .normal)
        connectionButton.setTitle("Connect", for: .normal)
        connectionButton.addTarget(self, action: #selector(presentConnection), for: .touchUpInside)
        let advertisementButton = UIButton(type: .custom)
        advertisementButton.setTitleColor(UIColor.black, for: .normal)
        advertisementButton.setTitle("Advertise", for: .normal)
        advertisementButton.addTarget(self, action: #selector(presentAdvertisement), for: .touchUpInside)
        let stackView = UIStackView(arrangedSubviews: [connectionButton, advertisementButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 50
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(stackView)
        let constraints = [stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                           stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func presentAdvertisement() {
        let viewController = AdvertisementViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func presentConnection() {
        let viewController = ConnectionViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
