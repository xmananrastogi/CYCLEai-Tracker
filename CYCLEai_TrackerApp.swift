//
//  CYCLEai_TrackerApp.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//

import SwiftUI

@main
struct CYCLEai_TrackerApp: App {
    @StateObject private var appEnvironment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnvironment)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Initialize Core Data stack
        appEnvironment.coreDataStack.loadPersistentStore()
        
        // Check authentication status
        Task {
            await appEnvironment.authService.checkAuthenticationStatus()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        Group {
            if appEnvironment.authService.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppEnvironment())
}
