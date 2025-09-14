//
//  DashboardView.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 14/09/25.
//


//
//  TabViews.swift
//  CYCLEai-Tracker
//
//  Created by Manan Rastogi on 15/09/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    var body: some View {
        NavigationView {
            Text("Dashboard View")
                .navigationTitle("Dashboard")
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        NavigationView {
            Text("Calendar View")
                .navigationTitle("Calendar")
        }
    }
}

struct SymptomLogView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        NavigationView {
            Text("Symptom Log View")
                .navigationTitle("Log Symptoms")
        }
    }
}

struct InsightsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        NavigationView {
            Text("Insights View")
                .navigationTitle("Insights")
        }
    }
}

struct AnalyticsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        NavigationView {
            Text("Analytics View")
                .navigationTitle("Analytics")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        NavigationView {
            VStack {
                 Text("Settings View")
                 // You can add a logout button here later
            }
            .navigationTitle("Settings")
        }
    }
}