//
//  WeeklyReflectionView.swift
//  PulseCor
//

import SwiftUI
import Charts
import SwiftData

struct WeeklyReflectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WeeklyReflectionViewModel()

    @Query(filter: #Predicate<DailyCheckIn> { $0.isComplete == true })
    private var checkIns: [DailyCheckIn]

    let userStreak: Int

    @State private var currentSlide = 0
    private let totalSlides = 7

    var body: some View {
        ZStack(alignment: .top) {
            Color("MainBG").ignoresSafeArea()

            TabView(selection: $currentSlide) {
                Slide1(vm: viewModel).tag(0)
                Slide2(vm: viewModel).tag(1)
                Slide3(vm: viewModel).tag(2)
                Slide4(vm: viewModel).tag(3)
                Slide5(vm: viewModel).tag(4)
                Slide6(vm: viewModel).tag(5)
                Slide7(vm: viewModel, onDone: { viewModel.markViewed(); dismiss() }).tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Top bar
            HStack {
                HStack(spacing: 4) {
                    ForEach(0..<totalSlides, id: \.self) { i in
                        Capsule()
                            .fill(i == currentSlide ? Color("AccentCoral") : Color("MainText").opacity(0.2))
                            .frame(width: i == currentSlide ? 16 : 6, height: 6)
                            .animation(.spring(response: 0.3), value: currentSlide)
                    }
                }
                Spacer()
                if currentSlide < totalSlides - 1 {
                    Button("Skip") { viewModel.markViewed(); dismiss() }
                        .font(.system(size: 13))
                        .foregroundColor(Color("MainText").opacity(0.45))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)

            // Bottom navigation
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    if currentSlide > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) { currentSlide -= 1 }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("AccentCoral"))
                                .frame(width: 52, height: 52)
                                .background(Color("AccentCoral").opacity(0.12))
                                .cornerRadius(14)
                        }
                    }

                    Button(action: {
                        if currentSlide < totalSlides - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) { currentSlide += 1 }
                        } else {
                            viewModel.markViewed()
                            dismiss()
                        }
                    }) {
                        Text(currentSlide == totalSlides - 1 ? "Done" : "Next →")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("AccentCoral"))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear { viewModel.load(checkIns: checkIns, userStreak: userStreak) }
        .onChange(of: checkIns.count) {
            viewModel.load(checkIns: checkIns, userStreak: userStreak)
        }
    }
}

//Shared helpers

private let cardBG = Color("CardBG")
private let textPrimary = Color("MainText")
private let textSecondary = Color("MainText").opacity(0.6)
private let textMuted = Color("MainText").opacity(0.35)

private func slideTitle(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
}

private func coraCaption(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 13))
        .foregroundColor(textSecondary)
        .lineSpacing(4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardBG)
        .cornerRadius(12)
}

private func statBox(value: String, label: String, valueColor: Color = Color("MainText")) -> some View {
    VStack(spacing: 4) {
        Text(value)
            .font(.system(size: 26, weight: .semibold))
            .foregroundColor(valueColor)
        Text(label)
            .font(.system(size: 11))
            .foregroundColor(textMuted)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(cardBG)
    .cornerRadius(14)
}

//Slide 1: Opening

private struct Slide1: View {
    let vm: WeeklyReflectionViewModel
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 100)

                ZStack {
                    Circle()
                        .fill(Color("AccentCoral").opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color("AccentCoral"))
                }
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)

                VStack(spacing: 8) {
                    Text("Weekly Reflection")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("AccentCoral"))
                        .kerning(1.5)
                        .textCase(.uppercase)

                    Text(vm.headlineInsight)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("— Cora")
                        .font(.system(size: 13))
                        .italic()
                        .foregroundColor(textMuted)
                }
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)

                HStack(spacing: 12) {
                    statBox(value: "\(vm.checkInCount)/7", label: "check-ins")
                    statBox(value: "\(vm.currentStreak)", label: "day streak", valueColor: Color("AccentCoral"))
                }
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)

                HStack(spacing: 12) {
                    statBox(value: String(format: "%.1f", vm.avgSleepHours) + "h", label: "avg sleep")
                    statBox(value: "\(vm.calmDays)", label: "calm days")
                }
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Swipe through to see your full week. We'll go through your sleep, stress, hydration, and the patterns Cora noticed.")
                        .font(.system(size: 14))
                        .foregroundColor(textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color("AccentCoral").opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("AccentCoral").opacity(0.2), lineWidth: 1))
                .cornerRadius(14)
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) { appeared = true }
        }
    }
}

// Slide 2: At a Glance

