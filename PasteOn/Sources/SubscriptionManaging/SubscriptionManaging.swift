//
//  SubscriptionManaging.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 14.03.2023.
//

import Foundation

struct SubscriptionManaging {

    let current: () -> Subscription

    let subscribe: (Subscription, (Subscription) -> Void) -> Void
}

extension SubscriptionManaging {

    enum Subscription {
        case free
        case xl
    }

}
