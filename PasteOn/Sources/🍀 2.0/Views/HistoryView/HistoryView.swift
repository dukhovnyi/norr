//
//  HistoryView.swift
//  PasteOn
//
//  Created by Yurii Dukhovnyi on 01.05.2023.
//

import Combine
import SwiftUI

struct HistoryView: View {

    @StateObject var model: Model
    @FocusState private var focusedField: FocusField?

    enum FocusField: Hashable { case search, items }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            SearchTextField(
                placeholder: "Search ...",
                text: $model.search,
                caseSensetive: $model.searchState.caseSensetive,
                bolted: $model.searchState.isBolted
            )
            .focused($focusedField, equals: .search)
            .padding(.vertical)
            .onExitCommand {
                model.search.removeAll()
            }

            if model.items.isEmpty {
                VStack {
                    Text(placeholders.randomElement() ?? "")
                        .padding(64)
                    Text("... or try to copy something into your pasteboard")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {

                List(model.items.lazy.filter(model.searchState()), selection: $model.selected) { item in

                    HistoryRowView(
                        model: .init(
                            item: item,
                            bolt: { [weak model] in model?.bolt(item: item) },
                            remove: { [weak model] in model?.remove(item: item) }
                        )
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { [weak model] in
                        model?.apply(item: item)
                    }
                }
                .focused($focusedField, equals: .items)
                .onAppear {
                    self.focusedField = .search
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {

    static var previews: some View {
        HistoryView(
            model: .init(engine: .init(history: .previews(), pasteboard: .mock()))
        )
    }
}

let placeholders = [
    "Looks like your clipboard history is feeling a bit lonely! It's currently on vacation in the digital Bahamas, sipping a virtual piña colada. Don't worry, it will be back soon with some hilarious memes and useful snippets to entertain you. In the meantime, why not practice your air guitar skills? 🎸✨",
    "Whoops! Looks like all the clipboard snippets went on a spontaneous vacation to sunny Tahiti! 🌴🍹 We'll keep an eye out for their return. In the meantime, feel free to enjoy some virtual beach vibes by making imaginary sandcastles with your keyboard! 🏖️🎉",
    "Oh, snap! It seems our clipboard history has taken a break to travel the world and seek inspiration from exotic lands. Rumor has it, it's currently sipping coconuts on a tropical beach, mingling with witty parrots and brainstorming brilliant copy ideas. While we eagerly await its return, why not take a moment to perfect your pirate accent? Arrr! 🏝️🦜",
    "Attention, clipboard enthusiasts! Our clipboard history is currently enjoying a luxurious spa retreat to rejuvenate its copy-pasting skills. It's receiving deep tissue massages and indulging in cucumber-infused data detox sessions. We apologize for any inconvenience caused, but in the meantime, feel free to unleash your creativity by doodling some clipboard-themed art. 🎨✂️",
    "Houston, we have a clipboard problem! Our clipboard history is currently on a mission to Mars, exploring the vast depths of space for the wittiest puns and most mind-blowing facts. While we eagerly await its return, why not attempt to solve the age-old question: 'Why did the chicken cross the road?' 🚀🐔"
]
