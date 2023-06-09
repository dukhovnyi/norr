//
//  RetentionDataSettingsView.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 16.05.2023.
//

import Foundation
import SwiftUI

struct RetentionDataSettingsView: View {

    enum Period: Int, Hashable {
        case month, three, year, forever

        func fromNow(now: Date = .now) -> Date {
            switch self {
            case .month:
                return Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            case .three:
                return Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
            case .year:
                return Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
            case .forever:
                return Calendar.current.date(byAdding: .year, value: -10, to: now) ?? now
            }
        }
    }

    @AppStorage("data-retention-period") var period = Period.month

    let wipe: () -> Void

    var body: some View {

        Form {
            Text("Retention History Period")

            Picker("", selection: $period) {
                Text("month").tag(Period.month)
                Text("three").tag(Period.three)
                Text("year").tag(Period.year)
                Text("forever").tag(Period.forever)

            }
            .pickerStyle(.segmented)

            Text("The length of time that pasteboard history is kept within the application before it is deleted or permanently removed.")
                .font(.footnote)

            Text("You have the option to completely remove all retained data at any time.")
                .padding(.top, 24)
            Button(
                action: wipe,
                label: { Text("Wipe data") }
            )
        }
        .fixedSize()
    }
}

struct RetentionDataSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RetentionDataSettingsView(wipe: {})
    }
}
