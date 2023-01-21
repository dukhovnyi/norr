//
// Copyright © 2023 Yurii Dukhovnyi. All rights reserved.
//
// This file is an original work developed by Yurii Dukhovnyi.
//

import SwiftUI

struct ItemPreviewView: View {

    let paste: Paste

    var body: some View {

        VStack {
            Spacer()

            if let data = paste.representations.first(where: { $0.type == .fileURL })?.data,
               let fileUrl = URL(dataRepresentation: data, relativeTo: nil) {
                let nsImage: NSImage = NSWorkspace.shared.icon(for: .init(filenameExtension: fileUrl.pathExtension) ?? .fileURL)
                VStack {
                    iconPreviewWithStyle(Image(nsImage: nsImage))
                    badgeWithStyle(Text(fileUrl.lastPathComponent))
                }
            } else if let data = paste.representations.first(where: { $0.type == .URL })?.data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) {
                let nsImage: NSImage = NSWorkspace.shared.icon(for: .url)
                VStack {

                    iconPreviewWithStyle(Image(nsImage: nsImage))
                    badgeWithStyle(Text(url.host() ?? "N/A"))
                }
            } 
            else if paste.is(.png) {
                Png(paste: paste)
            } else if paste.is(.rtf) || paste.is(.rtfd) {
                Rtf(paste: paste)
            } else if paste.is(.color) {
                ColorRef(paste: paste)
            } else {
                Text(paste.stringRepresentation)
            }

            Spacer()
        }
    }

    @ViewBuilder func iconPreviewWithStyle(_ image: Image) -> some View {
        image
            .resizable()
            .frame(width: 50, height: 50)
    }

    @ViewBuilder func badgeWithStyle(_ text: Text) -> some View {
        text
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.gray)
            .mask(Capsule())
    }
}

#Preview {
    ScrollView {
        VStack {
            Section("File URL") {
                ItemPreviewView(paste: .mockFileUrl())
                ItemPreviewView(paste: .mockFileUrl(fileUrl: .init(string: "/System/Applications/App Store.app/Contents")!))
            }

            Divider()

            Section("URL") {
                ItemPreviewView(paste: .mockUrl())
            }

            Section("Image") {
                ItemPreviewView(paste: .mockImage())
            }

            Section("Plain Text") {
                ItemPreviewView(paste: .mockPlainText(text: """
What is Lorem Ipsum?
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

Why do we use it?
It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).


Where does it come from?
Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.

The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
"""
                                                     ))
            }
        }
    }
    .padding()
}
