//
//  DateUtils.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation

struct DateUtils {
    // ISO8601 date formatter for API communication
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // Date formatter for date-only strings (YYYY-MM-DD)
    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    // Display date formatter
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - ISO8601 String Conversion
    
    static func dateToISOString(_ date: Date) -> String {
        return dateOnlyFormatter.string(from: date)
    }
    
    static func isoStringToDate(_ isoString: String) -> Date? {
        // First try date-only format
        if let date = dateOnlyFormatter.date(from: isoString) {
            return date
        }
        
        // Fallback to full ISO8601 format
        return iso8601Formatter.date(from: isoString)
    }
    
    // MARK: - Display Formatting
    
    static func formatDisplayDate(_ date: Date) -> String {
        return displayFormatter.string(from: date)
    }
    
    static func formatDisplayDate(_ isoString: String) -> String {
        guard let date = isoStringToDate(isoString) else { return isoString }
        return formatDisplayDate(date)
    }
    
    // MARK: - Cycle Calculations
    
    static func daysBetween(_ startDate: Date, _ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    static func addDays(_ days: Int, to date: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }
    
    static func startOfDay(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    static func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    static func isYesterday(_ date: Date) -> Bool {
        return Calendar.current.isDateInYesterday(date)
    }
    
    static func isTomorrow(_ date: Date) -> Bool {
        return Calendar.current.isDateInTomorrow(date)
    }
    
    // MARK: - Cycle-specific Utilities
    
    static func predictNextPeriod(lastPeriodStart: Date, averageCycleLength: Double) -> Date {
        let daysToAdd = Int(averageCycleLength.rounded())
        return addDays(daysToAdd, to: lastPeriodStart)
    }
    
    static func predictOvulation(periodStart: Date, cycleLength: Double) -> Date {
        // Ovulation typically occurs 14 days before the end of the cycle
        let ovulationDay = Int(cycleLength) - 14
        return addDays(ovulationDay, to: periodStart)
    }
    
    static func calculateFertileWindow(ovulationDate: Date) -> (start: Date, end: Date) {
        // Fertile window is typically 5 days before ovulation to 1 day after
        let startDate = addDays(-5, to: ovulationDate)
        let endDate = addDays(1, to: ovulationDate)
        return (start: startDate, end: endDate)
    }
    
    // MARK: - Calendar Helpers
    
    static func datesInMonth(_ date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.dateInterval(of: .month, for: date)!.start
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    static func monthAndYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    static func weekdaySymbols() -> [String] {
        return Calendar.current.shortWeekdaySymbols
    }
    
    // MARK: - Relative Date Strings
    
    static func relativeString(for date: Date) -> String {
        if isToday(date) {
            return "Today"
        } else if isYesterday(date) {
            return "Yesterday"
        } else if isTomorrow(date) {
            return "Tomorrow"
        } else {
            let daysDiff = daysBetween(Date(), date)
            if abs(daysDiff) <= 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // Day of week
                return formatter.string(from: date)
            } else {
                return formatDisplayDate(date)
            }
        }
    }
}