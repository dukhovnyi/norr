//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Foundation

enum QuickStorage {

    typealias Interface = _QuickStorageInterface
}

protocol _QuickStorageInterface {

    func read<Value: Decodable>(forKey key: String) -> Value?

    func write<Value: Encodable>(value: Value, forKey key: String)

    func delete(key: String)
}
