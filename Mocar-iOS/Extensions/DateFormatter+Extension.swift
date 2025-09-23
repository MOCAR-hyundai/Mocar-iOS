//
//  DateFormatter+Extension.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 밀리초 있는 경우 대비
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Z(UTC) 기준
        return formatter.date(from: self)
    }
}


extension Date {
    func toFormattedString(_ format: String = "yyyy년 MM월 dd일") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func toISO8601String() -> String {
          let formatter = ISO8601DateFormatter()
          formatter.timeZone = TimeZone(secondsFromGMT: 0)  // UTC로 저장
          formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
          return formatter.string(from: self)
      }
}

func formatDateString(_ dateString: String?, format: String = "yyyy년 MM월 dd일") -> String {
    guard let dateString,
          let date = dateString.toDate() else {
        return "-"
    }
    return date.toFormattedString(format)
}
