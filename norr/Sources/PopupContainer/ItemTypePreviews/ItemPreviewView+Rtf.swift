//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI


extension ItemPreviewView {
    
    struct Rtf: View {

        let attributedString: AttributedString

        var body: some View {
            Text(attributedString)
                    .truncationMode(.tail)
                    .lineLimit(4)
                    .padding()
                    .ifLet(attributedString.backgroundColor?.cgColor) { view, cgColor in
                        view.background(Color(cgColor: cgColor))
                    }
        }

        init?(paste: Paste) {
            guard 
                let content = paste.representations.first(where: { $0.type == .rtf || $0.type == .rtfd })
            else {
                return nil
            }

            do {
                let nsAttributedString = try NSAttributedString(
                    data: content.data ?? Data(),
                    options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil
                )
                var _attributedString = AttributedString(nsAttributedString)
                if let color = nsAttributedString.attribute(.backgroundColor, at: 0, effectiveRange: nil) as? NSColor {
                    _attributedString.backgroundColor = .init(nsColor: color)
                }
                self.attributedString = _attributedString
            } catch {
                debugPrint("💥 Pasteboard content has not converted to attributed  string. Error='\(error)'.")
                self.attributedString = .init("Something went wrong ...")
            }
        }
    }

}

#Preview {
    ItemPreviewView.Rtf(paste: Paste.mockRtf())
}
