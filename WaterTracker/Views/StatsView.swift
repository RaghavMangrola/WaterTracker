import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StatsViewModel?
    
    var body: some View {
        Group {
            if viewModel != nil {
                ScrollView {
                    VStack(spacing: 20) {
                        todayProgressCard
                        chartSection
                    }
                    .padding()
                }
                .navigationTitle("Statistics")
                .background(Color(.systemGroupedBackground))
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = StatsViewModel(modelContext: modelContext)
            }
        }
    }
    
    @ViewBuilder
    private var todayProgressCard: some View {
        if let viewModel = viewModel {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Progress")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(viewModel.todayIntake) oz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("of \(viewModel.currentSettings.dailyGoal) oz goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: viewModel.todayProgressPercentage,
                        lineWidth: 8
                    )
                    .frame(width: 60, height: 60)
                }
                
                progressMessage
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private var progressMessage: some View {
        if let viewModel = viewModel {
            if viewModel.todayIntake < viewModel.currentSettings.dailyGoal {
                Text("You need \(viewModel.currentSettings.dailyGoal - viewModel.todayIntake) oz more today")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            } else {
                Text("Great job! You've met your daily goal!")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
    }
    
    @ViewBuilder
    private var chartSection: some View {
        if viewModel != nil {
            VStack(alignment: .leading, spacing: 16) {
                chartHeader
                chartContent
                statisticsSummary
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private var chartHeader: some View {
        if let viewModel = viewModel {
            HStack {
                Text("Water Intake Trends")
                    .font(.headline)
                
                Spacer()
                
                Picker("Timeframe", selection: Binding(
                    get: { viewModel.selectedPeriod },
                    set: { newValue in
                        self.viewModel?.selectedPeriod = newValue
                    }
                )) {
                    ForEach(StatsViewModel.StatsPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }
        }
    }
    
    @ViewBuilder
    private var chartContent: some View {
        if let viewModel = viewModel {
            if !viewModel.chartData.isEmpty {
                chartView
            } else {
                emptyChartView
            }
        }
    }
    
    @ViewBuilder
    private var chartView: some View {
        if let viewModel = viewModel {
            Chart(viewModel.chartData) { data in
                BarMark(
                    x: .value("Date", data.date),
                    y: .value("Amount", data.amount)
                )
                .foregroundStyle(
                    data.amount >= viewModel.currentSettings.dailyGoal 
                    ? Color.green.gradient 
                    : Color.blue.gradient
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel("\(value.as(Int.self) ?? 0) oz")
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel(format: viewModel.selectedPeriod == .week ? .dateTime.weekday(.abbreviated) : .dateTime.day())
                }
            }
            .chartYScale(domain: 0...max(viewModel.currentSettings.dailyGoal + 20, viewModel.chartData.map(\.amount).max() ?? 0))
            .overlay(
                Rectangle()
                    .stroke(Color.green.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .frame(height: 1)
                    .position(
                        x: UIScreen.main.bounds.width / 2,
                        y: 200 - (200 * Double(viewModel.currentSettings.dailyGoal) / Double(max(viewModel.currentSettings.dailyGoal + 20, viewModel.chartData.map(\.amount).max() ?? 0)))
                    ),
                alignment: .top
            )
        }
    }
    
    private var emptyChartView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No data available")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Start tracking your water intake to see charts")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    @ViewBuilder
    private var statisticsSummary: some View {
        if let viewModel = viewModel, !viewModel.chartData.isEmpty {
            HStack(spacing: 20) {
                StatCard(
                    title: "Average",
                    value: "\(Int(viewModel.averageIntake)) oz",
                    color: .blue
                )
                
                StatCard(
                    title: "Best Day",
                    value: "\(viewModel.bestDay) oz",
                    color: .green
                )
                
                StatCard(
                    title: "Goal Rate",
                    value: "\(Int(viewModel.goalAchievementRate))%",
                    color: .purple
                )
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    Color.blue,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
} 