//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation

extension QuickStorage {

    final class UserDefaultsImpl: Interface {

        init(userDefaults: Foundation.UserDefaults) {

            self.userDefaults = userDefaults
        }

        func read<Value>(forKey key: String) -> Value? where Value : Decodable{

            guard let data = userDefaults.data(forKey: key) else {
                return nil
            }

            do {
                let value = try decoder.decode(Value.self, from: data)
                return value
            } catch {
                debugPrint("💥 Can't retrieve value for key='\(key)'. Error='\(error)'.")
                return nil
            }
        }

        func write<Value>(value: Value, forKey key: String) where Value : Encodable {

            do {
                let data = try encoder.encode(value)
                userDefaults.set(data, forKey: key)
            } catch {
                debugPrint("💥 Can't retrieve value for key='\(key)'. Error='\(error)'.")
            }
        }

        func delete(key: String) {

            userDefaults.removeObject(forKey: key)
        }

        // MARK: - Private

        private let userDefaults: Foundation.UserDefaults

        private let decoder = JSONDecoder()
        private let encoder = JSONEncoder()
    }
}
