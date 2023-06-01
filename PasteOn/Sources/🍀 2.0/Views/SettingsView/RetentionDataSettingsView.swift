//
//  RetentionDataSettingsView.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 16.05.2023.
//

import SwiftUI

struct RetentionDataSettingsView: View {

    enum Period: Int, Hashable {
        case month, three, year, forever
    }

    @AppStorage("dataRetention") var period = Period.month

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
        .frame(width: 420)

    }
}

struct RetentionDataSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RetentionDataSettingsView(wipe: {})
    }
}
