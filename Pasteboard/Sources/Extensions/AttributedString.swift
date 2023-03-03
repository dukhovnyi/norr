//
//  AttributedString.swift
//  Pasteboard
//
//  Created by Yurii Dukhovnyi on 03.03.2023.
//

import AppKit

extension AttributedString {

    static let loremIpsum: Self = {

        let attr = AttributedString(
            .loremIpsum,
            attributes: AttributeContainer(
                [
                    .font: NSFont.systemFont(ofSize: 33),
                    .backgroundColor : NSColor.orange
                ]
            )
        )

        return attr
    }()
}
