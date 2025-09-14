//
//  InsightsService.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation
import Combine

@MainActor
class InsightsService: ObservableObject {
    @Published var insights: [AiInsightDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchInsights(limit: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "/insights?limit=\(limit)"
        let result: Result<[AiInsightDTO], APIError> = await apiClient.get(endpoint)
        
        isLoading = false
        switch result {
        case .success(let fetchedInsights):
            self.insights = fetchedInsights
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func generateInsights() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<[AiInsightDTO], APIError> = await apiClient.post("/insights/generate", body: nil as String?)

        isLoading = false
        switch result {
        case .success(let newInsights):
            let uniqueNewInsights = newInsights.filter { newInsight in
                !self.insights.contains { $0.id == newInsight.id }
            }
            self.insights.insert(contentsOf: uniqueNewInsights, at: 0)
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func markInsightAsRead(_ insightId: String) async {
        guard let index = insights.firstIndex(where: { $0.id == insightId }) else { return }
        
        let result: Result<EmptyResponse, APIError> = await apiClient.post("/insights/\(insightId)/read", body: nil as String?)

        switch result {
        case .success:
            insights[index].isRead = true
        case .failure(let error):
            print("Failed to mark insight as read: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Computed Properties
    
    var unreadInsights: [AiInsightDTO] {
        return insights.filter { $0.isRead == false }
    }
    
    var highPriorityInsights: [AiInsightDTO] {
        return insights.filter { $0.priority == .high }
    }
    
    var insightsByType: [String: [AiInsightDTO]] {
        return Dictionary(grouping: insights, by: { $0.type })
    }
    
    // MARK: - Insight Categories
    
    func getPatternInsights() -> [AiInsightDTO] {
        return insights.filter { $0.type == "pattern" }
    }
    
    func getRecommendationInsights() -> [AiInsightDTO] {
        return insights.filter { $0.type == "recommendation" }
    }
    
    func getHealthTipInsights() -> [AiInsightDTO] {
        return insights.filter { $0.type == "health_tip" }
    }
}

// Empty response struct for APIs that don't return data
struct EmptyResponse: Codable {}
