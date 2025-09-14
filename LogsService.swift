//
//  LogsService.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation
import Combine

@MainActor
class LogsService: ObservableObject {
    @Published var dailyLogs: [DailyLogDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchDailyLogs(startDate: Date? = nil, endDate: Date? = nil) async {
        isLoading = true
        errorMessage = nil
        
        var endpoint = "/daily-logs"
        var queryParams: [String] = []
        
        if let startDate = startDate {
            queryParams.append("startDate=\(DateUtils.dateToISOString(startDate))")
        }
        
        if let endDate = endDate {
            queryParams.append("endDate=\(DateUtils.dateToISOString(endDate))")
        }
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        let result: Result<[DailyLogDTO], APIError> = await apiClient.get(endpoint)
        
        isLoading = false
        switch result {
        case .success(let logs):
            self.dailyLogs = logs
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchDailyLog(for date: Date) async -> DailyLogDTO? {
        let dateString = DateUtils.dateToISOString(date)
        let result: Result<DailyLogDTO, APIError> = await apiClient.get("/daily-logs/\(dateString)")
        
        switch result {
        case .success(let log):
            return log
        case .failure:
            return nil // Log doesn't exist for this date
        }
    }
    
    func createDailyLog(_ log: DailyLogDTO) async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<DailyLogDTO, APIError> = await apiClient.post("/daily-logs", body: log)
        
        isLoading = false
        switch result {
        case .success(let newLog):
            self.dailyLogs.append(newLog)
            self.dailyLogs.sort {
                DateUtils.isoStringToDate($0.date) ?? Date() > DateUtils.isoStringToDate($1.date) ?? Date()
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateDailyLog(_ log: DailyLogDTO) async {
        isLoading = true
        errorMessage = nil
        
        guard let logId = log.id else {
            self.errorMessage = "Invalid log ID"
            isLoading = false
            return
        }
        
        let result: Result<DailyLogDTO, APIError> = await apiClient.put("/daily-logs/\(logId)", body: log)

        isLoading = false
        switch result {
        case .success(let updatedLog):
            if let index = dailyLogs.firstIndex(where: { $0.id == logId }) {
                dailyLogs[index] = updatedLog
            }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteDailyLog(_ logId: String) async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<Void, APIError> = await apiClient.delete("/daily-logs/\(logId)")

        isLoading = false
        switch result {
        case .success:
            dailyLogs.removeAll { $0.id == logId }
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helper Methods
    
    func getLog(for date: Date) -> DailyLogDTO? {
        let dateString = DateUtils.dateToISOString(date)
        return dailyLogs.first { $0.date == dateString }
    }
    
    func getLogsForDateRange(from startDate: Date, to endDate: Date) -> [DailyLogDTO] {
        return dailyLogs.filter { log in
            guard let logDate = DateUtils.isoStringToDate(log.date) else { return false }
            return logDate >= startDate && logDate <= endDate
        }
    }
    
    // MARK: - Analytics Helper Methods
    
    func getSymptomFrequency() -> [String: Int] {
        var frequency: [String: Int] = [:]
        
        for log in dailyLogs {
            for symptom in log.symptoms ?? [] {
                frequency[symptom, default: 0] += 1
            }
        }
        
        return frequency
    }
    
    func getFlowLevelDistribution() -> [FlowLevel: Int] {
        var distribution: [FlowLevel: Int] = [:]
        
        for log in dailyLogs {
            if let flowLevel = log.flowLevel {
                distribution[flowLevel, default: 0] += 1
            }
        }
        
        return distribution
    }
    
    func getMoodFrequency() -> [String: Int] {
        var frequency: [String: Int] = [:]
        
        for log in dailyLogs {
            if let mood = log.mood {
                frequency[mood, default: 0] += 1
            }
        }
        
        return frequency
    }
}
