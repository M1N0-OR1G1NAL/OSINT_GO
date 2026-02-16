// Path: AtlasOSINT/Utils/View+Extensions.swift

import SwiftUI

extension View {
    func osintCard() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
    }
}