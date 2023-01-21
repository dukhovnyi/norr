//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import Combine
import Foundation

protocol _PasteboardManagingInterface {

    /// Publishes current value of pasteboard instance.
    var value: AnyPublisher<Paste, Never> { get }

    /// Starts observing pasteboard and emits current value
    ///  into `value` publisher.
    func start()

    /// Stops observing pasteboard and sends proper state
    ///  about this change to `state` publisher.
    func stop()

    /// Sets current pasteboard value to passed into function.
    func setPasteboardItem(to newValue: Paste)

    /// Gets current pasteboard item.
    func getCurrentPasteboardItem() -> Paste?

}
