//
//  AppEnvironment.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import SwiftUI
import Combine

@MainActor
class AppEnvironment: ObservableObject {
    // Core services
    let coreDataStack = CoreDataStack()
    let keychainStorage = KeychainStorage()
    let apiClient: APIClient
    let authService: AuthService
    let cyclesService: CyclesService
    let logsService: LogsService
    let insightsService: InsightsService
    let predictionsService: PredictionsService
    let settingsService: SettingsService
    
    init() {
        // Initialize API client with base URL
        self.apiClient = APIClient(baseURL: "http://localhost:5000/api")
        
        // Initialize services
        self.authService = AuthService(apiClient: apiClient, keychainStorage: keychainStorage)
        self.cyclesService = CyclesService(apiClient: apiClient)
        self.logsService = LogsService(apiClient: apiClient)
        self.insightsService = InsightsService(apiClient: apiClient)
        self.predictionsService = PredictionsService(apiClient: apiClient)
        self.settingsService = SettingsService(apiClient: apiClient)
        
        // Set auth token for API client
        apiClient.setAuthToken(keychainStorage.retrieveJWTToken())
    }
}
