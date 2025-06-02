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
    @State private var viewModel: ContentViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                NavigationStack {
                    VStack {
                        dailyProgressSection
                        waterEntriesList
                        quickAddButtons
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
                    .sheet(isPresented: Binding(
                        get: { viewModel.showingAddSheet },
                        set: { viewModel.showingAddSheet = $0 }
                    )) {
                        AddWaterEntryView()
                    }
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ContentViewModel(modelContext: modelContext)
            }
        }
    }
    
    @ViewBuilder
    private var dailyProgressSection: some View {
        if let viewModel = viewModel {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today's Progress")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(viewModel.progressText)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(viewModel.progressPercentageText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text(viewModel.remainingText)
                            .font(.caption)
                            .foregroundColor(viewModel.isGoalReached ? .green : .secondary)
                    }
                }
                
                progressBar
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var progressBar: some View {
        if let viewModel = viewModel {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.progressPercentage, height: 12)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.progressPercentage)
                }
            }
            .frame(height: 12)
        }
    }
    
    @ViewBuilder
    private var waterEntriesList: some View {
        if let viewModel = viewModel {
            List {
                ForEach(viewModel.waterEntries) { entry in
                    NavigationLink {
                        WaterEntryDetailView(entry: entry)
                    } label: {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("\(entry.amount) oz")
                                    .font(.headline)
                                Text(entry.timestamp, format: .dateTime)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    withAnimation {
                        viewModel.deleteEntries(at: indexSet)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var quickAddButtons: some View {
        if let viewModel = viewModel {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    QuickAddButton(
                        amount: 8,
                        displayAmount: "8 oz",
                        icon: "waterbottle"
                    ) { amount in
                        withAnimation {
                            viewModel.addWater(amount: amount)
                        }
                    }
                    QuickAddButton(
                        amount: 40,
                        displayAmount: "40 oz", 
                        icon: "waterbottle.fill"
                    ) { amount in
                        withAnimation {
                            viewModel.addWater(amount: amount)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .shadow(radius: 2)
        }
    }
}

struct QuickAddButton: View {
    let amount: Int
    let displayAmount: String
    let icon: String
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: { action(amount) }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                Text(displayAmount)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.blue)
            .cornerRadius(15)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WaterEntry.self, inMemory: true)
}
