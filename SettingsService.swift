//
//  SettingsService.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import Foundation
import Combine

@MainActor
class SettingsService: ObservableObject {
    @Published var userSettings: UserSettingsDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func fetchSettings() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<UserSettingsDTO, APIError> = await apiClient.get("/settings")
        
        isLoading = false
        switch result {
        case .success(let settings):
            self.userSettings = settings
        case .failure(let error):
            if case .clientError(404) = error {
                // No settings exist yet, create defaults
                await createDefaultSettings()
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateSettings(_ settings: UserSettingsDTO) async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<UserSettingsDTO, APIError> = await apiClient.put("/settings", body: settings)

        isLoading = false
        switch result {
        case .success(let updatedSettings):
            self.userSettings = updatedSettings
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }
    
    func createDefaultSettings() async {
        let defaultSettings = UserSettingsDTO(
            id: nil,
            userId: "", // Will be set by server
            cycleLength: 28,
            periodLength: 5,
            reminderSettings: ReminderSettingsDTO(
                periodReminder: true,
                ovulationReminder: true,
                symptomReminder: true
            ),
            darkMode: false,
            notifications: true
        )
        
        await updateSettings(defaultSettings)
    }
    
    // MARK: - Individual Setting Updates
    
    func updateCycleLength(_ length: Int) async {
        guard var settings = userSettings else { return }
        settings.cycleLength = length
        await updateSettings(settings)
    }
    
    func updatePeriodLength(_ length: Int) async {
        guard var settings = userSettings else { return }
        settings.periodLength = length
        await updateSettings(settings)
    }
    
    func updateReminderSettings(_ reminderSettings: ReminderSettingsDTO) async {
        guard var settings = userSettings else { return }
        settings.reminderSettings = reminderSettings
        await updateSettings(settings)
    }
    
    func updateDarkMode(_ isDarkMode: Bool) async {
        guard var settings = userSettings else { return }
        settings.darkMode = isDarkMode
        await updateSettings(settings)
    }
    
    func updateNotifications(_ enabled: Bool) async {
        guard var settings = userSettings else { return }
        settings.notifications = enabled
        await updateSettings(settings)
    }
    
    // MARK: - Computed Properties
    
    var averageCycleLength: Int {
        return userSettings?.cycleLength ?? 28
    }
    
    var averagePeriodLength: Int {
        return userSettings?.periodLength ?? 5
    }
    
    var isDarkModeEnabled: Bool {
        return userSettings?.darkMode ?? false
    }
    
    var areNotificationsEnabled: Bool {
        return userSettings?.notifications ?? true
    }
    
    var reminderSettings: ReminderSettingsDTO {
        return userSettings?.reminderSettings ?? ReminderSettingsDTO(
            periodReminder: true,
            ovulationReminder: true,
            symptomReminder: true
        )
    }
}
