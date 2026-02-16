// Path: AtlasOSINT/Utils/DateFormatter+OSINT.swift

import Foundation

extension DateFormatter {
    static let osintTimestamp: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = .current
        return df
    }()

    static let osintShortDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
}