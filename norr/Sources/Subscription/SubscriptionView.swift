//
//  SubscriptionView.swift
//  norr
//
//  Created by Yurii Dukhovnyi on 07.06.2023.
//

import StoreKit
import SwiftUI

struct SubscriptionView: View {

    @StateObject var model: Model

    var body: some View {
        VStack(spacing: 16) {
            Text("Upgrade to Norr Premium today and take your pasteboard management to the next level.")
                .fixedSize(horizontal: true, vertical: false)

                HStack {
                    ItemView(title: "Basic", description: "", amount: "Free", active: model.isFree())

                    ForEach(model.products) { product in
                        ItemView(
                            title: product.nameOrPeriod,
                            description: product.description,
                            amount: product.displayPrice,
                            active: model.isActive(product: product)
                        )
                        .onTapGesture {
                            model.purchase(product)
                        }
                    }
            }

            Text("By subscribing to Norr Premium you agree to the [Terms of Use](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) and [Privacy Policy](https://dukhovnyi.com/norr/privacy-policy.txt)")
                .padding()
        }
    }
}

extension SubscriptionView {

    struct ItemView: View {
        let title: String
        let description: String
        let amount: String
        let active: Bool

        var body: some View {
            VStack {
                Text(title)
                    .font(.title3)

                Text(amount)
                    .font(.title2)
            }
            .frame(width: 100, height: 100)
            .background(Color.black.opacity(0.2))
            .overlay(alignment: .bottom) {
                if active {
                    Text("Active")
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                }
            }
            .cornerRadius(13)
        }
    }
}

extension Product {

    var nameOrPeriod: String {

        if !displayName.isEmpty {
            return displayName
        }
        if let subscription {
            return [
                "\(subscription.subscriptionPeriod.value)",
                "\(subscription.subscriptionPeriod.unit.localizedDescription)"
            ].joined(separator: " ")
        }

        return ""
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(model: .init(subscription: .previews()))
    }
}
