import SwiftUI
import SwiftData
import Charts
struct DataManagementView: View {
    @Query(sort: \Gecko.name) private var geckos: [Gecko]
    @State private var selectedGecko: Gecko?
    
    // AI Insight
    @State private var aiInsightMessage: String = "개체를 선택하면 AI가 데이터를 분석해 드립니다."
    @State private var isAnalyzing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if geckos.isEmpty {
                    Spacer()
                    Text("등록된 개체가 없습니다.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    // 1. 개체 선택 (가로 스크롤로 필터 버튼 배치 가능)
                    HStack {
                        Picker("개체 선택", selection: $selectedGecko) {
                            Text("모든 개체 보기").tag(nil as Gecko?)
                            ForEach(geckos) { gecko in
                                Text(gecko.name).tag(gecko as Gecko?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // 2. AI Insight 영역 (뼈대 위젯)
                    if let gecko = selectedGecko {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                Text("AI Insight")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.purple)
                                Spacer()
                                if isAnalyzing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            Text(aiInsightMessage)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        // 2-1. Chart Carousel 영역
                        let sortedLogs = gecko.dailyLogs.sorted { $0.date < $1.date }
                        if !sortedLogs.isEmpty {
                            DailyLogCarouselView(logs: sortedLogs)
                        }
                    }
                    
                    // 3. Notion Style Data Table
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            // Table Header
                            HStack(spacing: 0) {
                                TableCellView(text: "날짜", isHeader: true, width: 100)
                                TableCellView(text: "개체명", isHeader: true, width: 100)
                                TableCellView(text: "먹이종류", isHeader: true, width: 150)
                                TableCellView(text: "급여량", isHeader: true, width: 80)
                                TableCellView(text: "공복체중", isHeader: true, width: 80)
                                TableCellView(text: "식후체중", isHeader: true, width: 80)
                                TableCellView(text: "온/습도", isHeader: true, width: 100)
                                TableCellView(text: "배변", isHeader: true, width: 60)
                                TableCellView(text: "탈피상태", isHeader: true, width: 100)
                            }
                            .border(Color.gray.opacity(0.3), width: 1)
                            
                            // Table Rows
                            let filteredLogs = getAllLogs()
                            if filteredLogs.isEmpty {
                                Text("기록된 일지가 없습니다.")
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ForEach(filteredLogs, id: \.log.id) { item in
                                    HStack(spacing: 0) {
                                        TableCellView(text: item.log.date.formatted(date: .numeric, time: .omitted), width: 100)
                                        TableCellView(text: item.gecko.name, width: 100)
                                        TableCellView(text: item.log.foodType, width: 150)
                                        TableCellView(text: "\(String(format: "%.1f", item.log.foodAmount)) ml", width: 80)
                                        TableCellView(text: "\(String(format: "%.1f", item.log.emptyWeight)) g", width: 80)
                                        TableCellView(text: "\(String(format: "%.1f", item.log.afterWeight)) g", width: 80)
                                        TableCellView(text: "\(String(format: "%.1f", item.log.amTemp))℃ / \(String(format: "%.0f", item.log.amHumid))%", width: 100)
                                        TableCellView(text: item.log.defecation ? "O" : "X", width: 60)
                                        TableCellView(text: item.log.sheddingStatus, width: 100)
                                    }
                                    .background(Color(UIColor.systemBackground))
                                    .border(Color.gray.opacity(0.2), width: 0.5)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("데이터")
            .onChange(of: selectedGecko) { _, newValue in
                if let gecko = newValue {
                    analyzeData(for: gecko)
                } else {
                    aiInsightMessage = "개체를 선택하면 AI가 데이터를 분석해 드립니다."
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if let csvURL = CSVExportManager.shared.generateCSV(for: geckos) {
                        ShareLink(item: csvURL) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    } else {
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .disabled(true)
                    }
                }
            }
        }
    }
    
    // 선택된 개체 또는 전체 개체의 로그를 날짜 최신순으로 가져옴
    private func getAllLogs() -> [(gecko: Gecko, log: DailyLog)] {
        var allLogItems: [(Gecko, DailyLog)] = []
        let targetGeckos = selectedGecko != nil ? [selectedGecko!] : geckos
        
        for gecko in targetGeckos {
            for log in gecko.dailyLogs {
                allLogItems.append((gecko, log))
            }
        }
        
        return allLogItems.sorted { $0.1.date > $1.1.date }
    }
    
    private func analyzeData(for gecko: Gecko) {
        isAnalyzing = true
        aiInsightMessage = "AI 분석을 진행 중입니다..."
        
        Task {
            if let result = try? await AIServiceManager.shared.analyzeGeckoData(gecko: gecko) {
                withAnimation {
                    aiInsightMessage = result
                    isAnalyzing = false
                }
            } else {
                withAnimation {
                    aiInsightMessage = "분석 중 오류가 발생했습니다."
                    isAnalyzing = false
                }
            }
        }
    }
}

// 개별 테이블 셀 컴포넌트
struct TableCellView: View {
    let text: String
    var isHeader: Bool = false
    var width: CGFloat
    
    var body: some View {
        Text(text)
            .font(isHeader ? .subheadline.bold() : .footnote)
            .foregroundColor(isHeader ? .primary : .secondary)
            .frame(width: width, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isHeader ? Color(UIColor.systemGray5) : Color.clear)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

// 개별 차트 컨테이너 뷰
struct ChartViewContainer<Content: View>: View {
    let title: String
    let color: Color
    let content: Content
    
    init(title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(color)
                .bold()
                .padding(.bottom, 5)
            
            content
                .padding(.vertical, 5)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// 추출된 Carousel View (컴파일러 복잡도 완화)
struct DailyLogCarouselView: View {
    let logs: [DailyLog]
    
    var body: some View {
        TabView {
            // 차트 1: 먹이 급여량
            ChartViewContainer(title: "먹이 급여량 (ml)", color: .green) {
                Chart {
                    ForEach(logs, id: \.id) { log in
                        LineMark(
                            x: .value("날짜", log.date),
                            y: .value("급여량", log.foodAmount)
                        )
                        .foregroundStyle(.green)
                        .symbol(BasicChartSymbolShape.circle)
                    }
                }
            }
            
            // 차트 2: 공복 체중
            ChartViewContainer(title: "공복 체중 (g)", color: .blue) {
                Chart {
                    ForEach(logs, id: \.id) { log in
                        LineMark(
                            x: .value("날짜", log.date),
                            y: .value("공복 체중", log.emptyWeight)
                        )
                        .foregroundStyle(.blue)
                        .symbol(BasicChartSymbolShape.circle)
                    }
                }
            }
            
            // 차트 3: 식후 체중
            ChartViewContainer(title: "식후 체중 (g)", color: .orange) {
                Chart {
                    ForEach(logs, id: \.id) { log in
                        LineMark(
                            x: .value("날짜", log.date),
                            y: .value("식후 체중", log.afterWeight)
                        )
                        .foregroundStyle(.orange)
                        .symbol(BasicChartSymbolShape.circle)
                    }
                }
            }
            
            // 차트 4: 온/습도
            ChartViewContainer(title: "온도(℃) / 습도(%)", color: .red) {
                VStack(spacing: 5) {
                    Chart {
                        ForEach(logs, id: \.id) { log in
                            LineMark(
                                x: .value("날짜", log.date),
                                y: .value("온도", log.amTemp)
                            )
                            .foregroundStyle(.red)
                            .symbol(BasicChartSymbolShape.circle)
                            
                            LineMark(
                                x: .value("날짜", log.date),
                                y: .value("습도", log.amHumid)
                            )
                            .foregroundStyle(.cyan)
                            .symbol(BasicChartSymbolShape.square)
                        }
                    }
                    HStack {
                        Circle().fill(.red).frame(width: 8, height: 8)
                        Text("온도").font(.caption).foregroundColor(.secondary)
                        Rectangle().fill(.cyan).frame(width: 8, height: 8)
                        Text("습도").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 250)
        .padding(.bottom, 10)
    }
}
