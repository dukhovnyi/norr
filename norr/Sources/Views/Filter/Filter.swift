//
//  FilterView.swift
//  noor
//
//  Created by Yurii Dukhovnyi on 05.05.2023.
//

import Foundation

enum Filter: Equatable {
    case all
    case bolted(_ includes: String)
    case text(String)
    
    var filter: (Paste) -> Bool {
        { item in
            
            switch self {
            case .all:
                return true
            case .bolted(let text):
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return item.isBolted && (trimmed.isEmpty ? true : item.description.lowercased().contains(trimmed.lowercased()))
            case .text(let value):
                return item.description.contains(value)
            }
        }
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.bolted, .bolted):
            return true
        case let (.text(lhsText), .text(rhsText)):
            return lhsText == rhsText
        default:
            return false
        }
    }
}

final class SearchState: ObservableObject {
    @Published var isBolted = false
    @Published var caseSensetive = false
    @Published var text = ""

    func callAsFunction() -> (Paste) -> Bool {
        { [weak self] item in

            guard let self else { return true }

            var searchText = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
            var itemText = item.description

            if !self.caseSensetive {
                searchText = searchText.lowercased()
                itemText = itemText.lowercased()
            }

            return (self.isBolted ? item.isBolted : true) && (searchText.isEmpty ? true : itemText.contains(searchText))
        }
    }
}
