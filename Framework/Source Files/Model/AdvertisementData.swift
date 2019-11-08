//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

/// An enum used to specify advertising parameters of a peripheral.
public enum AdvertisementData {
    
    case localName(String)
    case servicesUUIDs(String)
    case serviceData(Data)
    case txPower(Int)
    case manufacturersData(String)
    case custom(String, Any)
}

internal extension AdvertisementData {
    
    var data: Any? {
        switch self {
        case .localName(let name):
            return name
        case .servicesUUIDs(let uuid):
            return try? [CBUUID(uuidString: uuid)]
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
    
    var key: String {
        switch self {
        case .localName(_):
            return CBAdvertisementDataLocalNameKey
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
