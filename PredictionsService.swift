//
//  PredictionsService.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation
import Combine

@MainActor
class PredictionsService: ObservableObject {
    @Published var latestPrediction: PredictionDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchLatestPrediction() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<PredictionDTO, APIError> = await apiClient.get("/predictions/latest")
        
        isLoading = false
        switch result {
        case .success(let prediction):
            self.latestPrediction = prediction
        case .failure(let error):
            if case .clientError(404) = error {
                self.latestPrediction = nil
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func generatePrediction() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<PredictionDTO, APIError> = await apiClient.post("/predictions/generate", body: nil as String?)
        
        isLoading = false
        switch result {
        case .success(let prediction):
            self.latestPrediction = prediction
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Prediction Analysis
    
    var nextPeriodDate: Date? {
        guard let prediction = latestPrediction,
              let dateString = prediction.nextPeriodDate else { return nil }
        return DateUtils.isoStringToDate(dateString)
    }
    
    var ovulationDate: Date? {
        guard let prediction = latestPrediction,
              let dateString = prediction.ovulationDate else { return nil }
        return DateUtils.isoStringToDate(dateString)
    }
    
    var fertilityWindow: (start: Date, end: Date)? {
        guard let prediction = latestPrediction,
              let window = prediction.fertilityWindow,
              let startDate = DateUtils.isoStringToDate(window.start),
              let endDate = DateUtils.isoStringToDate(window.end) else { return nil }
        
        return (start: startDate, end: endDate)
    }
    
    var confidenceLevel: Int {
        return latestPrediction?.confidence ?? 0
    }
    
    var daysUntilNextPeriod: Int? {
        guard let nextPeriod = nextPeriodDate else { return nil }
        return DateUtils.daysBetween(Date(), nextPeriod)
    }
    
    var daysUntilOvulation: Int? {
        guard let ovulation = ovulationDate else { return nil }
        return DateUtils.daysBetween(Date(), ovulation)
    }
    
    // MARK: - Cycle Phase Detection
    
    enum CyclePhase {
        case menstrual
        case follicular
        case ovulation
        case luteal
        case unknown
        
        var displayName: String {
            switch self {
            case .menstrual: return "Menstrual"
            case .follicular: return "Follicular"
            case .ovulation: return "Ovulation"
            case .luteal: return "Luteal"
            case .unknown: return "Unknown"
            }
        }
        
        var description: String {
            switch self {
            case .menstrual:
                return "Your period is here. Focus on rest and self-care."
            case .follicular:
                return "Your energy is building. Great time for new activities."
            case .ovulation:
                return "Peak fertility window. Your energy is at its highest."
            case .luteal:
                return "Pre-menstrual phase. Listen to your body's needs."
            case .unknown:
                return "Keep tracking to get personalized insights."
            }
        }
    }
    
    var currentPhase: CyclePhase {
        guard latestPrediction != nil else { return .unknown }
        
        let today = Date()
        
        if let ovulationDate = self.ovulationDate {
            let daysSinceOvulation = DateUtils.daysBetween(ovulationDate, today)
            
            if abs(daysSinceOvulation) <= 1 {
                return .ovulation
            } else if daysSinceOvulation < -5 {
                return .follicular
            } else if daysSinceOvulation > 1 {
                return .luteal
            }
        }
        
        // This is a simplified check. A more robust implementation
        // would check daily logs to confirm menstruation.
        if let daysUntil = daysUntilNextPeriod, daysUntil <= 5 && daysUntil >= 0 {
             return .menstrual
        }
        
        return .unknown
    }
    
    // MARK: - Fertility Status
    
    var isInFertileWindow: Bool {
        guard let window = fertilityWindow else { return false }
        let today = Date()
        return today >= window.start && today <= window.end
    }
    
    var fertilityStatus: String {
        if isInFertileWindow {
            return "High fertility"
        } else if let daysUntilOvulation = daysUntilOvulation {
            if daysUntilOvulation <= 5 && daysUntilOvulation > 0 {
                return "Approaching fertile window"
            } else if daysUntilOvulation < 0 && daysUntilOvulation >= -14 {
                return "Low fertility"
            }
        }
        return "Unknown"
    }
}
