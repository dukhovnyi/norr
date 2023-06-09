//
//  Subscription.swift
//  norr
//
//  Created by Yurii Dukhovnyi on 07.06.2023.
//

import Foundation

private let supportedProductIds = [
    "annual_pack",
    "quarterly_plan",
    "monthly_plan_product"
]

struct Subscription {
    var products: () -> AnyPublisher<[Product], Never>
    var purchasedProducts: () -> AnyPublisher<Set<Product.ID>, Never>
    var purchase: (Product) -> Void
}

extension Subscription {

    static func live() -> Self {

        let manager = SubscriptionManager()

        return .init(
            products: { manager.products },
            purchasedProducts: { manager.purchasedProducts },
            purchase: { manager.purchase($0) }
        )
    }

    static func previews(
        prods: AnyPublisher<[Product], Never> = CurrentValueSubject<[Product], Never>([]).eraseToAnyPublisher(),
        purchasedProducts: AnyPublisher<Set<Product.ID>, Never> = CurrentValueSubject<Set<Product.ID>, Never>([]).eraseToAnyPublisher()
    ) -> Self {
        .init(
            products: { prods },
            purchasedProducts: { purchasedProducts },
            purchase: { _ in }
        )
    }
}

import Combine
import StoreKit

final class SubscriptionManager {

    var products: AnyPublisher<[Product], Never> { prodSubj.eraseToAnyPublisher() }
    var purchasedProducts: AnyPublisher<Set<Product.ID>, Never> { purchasedProductsSubj.eraseToAnyPublisher() }

    init() {

        productFetchUpdate = fetchProducts()
        activeProductsUpdate = newTransactionListenerTask()
        purchasedProductsTask()
    }

    deinit {
        activeProductsUpdate?.cancel()
    }

    func fetchProducts() -> Task<Void, Never> {
        Task { [weak self] in
            do {
                let products = try await Product.products(for: supportedProductIds)
                self?.prodSubj.send(products)
            } catch {
                debugPrint("🔥 Products have not been retrieved with error='\(error)'.")
            }
        }
    }

    func purchase(_ product: Product) {
        Task { [weak self] in
            do {
                let result = try await product.purchase(options: [.simulatesAskToBuyInSandbox(true)])
                switch result {
                case let .success(.verified(transaction)):
                    await transaction.finish()
                    guard let self else { return }
                    self.activeProductsUpdate = self.newTransactionListenerTask()

                case let .success(.unverified(_, error)):
                    break

                case .pending:
                    break

                case .userCancelled:
                    break

                @unknown default:
                    break
                }
            } catch {
                debugPrint("🔥 Purchase has been failed with error='\(error)'.")
            }
        }
    }

    private func purchasedProductsTask() {
        Task {
            for await verificationResult in Transaction.currentEntitlements {
                self.handle(updatedTransaction: verificationResult)
            }
        }
    }

    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                self.handle(updatedTransaction: verificationResult)
            }
        }
    }

    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }


        if let revocationDate = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
            debugPrint("🔥 revocation date='\(revocationDate)'.")
            var newValue = purchasedProductsSubj.value
            newValue.remove(transaction.productID)
            purchasedProductsSubj.send(newValue)
        } else if let expirationDate = transaction.expirationDate,
            expirationDate < Date() {
            // Do nothing, this subscription is expired.
            return
        } else if transaction.isUpgraded {
            // Do nothing, there is an active transaction
            // for a higher level of service.
            return
        } else {
            // Provide access to the product identified by
            // transaction.productID.
            var newValue = purchasedProductsSubj.value
            newValue.insert(transaction.productID)
            purchasedProductsSubj.send(newValue)
        }
    }

    // MARK: - Private

    private let prodSubj = CurrentValueSubject<[Product], Never>([])
    private let purchasedProductsSubj = CurrentValueSubject<Set<Product.ID>, Never>([])

    private var productFetchUpdate: Task<Void, Never>?
    private var activeProductsUpdate: Task<Void, Never>?
}
