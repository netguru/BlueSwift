//
//  Copyright © 2018 Netguru Sp. z o.o. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum AdvertisementData {
    
    case name(String)
    
    internal var data: [String: Any] {
        return [:]
    }
}
