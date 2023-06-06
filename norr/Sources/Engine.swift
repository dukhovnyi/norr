//
//  Engine.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import Combine
import Foundation
import SwiftUI

final class Engine {

    let history: History
    let pasteboard: PasteboardManaging
    let excludeApps: ExcludeApps
    let analytics: AnalyticsManaging

    init(
        history: History,
        pasteboard: PasteboardManaging,
        excludeApps: ExcludeApps,
        analytics: AnalyticsManaging
    ) {
        self.history = history
        self.pasteboard = pasteboard
        self.excludeApps = excludeApps
        self.analytics = analytics

        scheduleHistoryCleanUp(nextRoundIn: 10)
    }

    func start() {

        cancellableSubscription = pasteboard.value
            .filter { [weak self] paste in
                if let self, let bundleId = paste.bundleId {
                    return !self.excludeApps.isExcluded(bundleId)
                }
                return true
            }
            .sink { [weak self] newItem in
                self?.history.append(newItem)
            }

        pasteboard.start()
    }

    func stop() {

        pasteboard.stop()
        cancellableSubscription = nil
    }

    // MARK: - Private

    private var cancellableSubscription: AnyCancellable?

    private func scheduleHistoryCleanUp(nextRoundIn: Double) {
        Timer.scheduledTimer(withTimeInterval: nextRoundIn, repeats: false) { [weak self] timer in
            self?.analytics.logEvent(.maxRetainPeriodAchieved)
            let period =  RetentionDataSettingsView.Period(rawValue: Foundation.UserDefaults.standard.value(forKey: "data-retention-period") as? Int ?? 0) ?? .month
            self?.history.removeWithPredicate(NSPredicate(format: "createdAt < %@", period.fromNow() as NSDate))

            self?.scheduleHistoryCleanUp(nextRoundIn: 60*60*24)
        }
    }
}

extension Engine {
    static func previews() -> Engine {
        .init(
            history: .previews(),
            pasteboard: .mock(),
            excludeApps: .previews(),
            analytics: .previews()
        )
    }
}