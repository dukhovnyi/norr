//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

extension View {

    @ViewBuilder func ifLet<Transform: View, V>(
        _ condition: @autoclosure () -> V?,
        @ViewBuilder transform: (Self, V) -> Transform
    ) -> some View {

        if let result = condition() {
            transform(self, result)
        } else {
            self
        }
    }

    @ViewBuilder func ifCondition(
        _ condition: @autoclosure () -> Bool,
        @ViewBuilder transform: (Self) -> some View
    ) -> some View {

        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
