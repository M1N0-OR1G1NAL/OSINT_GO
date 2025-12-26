//
//  SectionHeaderView.swift
//  OSINT
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}