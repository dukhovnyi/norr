//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct SubscriptionDiffView: View {
    
    var body: some View {
        HStack {
            
            VStack(spacing: 16) {
                Text("Free")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 3) {
                    Row(text: "Plain-Text Preview", isAvailable: true)
                    Row(text: "Rich-Text Preview", isAvailable: false)
                    Row(text: "Image Preview", isAvailable: false)
                }
            }
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 16) {
                Text("Premium")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 3) {
                    Row(text: "Plain-Text Preview", isAvailable: true)
                    Row(text: "Rich-Text Preview", isAvailable: true)
                    Row(text: "Image Preview", isAvailable: true)
                }
            }
        }
    }
}

extension SubscriptionDiffView {
    
    struct Row: View {
        
        let text: String
        let isAvailable: Bool
        
        var body: some View {
            HStack {
                Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle")
                    .renderingMode(.template)
                    .foregroundColor(isAvailable ? .green : .red)
                Text(text)
            }
        }
    }
    
}

struct SubscriptionDiffView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionDiffView()
    }
}
