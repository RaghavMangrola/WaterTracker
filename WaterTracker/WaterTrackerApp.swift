//
//  WaterTrackerApp.swift
//  WaterTracker
//
//  Created by Raghav Mangrola on 2/7/25.
//

import SwiftUI
import SwiftData

@main
struct WaterTrackerApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: WaterEntry.self, Settings.self, configurations: config)
        } catch {
            print("Failed to create ModelContainer: \(error)")
            // Create a fallback in-memory container for development
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(for: WaterEntry.self, Settings.self, configurations: config)
                print("Using in-memory ModelContainer as fallback")
            } catch {
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