private struct Slide2: View {
    let vm: WeeklyReflectionViewModel
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 100)
                slideTitle("Your week at a glance")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statBox(value: "\(vm.checkInCount)/7", label: "check-ins completed")
                    statBox(value: "\(vm.currentStreak)", label: "day streak", valueColor: Color("AccentCoral"))
                    statBox(value: String(format: "%.1f", vm.avgSleepHours) + "h", label: "avg sleep / night")
                    statBox(value: "\(vm.calmDays)", label: "calm days")
                    statBox(value: "\(vm.daysUnderSevenHours)", label: "days under 7h sleep")
                    statBox(value: "\(vm.hydrationGoalDays)/7", label: "well-hydrated days")
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)

                if !vm.headlineInsight.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cora's take")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color("AccentCoral"))
                        Text(vm.headlineInsight)
                            .font(.system(size: 13))
                            .foregroundColor(textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardBG)
                    .cornerRadius(12)
                    .opacity(appeared ? 1 : 0)
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.15)) { appeared = true }
        }
    }
}

// Slide33:  Sleep

private struct Slide3: View {
    let vm: WeeklyReflectionViewModel
    @State private var appeared = false

    private let yLabels: [(value: Double, label: String)] = [
        (5.0, "<6h"), (6.5, "6-7h"), (7.5, "7-8h"), (8.5, "8h+")
    ]
    private let minY: Double = 4.0
    private let maxY: Double = 9.5

    private func yPos(_ val: Double, chartH: CGFloat) -> CGFloat {
        let frac = (val - minY) / (maxY - minY)
        return chartH - CGFloat(frac) * chartH
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 100)
                slideTitle("Sleep this week")

                if !vm.sleepData.isEmpty {
                    GeometryReader { geo in
                        let chartH = geo.size.height
                        let chartW = geo.size.width
                        let labelW: CGFloat = 36
                        let barArea = chartW - labelW
                        let barCount = vm.sleepData.count
                        let barSlot = barArea / CGFloat(barCount)
                        let barW = barSlot * 0.55

                        ZStack(alignment: .topLeading) {
                            ForEach(yLabels, id: \.value) { item in
                                let y = yPos(item.value, chartH: chartH)
                                Path { p in
                                    p.move(to: CGPoint(x: labelW, y: y))
                                    p.addLine(to: CGPoint(x: chartW, y: y))
                                }
                                .stroke(Color("MainText").opacity(0.08), lineWidth: 1)

                                Text(item.label)
                                    .font(.system(size: 9))
                                    .foregroundColor(Color("MainText").opacity(0.35))
                                    .frame(width: labelW - 4, alignment: .trailing)
                                    .position(x: (labelW - 4) / 2, y: y)
                            }

                            Path { p in
                                p.move(to: CGPoint(x: labelW, y: yPos(7.5, chartH: chartH)))
                                p.addLine(to: CGPoint(x: chartW, y: yPos(7.5, chartH: chartH)))
                            }
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundColor(Color("MainText").opacity(0.25))

                            ForEach(Array(vm.sleepData.enumerated()), id: \.element.id) { idx, point in
                                let x = labelW + CGFloat(idx) * barSlot + (barSlot - barW) / 2
                                let barBottom = yPos(minY, chartH: chartH)
                                let fullBarH = barBottom - yPos(max(point.value, minY + 0.1), chartH: chartH)
                                let barH = fullBarH * (appeared ? 1 : 0)

                                Rectangle()
                                    .fill(point.value >= 7 ? Color("AccentCoral") : Color("AccentCoral").opacity(0.5))
                                    .frame(width: barW, height: max(barH, 0))
                                    .cornerRadius(4)
                                    .position(x: x + barW / 2, y: barBottom - max(barH, 0) / 2)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(idx) * 0.05 + 0.15), value: appeared)
                            }

                            ForEach(Array(vm.sleepData.enumerated()), id: \.element.id) { idx, point in
                                let x = labelW + CGFloat(idx) * barSlot + barSlot / 2
                                Text(point.day)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color("MainText").opacity(0.4))
                                    .position(x: x, y: chartH + 14)
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.bottom, 28)
                }

                HStack(spacing: 12) {
                    statBox(value: String(format: "%.1f", vm.avgSleepHours) + "h", label: "avg / night")
                    statBox(value: "\(vm.daysUnderSevenHours)/7", label: "days under 7h")
                }
                .opacity(appeared ? 1 : 0)

                coraCaption(vm.sleepCaption)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Did you know?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("AccentCoral"))
                    Text("Adults need 7-9 hours of sleep per night. Even one extra 30 minutes can improve mood, energy, and heart health.")
                        .font(.system(size: 12))
                        .foregroundColor(textSecondary)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(cardBG)
                .cornerRadius(12)
                .opacity(appeared ? 1 : 0)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) { appeared = true }
        }
    }
}

// Slide 4: Stress & Energy

