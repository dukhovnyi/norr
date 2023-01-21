//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation

extension QuickStorage {

    final class Mock: Interface {
        
        var mock = [String: [Codable]]()

        func read<Value>(forKey key: String) -> Value? where Value : Decodable {
            mock[key] as? Value
        }

        func write<Value>(
            value: Value,
            forKey key: String
        ) where Value : Encodable {

            var current = mock[key] ?? []
            current.append(value as! Codable)
            mock[key] = current
        }

        func delete(key: String) {
            mock[key] = nil
        }
    }

}
