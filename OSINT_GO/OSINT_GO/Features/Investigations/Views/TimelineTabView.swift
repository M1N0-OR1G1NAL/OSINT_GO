//
//  TimelineTabView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct TimelineTabView: View {
    let investigation: Investigation
    
    private var timelineEvents: [(Date, String, Target)] {
        var events: [(Date, String, Target)] = []
        for target in investigation.targets {
            events.append((target.investigation!.createdAt, "Target added", target))
            for result in target.results {
                events.append((result.timestamp, result.summary, target))
            }
        }
        return events.sorted { $0.0 > $1.0 }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(timelineEvents.enumerated()), id: \.offset) { index, event in
                    TimelineRowView(
                        event: event,
                        isFirstSameDay: index == 0 || !Calendar.current.isDate(event.0, inSameDayAs: timelineEvents[index - 1].0)
                    )
                }
            }
        }
    }
}

struct TimelineRowView: View {
    let event: (Date, String, Target)
    let isFirstSameDay: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd.MM"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline
            VStack(spacing: 0) {
                if isFirstSameDay {
                    Text(dateFormatter.string(from: event.0))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 30)
                }
                
                TimelineDotView()
                
                Rectangle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 2)
                    .frame(minHeight: 40)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: TargetType(rawValue: event.2.type)?.iconName ?? "questionmark")
                    Text(event.1)
                        .fontWeight(.medium)
                    Spacer()
                    Text(event.0, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(event.2.value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct TimelineDotView: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
}
