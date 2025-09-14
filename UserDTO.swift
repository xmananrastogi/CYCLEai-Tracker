//
//  UserDTO.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation

// Data Transfer Objects - match the API schema

struct UserDTO: Codable {
    let id: String
    let email: String
    var firstName: String?
    var lastName: String?
    let createdAt: Date?
}

struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}

struct RegisterRequestDTO: Codable {
    let email: String
    let password: String
    let firstName: String?
    let lastName: String?
}

struct AuthResponseDTO: Codable {
    let user: UserDTO
    let token: String
}

struct CycleDTO: Codable {
    let id: String?
    let userId: String
    var startDate: String // ISO8601 date string
    var endDate: String?
    var cycleLength: Int?
    var periodLength: Int?
    var isComplete: Bool?
    let createdAt: Date?
}

struct DailyLogDTO: Codable {
    let id: String?
    let userId: String
    let date: String // ISO8601 date string
    var flowLevel: FlowLevel?
    var symptoms: [String]?
    var mood: String?
    var notes: String?
    var temperature: String?
    var weight: String?
    let createdAt: Date?
}

struct PredictionDTO: Codable {
    let id: String?
    let userId: String
    let nextPeriodDate: String?
    let ovulationDate: String?
    let fertilityWindow: FertilityWindowDTO?
    let confidence: Int?
    let generatedAt: Date?
}

struct FertilityWindowDTO: Codable {
    let start: String
    let end: String
}

struct AiInsightDTO: Codable {
    let id: String?
    let userId: String
    let type: String
    let title: String
    let content: String
    var priority: Priority?
    var isRead: Bool?
    let generatedAt: Date?
}

struct UserSettingsDTO: Codable {
    let id: String?
    let userId: String
    var cycleLength: Int?
    var periodLength: Int?
    var reminderSettings: ReminderSettingsDTO?
    var darkMode: Bool?
    var notifications: Bool?
}

struct ReminderSettingsDTO: Codable {
    var periodReminder: Bool
    var ovulationReminder: Bool
    var symptomReminder: Bool
}

// Enums
enum FlowLevel: String, Codable, CaseIterable {
    case none = "none"
    case light = "light"
    case medium = "medium"
    case heavy = "heavy"
    
    var displayName: String {
        return self.rawValue.capitalized
    }
}

enum Priority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        rawValue.capitalized
    }
}
