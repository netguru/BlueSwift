//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

internal class ConnectionService: NSObject {
    
    private lazy var centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    
    
}

extension ConnectionService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //TODO: handle bluetooth state
    }
}