private struct Slide4: View {
    let vm: WeeklyReflectionViewModel
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 100)
                slideTitle("Stress & energy")

                if !vm.stressData.isEmpty && !vm.energyData.isEmpty {
                    Chart {
                        ForEach(Array(vm.stressData.enumerated()), id: \.element.id) { idx, point in
                            LineMark(
                                x: .value("Day", idx),
                                y: .value("Level", point.value),
                                series: .value("Type", "Stress")
                            )
                            .foregroundStyle(Color("AccentCoral"))
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                            .interpolationMethod(.monotone)
                            PointMark(
                                x: .value("Day", idx),
                                y: .value("Level", point.value)
                            )
                            .foregroundStyle(Color("AccentCoral"))
                            .symbolSize(30)
                        }
                        ForEach(Array(vm.energyData.enumerated()), id: \.element.id) { idx, point in
                            LineMark(
                                x: .value("Day", idx),
                                y: .value("Level", point.value),
                                series: .value("Type", "Energy")
                            )
                            .foregroundStyle(Color("MainText").opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
                            .interpolationMethod(.monotone)
                            PointMark(
                                x: .value("Day", idx),
                                y: .value("Level", point.value)
                            )
                            .foregroundStyle(Color("MainText").opacity(0.4))
                            .symbolSize(20)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3]) { value in
                            AxisGridLine().foregroundStyle(Color("MainText").opacity(0.08))
                            AxisValueLabel {
                                if let v = value.as(Int.self) {
                                    let labels = [1: "Low", 2: "Mid", 3: "High"]
                                    Text(labels[v] ?? "")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("MainText").opacity(0.35))
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: Array(0..<vm.stressData.count)) { value in
                            AxisValueLabel {
                                if let i = value.as(Int.self), i < vm.stressData.count {
                                    Text(vm.stressData[i].day)
                                        .font(.system(size: 11))
                                        .foregroundColor(Color("MainText").opacity(0.4))
                                }
                            }
                        }
                    }
                    .chartXScale(domain: -0.5...6.5)
                    .chartYScale(domain: 0.5...3.5)
                    .frame(height: 200)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.2), value: appeared)
                }

                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Rectangle().fill(Color("AccentCoral")).frame(width: 18, height: 2.5).cornerRadius(1)
                        Text("Stress").font(.system(size: 12)).foregroundColor(textSecondary)
                    }
                    HStack(spacing: 6) {
                        Rectangle().fill(Color("MainText").opacity(0.4)).frame(width: 18, height: 2).cornerRadius(1)
                        Text("Energy").font(.system(size: 12)).foregroundColor(textSecondary)
                    }
                }
                .opacity(appeared ? 1 : 0)

                HStack(spacing: 12) {
                    statBox(value: "\(vm.calmDays)/7", label: "calm days")
                    statBox(value: "\(7 - vm.calmDays)/7", label: "stressed days")
                }
                .opacity(appeared ? 1 : 0)

                coraCaption(vm.stressEnergyCaption)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Cora's tip")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("AccentCoral"))
                    Text("When stress is high, your heart rate and cortisol both rise. Even 10 minutes of calm; a walk, breathing, or quiet can bring both down.")
                        .font(.system(size: 12))
                        .foregroundColor(textSecondary)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(cardBG)
                .cornerRadius(12)
                .opacity(appeared ? 1 : 0)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { appeared = true }
        }
    }
}

//Slide 5: Hydration

private struct Slide5: View {
    let vm: WeeklyReflectionViewModel
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 100)
                slideTitle("Hydration this week")

                HStack {
                    Spacer()
                    ZStack {
                        let total = max(vm.waterLevels.map { $0.count }.reduce(0, +), 1)
                        let segments: [(Double, Color)] = vm.waterLevels.map { level in
                            (Double(level.count) / Double(total), Color("AccentCoral").opacity(level.opacity))
                        }
                        ForEach(0..<segments.count, id: \.self) { i in
                            DonutSegment(
                                startFraction: segments.prefix(i).map { $0.0 }.reduce(0, +),
                                endFraction: segments.prefix(i + 1).map { $0.0 }.reduce(0, +),
                                color: segments[i].1,
                                animate: appeared
                            )
                        }
                        VStack(spacing: 2) {
                            Text("\(vm.hydrationGoalDays)/7")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(textPrimary)
                            Text("well hydrated")
                                .font(.system(size: 10))
                                .foregroundColor(textMuted)
                        }
                    }
                    .frame(width: 140, height: 140)
                    Spacer()
                }

                VStack(spacing: 10) {
                    ForEach(vm.waterLevels, id: \.label) { level in
                        HStack {
                            Circle().fill(Color("AccentCoral").opacity(level.opacity)).frame(width: 10, height: 10)
                            Text(level.label).font(.system(size: 13)).foregroundColor(textSecondary)
                            Spacer()
                            Text("\(level.count) day\(level.count == 1 ? "" : "s")").font(.system(size: 13)).foregroundColor(textSecondary)
                        }
                    }
                }
                .padding(14)
                .background(cardBG)
                .cornerRadius(14)
                .opacity(appeared ? 1 : 0)

                coraCaption(vm.hydrationCaption)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Did you know?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("AccentCoral"))
                    Text("Even mild dehydration can cause fatigue, headaches, and reduced concentration. The NHS recommends 6-8 glasses of fluid a day.")
                        .font(.system(size: 12))
                        .foregroundColor(textSecondary)
                        .lineSpacing(3)
                }
                .padding(14)
                .background(cardBG)
                .cornerRadius(12)
                .opacity(appeared ? 1 : 0)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { appeared = true }
        }
    }
}

