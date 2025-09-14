//
//  MainTabView.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .environmentObject(appEnvironment)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .environmentObject(appEnvironment)
            
            SymptomLogView()
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Log")
                }
                .environmentObject(appEnvironment)
            
            InsightsView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Insights")
                }
                .environmentObject(appEnvironment)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .environmentObject(appEnvironment)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .environmentObject(appEnvironment)
        }
        .tint(.pink)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppEnvironment())
}
