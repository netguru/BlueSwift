//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import CoreBluetooth

public extension Peripheral where Type == Advertisable {

    /// Creates a new instance of Peripheral that will be used for advertisement purposes.
    ///
    /// - Parameters:
    ///   - configuration: a specification of the peripheral that you are willing to advertise wrapped in Configuration object instance.
    ///   - advertisementData: a data that should be put in Bluetooth LE advertisement header. Please note that iPhones don't allow some keys there, so they won't be advertised even if set properly.
    public convenience init(configuration: Configuration, advertisementData: [AdvertisementData]) {
        self.init(configuration: configuration, deviceIdentifier: nil, advertisementData: advertisementData)
    }
}
