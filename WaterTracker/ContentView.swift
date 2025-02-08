//
//  ContentView.swift
//  WaterTracker
//
//  Created by Raghav Mangrola on 2/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaterEntry.timestamp, order: .reverse) private var waterEntries: [WaterEntry]
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(waterEntries) { entry in
                        NavigationLink {
                            WaterEntryDetailView(entry: entry)
                        } label: {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text("\(entry.amount)ml")
                                        .font(.headline)
                                    Text(entry.timestamp, format: .dateTime)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
                
                VStack(spacing: 16) {
                    Text("Quick Add")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        QuickAddButton(amount: 250, action: addWater)
                        QuickAddButton(amount: 500, action: addWater)
                        QuickAddButton(amount: 750, action: addWater)
                    }
                    
                    Button(action: { showingAddSheet = true }) {
                        Text("Custom Amount")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 2)
            }
            .navigationTitle("Water Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: StatsView()) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWaterEntryView()
            }
        }
    }
    
    private func addWater(amount: Int) {
        withAnimation {
            let entry = WaterEntry(amount: amount)
            modelContext.insert(entry)
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(waterEntries[index])
            }
        }
    }
}

struct QuickAddButton: View {
    let amount: Int
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: { action(amount) }) {
            VStack {
                Image(systemName: "drop.fill")
                    .font(.title2)
                Text("\(amount)ml")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(width: 80, height: 80)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
