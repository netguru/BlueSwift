//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

public enum AdvertisementData {
    
    case localName(String)
    case connectable(Bool)
    case servicesUUIDs(String)
    case serviceData(Data)
    case txPower(Int)
    case manufacturersData(String)
    case custom(String, Any)
    
    internal var data: Any {
        switch self {
        case .localName(let name):
            return name
        case .connectable(let connectable):
            return connectable
        case .servicesUUIDs(let uuid):
            return try! CBUUID(uuidString: uuid)
        case .serviceData(let data):
            return data
        case .txPower(let level):
            return level
        case .manufacturersData(let data):
            return data
        case .custom(_, let data):
            return data
        }
    }
    
    internal var key: String {
        switch self {
        case .localName(_):
            return CBAdvertisementDataLocalNameKey
        case .connectable(_):
            return CBAdvertisementDataIsConnectable
        case .servicesUUIDs(_):
            return CBAdvertisementDataServiceUUIDsKey
        case .serviceData(_):
            return CBAdvertisementDataServiceDataKey
        case .txPower(_):
            return CBAdvertisementDataTxPowerLevelKey
        case .manufacturersData(_):
            return CBAdvertisementDataManufacturerDataKey
        case .custom(let key, _):
            return key
        }
    }
}