// Donut segment helpter

private struct DonutSegment: View {
    let startFraction: Double
    let endFraction: Double
    let color: Color
    let animate: Bool

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth: CGFloat = 22
            Circle()
                .trim(from: 0, to: animate ? CGFloat(endFraction - startFraction) : 0)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(-90 + startFraction * 360))
                .frame(width: size - lineWidth, height: size - lineWidth)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .animation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.3), value: animate)
        }
    }
}

//Slide 6: Correlations

private struct Slide6: View {
    let vm: WeeklyReflectionViewModel
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 100)
                slideTitle("What Cora noticed")

                if vm.topCorrelations.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Not enough variation this week to find strong patterns — which could be a good sign! Keep checking in and Cora will surface deeper insights next week.")
                            .font(.system(size: 14))
                            .foregroundColor(textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(cardBG)
                    .cornerRadius(14)
                } else {
                    ForEach(Array(vm.topCorrelations.enumerated()), id: \.element.id) { idx, correlation in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("AccentCoral"))
                                Text(correlation.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(textPrimary)
                            }
                            Text(correlation.body)
                                .font(.system(size: 13))
                                .foregroundColor(textSecondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(idx == 0 ? Color("AccentCoral").opacity(0.08) : cardBG)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(idx == 0 ? Color("AccentCoral").opacity(0.25) : Color.clear, lineWidth: 1))
                        .cornerRadius(14)
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(Double(idx) * 0.12), value: appeared)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color("AccentCoral"))
                        Text("This week's win")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("AccentCoral"))
                    }
                    Text(vm.weekWin)
                        .font(.system(size: 13))
                        .foregroundColor(textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(cardBG)
                .cornerRadius(14)
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.25), value: appeared)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear { withAnimation { appeared = true } }
    }
}

//Slide 7 : Closing

private struct Slide7: View {
    let vm: WeeklyReflectionViewModel
    let onDone: () -> Void
    @State private var appeared = false

    var focusAreas: [(icon: String, text: String)] {
        var areas: [(String, String)] = []
        if vm.avgSleepHours < 7.0 {
            areas.append(("moon.fill", "Try getting to bed 30 minutes earlier this week"))
        }
        if vm.calmDays < 4 {
            areas.append(("wind", "Build in 10 minutes of quiet time each day to lower stress"))
        }
        if vm.hydrationGoalDays < 4 {
            areas.append(("drop.fill", "Keep a water bottle visible — aim for 6+ glasses daily"))
        }
        if vm.checkInCount < 7 {
            areas.append(("checkmark.circle.fill", "Try to check in every day — even a quick one counts"))
        }
        if areas.isEmpty {
            areas.append(("arrow.up.circle.fill", "You're doing great — keep the consistency going"))
        }
        return areas
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 100)

                ZStack {
                    Circle().fill(Color("AccentCoral").opacity(0.15)).frame(width: 80, height: 80)
                    Image(systemName: "heart.fill").font(.system(size: 32)).foregroundColor(Color("AccentCoral"))
                }
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)

                Text("That's a wrap on your week")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)

                Text(vm.closingMessage)
                    .font(.system(size: 14))
                    .foregroundColor(textSecondary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .padding(18)
                    .background(Color("AccentCoral").opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("AccentCoral").opacity(0.2), lineWidth: 1))
                    .cornerRadius(16)
                    .offset(y: appeared ? 0 : 16)
                    .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Areas to focus on next week")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textPrimary)

                    ForEach(Array(focusAreas.enumerated()), id: \.offset) { idx, area in
                        HStack(spacing: 12) {
                            Image(systemName: area.icon)
                                .font(.system(size: 16))
                                .foregroundColor(Color("AccentCoral"))
                                .frame(width: 24)
                            Text(area.text)
                                .font(.system(size: 13))
                                .foregroundColor(textSecondary)
                                .lineSpacing(3)
                            Spacer()
                        }
                        .padding(12)
                        .background(cardBG)
                        .cornerRadius(10)
                        .offset(y: appeared ? 0 : 16)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(Double(idx) * 0.1 + 0.3), value: appeared)
                    }
                }
                .padding(.top, 4)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) { appeared = true }
        }
    }
}
