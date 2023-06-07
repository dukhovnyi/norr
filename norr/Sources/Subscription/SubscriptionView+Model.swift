//
//  SubscriptionView+Model.swift
//  norr
//
//  Created by Yurii Dukhovnyi on 07.06.2023.
//

import Combine
import Foundation
import StoreKit

extension SubscriptionView {

    final class Model: ObservableObject {

        @Published var products: [Product] = []

        init(subscription: Subscription) {
            self.subscription = subscription

            fetchProducts()
            updatePurchased()
        }

        func purchase(_ product: Product) {
            subscription.purchase(product)
        }

        func isActive(product: Product) -> Bool {
            purchasedProductIds.contains(product.id)
        }

        func isFree() -> Bool {
            purchasedProductIds.isEmpty
        }

        // MARK: - Private

        private var cancellable = Set<AnyCancellable>()
        private let subscription: Subscription

        private var purchasedProductIds = [Product.ID]()

        private func fetchProducts() {

            subscription.products()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] prods in

                    self?.products = prods.sorted(by: { $0.price > $1.price })
                }
                .store(in: &cancellable)
        }

        private func updatePurchased() {
            subscription.purchasedProducts()
                .sink { [weak self] ids in
                    self?.purchasedProductIds = ids
                }
                .store(in: &cancellable)
        }
    }
}
