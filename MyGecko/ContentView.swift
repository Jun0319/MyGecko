import SwiftUI
import SwiftData
import PhotosUI
import Charts

// 📌 0. 앱 시작을 담당하는 메인 화면 (스플래시 스크린 제어)
struct ContentView: View {
    @State private var isSplashActive = true
    
    var body: some View {
        ZStack {
            // 1. 스플래시가 끝나면 진짜 앱 화면(MainTabView)을 보여줌
            if !isSplashActive {
                MainTabView()
            }
            
            // 2. 앱을 켜자마자 보이는 스플래시 화면
            if isSplashActive {
                SplashView()
                    .transition(.opacity) // 사라질 때 스르륵~ 페이드아웃 효과
            }
        }
        .onAppear {
            // 1.5초 뒤에 스플래시 화면을 스르륵 닫고 메인으로 넘어가는 애니메이션!
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isSplashActive = false
                }
            }
        }
    }
}

// 📌 0-1. Éclat Privé 스플래시 디자인 (시안 1: 클래식 화이트 & 우아한 모션)
struct SplashView: View {
    // 🌟 애니메이션 상태를 관리할 스위치들
    @State private var textOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 15.0 // 처음엔 살짝 아래(15만큼)에 위치
    
    var body: some View {
        ZStack {
            // 🌟 배경색 (완벽한 순백색으로 강제 고정)
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 12) {
                // 🌟 메인 브랜드 네임
                Text("Éclat Privé")
                    .font(.custom("Baskerville", size: 48)) // 가늘고 우아한 명조체
                    .fontWeight(.regular)
                    // 짙은 차콜/딥 인디고 색상 (완전 검은색보다 훨씬 고급스러움)
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.2))
                
                // 🌟 서브 타이틀
                Text("Premium Crested Gecko Lineage")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.gray)
                    .tracking(4) // 자간을 넓게 벌려 여백의 미 극대화
            }
            // 🌟 모션(애니메이션) 적용
            .opacity(textOpacity)
            .offset(y: textOffset)
        }
        .onAppear {
            // 🌟 화면이 나타날 때 1.5초 동안 아주 부드럽게 떠오르며 뚜렷해지는 마법!
            withAnimation(.easeOut(duration: 1.5)) {
                textOpacity = 1.0
                textOffset = 0.0 // 원래 위치(0)로 스르륵 올라옴
            }
        }
    }
}

// 📌 1. 앱의 뿌리가 되는 하단 탭 바 (기존 ContentView 이름을 MainTabView로 변경!)
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("홈", systemImage: "house.fill") }
            
            GeckoListView()
                .tabItem { Label("개체 관리", systemImage: "pawprint.fill") }
            
            IncubatorView()
                .tabItem { Label("인큐베이터", systemImage: "tray.2.fill") }
            
            StatisticsView()
                .tabItem { Label("통계", systemImage: "chart.pie.fill") }
            
            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape.fill") }
        }
        .tint(.indigo)
    }
}

// (이 아래부터 있는 HomeView, GeckoListView 등의 코드는 그대로 두면 돼!)

// 📌 2. 홈 화면 (토스 스타일 대시보드)
struct HomeView: View {
    @Query private var geckos: [Gecko]
    @State private var showingQuickFeed = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 카드 1: 투데이 알림
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("할 일 1건 >")
                                .font(.subheadline)
                                .foregroundColor(.indigo)
                                .bold()
                            Text("오늘 피딩 예정인 개체가 있습니다 🦗")
                                .font(.headline)
                        }
                        Spacer()
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    let sheddingSoonGeckos = geckos.filter { $0.daysUntilShedding <= 3 }
                            if !sheddingSoonGeckos.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    let sheddingSoonGeckos = geckos.filter { $0.daysUntilShedding <= 3 }
                                            if !sheddingSoonGeckos.isEmpty {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    HStack {
                                                        Text("탈피 임박 알림 🐍")
                                                            .font(.headline)
                                                        Spacer()
                                                        Image(systemName: "drop.fill")
                                                            .foregroundColor(.cyan)
                                                    }
                                                    Text("습도를 70~80%로 높여주세요!")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Divider()
                                                    
                                                    // 해당되는 개체들 리스트 쫙 뽑아주기
                                                    ForEach(sheddingSoonGeckos) { gecko in
                                                        HStack {
                                                            Text(gecko.name).font(.subheadline).bold()
                                                            Spacer()
                                                            let dDay = gecko.daysUntilShedding
                                                            Text(dDay > 0 ? "D-\(dDay)" : (dDay == 0 ? "오늘 예정" : "D+\(abs(dDay)) (지연)"))
                                                                .font(.subheadline)
                                                                .bold()
                                                                .foregroundColor(dDay <= 0 ? .red : .orange)
                                                        }
                                                    }
                                                }
                                                .padding()
                                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                                .cornerRadius(16)
                                            }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(16)
                            }
                    
                    // 🌟 카드 2: 사육방 요약 현황 (클릭하면 상세 화면으로 이동!)
                    NavigationLink(destination: MorphStatisticsView(geckos: geckos)) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("나의 사육방 현황 📊")
                                    .font(.headline)
                                    .foregroundColor(.primary) // 글씨가 파란색 링크처럼 변하는 걸 방지
                                Spacer()
                                Text("총 \(geckos.count)마리")
                                    .font(.headline)
                                    .foregroundColor(.indigo)
                                
                                // 👉 누를 수 있다는 힌트를 주는 꺾쇠 아이콘
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Divider()
                            HStack {
                                VStack {
                                    Text("수컷").font(.caption).foregroundColor(.secondary)
                                    Text("\(geckos.filter { $0.gender == .male }.count)").font(.title3).bold().foregroundColor(.primary)
                                }
                                Spacer()
                                VStack {
                                    Text("암컷").font(.caption).foregroundColor(.secondary)
                                    Text("\(geckos.filter { $0.gender == .female }.count)").font(.title3).bold().foregroundColor(.primary)
                                }
                                Spacer()
                                VStack {
                                    Text("미구분").font(.caption).foregroundColor(.secondary)
                                    Text("\(geckos.filter { $0.gender == .unsexed }.count)").font(.title3).bold().foregroundColor(.primary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle()) // 버튼 눌렀을 때 회색으로 번쩍이는 기본 효과 제거
                    
                    
                    // 카드 3: 일괄 피딩 (Quick Feed)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("일괄 피딩 (Quick Feed) ⚡")
                            .font(.headline)
                        Text("버튼 한 번으로 여러 마리에게 동시에 피딩 기록을 남기세요.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                        
                        Button(action: {
                            showingQuickFeed = true
                        }) {
                            Text("일괄 피딩 시작하기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // 카드 4: 인큐베이터 요약
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("보관 중인 알: 0개")
                                .font(.headline)
                            Text("가장 빠른 해칭: 해당 없음")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Éclat Privé")
            .sheet(isPresented: $showingQuickFeed) {
                QuickFeedView()
            }
        }
    }
}
// 📌 3. 개체 관리 탭 (우리가 기존에 만들었던 리스트 화면!)
struct GeckoListView: View {
    @Query(sort: \Gecko.name) private var geckos: [Gecko]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddGecko = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(geckos) { gecko in
                    NavigationLink(destination: GeckoDetailView(gecko: gecko)) {
                        HStack(spacing: 15) {
                            GeckoProfileImage(imageData: gecko.profileImageData)
                                .frame(width: 50, height: 50)

                            VStack(alignment: .leading) {
                                Text(gecko.name)
                                    .font(.headline)
                                Text("\(gecko.morph) | \(gecko.gender.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete(perform: deleteGecko)
            }
            .navigationTitle("개체 관리")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddGecko = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGecko) {
                AddGeckoView()
            }
        }
    }

    private func deleteGecko(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(geckos[index])
        }
    }
}

// 📌 4. 산란실 (인큐베이터) 메인 화면
struct IncubatorView: View {
    // 해칭일이 가장 가까운 순서대로 알을 불러옵니다
    @Query(sort: \EggRecord.expectedHatchDate) private var eggs: [EggRecord]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEgg = false

    var body: some View {
        NavigationStack {
            List {
                // 상태가 '인큐베이팅'인 알들만 모아서 보기
                let incubatingEggs = eggs.filter { $0.status == "인큐베이팅" }
                
                if incubatingEggs.isEmpty {
                    Text("현재 인큐베이터가 비어있습니다. 🥚")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(incubatingEggs) { egg in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(egg.sireName) x \(egg.damName)")
                                    .font(.headline)
                                Text("산란일: \(egg.layDate, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // 🌟 D-Day 자동 계산 로직
                            let dDay = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: egg.expectedHatchDate)).day ?? 0
                            
                            VStack {
                                Text(dDay > 0 ? "D-\(dDay)" : (dDay == 0 ? "D-Day" : "D+\(abs(dDay))"))
                                    .font(.title2)
                                    .bold()
                                    // 5일 이내로 남으면 빨간색으로 경고!
                                    .foregroundColor(dDay <= 5 ? .red : .indigo)
                                Text("해칭 예정")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        // 🌟 리스트를 왼쪽으로 쓱 밀면 '해칭 완료' 처리 가능!
                        .swipeActions(edge: .leading) {
                            Button {
                                egg.status = "해칭 완료"
                            } label: {
                                Label("해칭 완료", systemImage: "party.popper.fill")
                            }
                            .tint(.green)
                        }
                    }
                    .onDelete(perform: deleteEgg)
                }
            }
            .navigationTitle("인큐베이터 🌡️")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddEgg = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEgg) {
                AddEggView()
            }
        }
    }

    private func deleteEgg(offsets: IndexSet) {
        let incubatingEggs = eggs.filter { $0.status == "인큐베이팅" }
        for index in offsets {
            let eggToDelete = incubatingEggs[index]
            modelContext.delete(eggToDelete)
        }
    }
}
// 📌 5. 통계 화면 (개체별 체중 성장 차트 📈)
struct StatisticsView: View {
    // 저장된 모든 개체를 불러옵니다.
    @Query(sort: \Gecko.name) private var geckos: [Gecko]
    
    // 현재 그래프를 보고 있는 개체를 기억하는 변수
    @State private var selectedGecko: Gecko?

    var body: some View {
        NavigationStack {
            VStack {
                if geckos.isEmpty {
                    Text("등록된 개체가 없습니다.")
                        .foregroundColor(.secondary)
                } else {
                    // 🌟 1. 상단 개체 선택 픽커 (드롭다운)
                    Picker("개체 선택", selection: $selectedGecko) {
                        Text("개체를 선택하세요").tag(nil as Gecko?)
                        ForEach(geckos) { gecko in
                            Text(gecko.name).tag(gecko as Gecko?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    if let gecko = selectedGecko {
                        // 체중이 0보다 큰 일지만 날짜순으로 모아줍니다.
                        let logs = gecko.dailyLogs.filter { $0.emptyWeight > 0 }.sorted { $0.date < $1.date }

                        if logs.isEmpty {
                            Spacer()
                            Text("체중 기록이 없습니다.\n사육 일지에서 공복 체중을 기록해 주세요!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            Spacer()
                        } else {
                            // 🌟 2. 하얀색 카드 위에 그려지는 성장 그래프
                            VStack(alignment: .leading) {
                                Text("\(gecko.name)의 성장 그래프 📈")
                                    .font(.headline)
                                    .padding(.bottom, 10)

                                // 애플의 마법! Chart 블록 하나면 끝납니다.
                                Chart {
                                    ForEach(logs, id: \.self) { log in
                                        // 꺾은선 그리기
                                        LineMark(
                                            x: .value("날짜", log.date),
                                            y: .value("체중(g)", log.emptyWeight)
                                        )
                                        .foregroundStyle(Color.indigo)
                                        .interpolationMethod(.monotone) // 선을 부드러운 곡선으로 만들어줌!

                                        // 날짜마다 동그란 점 찍기
                                        PointMark(
                                            x: .value("날짜", log.date),
                                            y: .value("체중(g)", log.emptyWeight)
                                        )
                                        .foregroundStyle(Color.indigo)
                                    }
                                }
                                .frame(height: 300) // 그래프 높이
                                .chartYAxis {
                                    AxisMarks(position: .leading) // Y축 숫자(무게)를 왼쪽에 표시
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .padding()

                            Spacer()
                        }
                    } else {
                        Spacer()
                        Text("위에서 그래프를 볼 개체를 선택해 주세요.")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground)) // 토스 느낌의 회색 배경
            .navigationTitle("성장 통계 📈")
            .onAppear {
                // 화면에 들어왔을 때 자동으로 첫 번째 개체를 선택해 줌
                if selectedGecko == nil, let first = geckos.first {
                    selectedGecko = first
                }
            }
        }
    }
}
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("여기에 브랜드 설정과 보증서 발급 기능이 들어옵니다! ⚙️").navigationTitle("설정")
        }
    }
}

// ---------------------------------------------------------
// 👇 아래는 우리가 기존에 완벽하게 세팅해둔 기능들입니다 (변경 없음!)
// ---------------------------------------------------------

struct GeckoProfileImage: View {
    var imageData: Data?
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage).resizable().scaledToFill().clipShape(Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
        } else {
            ZStack {
                Circle().fill(Color.secondary.opacity(0.1))
                Text("🦎").font(.system(size: 30))
            }
            .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
        }
    }
}

struct GeckoDetailView: View {
    @Bindable var gecko: Gecko
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showingAddLog = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    if let imageData = gecko.profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle())
                            .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 2))
                    } else {
                        ZStack {
                            Circle().fill(Color.secondary.opacity(0.1)).frame(width: 100, height: 100)
                            Text("🦎").font(.system(size: 50))
                        }
                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 2))
                        .overlay(
                            Image(systemName: "camera.circle.fill").resizable().frame(width: 28, height: 28)
                                .foregroundColor(.blue).background(Circle().fill(Color.white)).offset(x: 35, y: 35)
                        )
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task { if let data = try? await newItem?.loadTransferable(type: Data.self) { gecko.profileImageData = data } }
                }
            }
            .padding(.vertical)
            
            List {
                ForEach(gecko.dailyLogs.sorted(by: { $0.date > $1.date })) { log in
                    VStack(alignment: .leading, spacing: 7) {
                        Text(log.date, style: .date).font(.subheadline).foregroundColor(.blue).bold()
                        HStack(alignment: .top) {
                            Text("먹이: \(log.foodType)").fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Text("\(String(format: "%.1f", log.foodAmount))ml").fontWeight(.bold)
                        }
                        .font(.body)
                        HStack {
                            Text("공복: \(String(format: "%.1f", log.emptyWeight))g")
                            Text("|").foregroundColor(.secondary)
                            Text("식후: \(String(format: "%.1f", log.afterWeight))g")
                            Spacer()
                        }
                        .font(.subheadline)
                        if !log.foodMixRatio.isEmpty {
                            HStack {
                                Text("배합 비율:")
                                Text(log.foodMixRatio).fontWeight(.medium).foregroundColor(.indigo)
                                Spacer()
                            }
                            .font(.subheadline)
                        }
                        HStack {
                            Text("온습도: \(String(format: "%.1f", log.amTemp))℃ / \(String(format: "%.0f", log.amHumid))%")
                            Spacer()
                            HStack(spacing: 2) {
                                Text("배변")
                                Text(log.defecation ? "✅" : "❌")
                            }
                        }
                        .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                .onDelete(perform: deleteLog)
            }
        }
        .navigationTitle(gecko.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddLog = true }) { Image(systemName: "square.and.pencil") }
            }
        }
        .sheet(isPresented: $showingAddLog) { AddDailyLogView(gecko: gecko) }
    }
    
    private func deleteLog(offsets: IndexSet) {
        let sortedLogs = gecko.dailyLogs.sorted(by: { $0.date > $1.date })
        for index in offsets {
            let logToDelete = sortedLogs[index]
            if let indexInGecko = gecko.dailyLogs.firstIndex(of: logToDelete) {
                gecko.dailyLogs.remove(at: indexInGecko)
            }
        }
    }
}

// 📌 새 개체 등록 화면 (해칭일 추가)
struct AddGeckoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var morph = ""
    @State private var gender: Gender = .unsexed
    @State private var hatchDate = Date() // 🌟 해칭일 입력 변수
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("이름", text: $name)
                TextField("모프", text: $morph)
                Picker("성별", selection: $gender) {
                    Text("수컷").tag(Gender.male)
                    Text("암컷").tag(Gender.female)
                    Text("미구분").tag(Gender.unsexed)
                }
                // 🌟 해칭일 달력 추가!
                DatePicker("해칭일 (나이 계산용)", selection: $hatchDate, displayedComponents: .date)
            }
            .navigationTitle("새 개체 등록")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let newGecko = Gecko(name: name, morph: morph, gender: gender, hatchDate: hatchDate) // 해칭일 저장
                        modelContext.insert(newGecko)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddDailyLogView: View {
    @Environment(\.dismiss) var dismiss
    var gecko: Gecko
    let availableFoods = ["게코 뉴트리션 하이인섹트", "인섹트파이", "G- rap 인섹트", "크레팍스 칼슘"]
    @State private var selectedFoods: Set<String> = []
    @State private var foodMixRatio: String = ""
    @State private var foodAmountText: String = ""
    @State private var emptyWeightText: String = ""
    @State private var afterWeightText: String = ""
    @State private var feedingMethod: String = "핸드 피딩"
    @State private var date: Date = Date()
    @State private var amTemp: Double = 23.0
    @State private var amHumid: Double = 60.0
    @State private var defecation: Bool = false
    @State private var isCleaned: Bool = false
    @State private var sheddingStatus = "없음" // 🌟 탈피 상태 저장용
        let sheddingOptions = ["없음", "징후 보임", "탈피 완료", "탈피 부전"]
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("기본 정보")) { DatePicker("날짜", selection: $date, displayedComponents: .date) }
                Section(header: Text("먹이 종류 (중복 선택 가능)")) {
                    ForEach(availableFoods, id: \.self) { food in
                        Button(action: {
                            if selectedFoods.contains(food) {
                                selectedFoods.remove(food)
                            } else {
                                selectedFoods.insert(food)
                            }
                        }) {
                            HStack {
                                Text(food).foregroundColor(.primary)
                                Spacer()
                                if selectedFoods.contains(food) { Image(systemName: "checkmark").foregroundColor(.blue).bold() }
                            }
                        }
                    }
                    if selectedFoods.count >= 2 { TextField("배합 비율 입력 (예: 1:1, 2:1:1)", text: $foodMixRatio) }
                }
                Section(header: Text("급여 상세")) {
                    HStack { Text("급여량 (ml)"); Spacer(); TextField("입력", text: $foodAmountText).keyboardType(.decimalPad).multilineTextAlignment(.trailing) }
                    Picker("피딩 방법", selection: $feedingMethod) { Text("핸드 피딩").tag("핸드 피딩"); Text("자율").tag("자율") }.pickerStyle(.segmented)
                }
                Section(header: Text("체중 변화")) {
                    HStack { Text("공복 체중 (g)"); Spacer(); TextField("입력", text: $emptyWeightText).keyboardType(.decimalPad).multilineTextAlignment(.trailing) }
                    HStack { Text("식후 체중 (g)"); Spacer(); TextField("입력", text: $afterWeightText).keyboardType(.decimalPad).multilineTextAlignment(.trailing) }
                }
                Section(header: Text("탈피 상태")) {
                    Picker("상태 선택", selection: $sheddingStatus) {
                        ForEach(sheddingOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("오전 환경 및 체크")) {
                    VStack(alignment: .leading) { Text("온도 (℃): \(String(format: "%.1f", amTemp))"); Slider(value: $amTemp, in: 15...35, step: 0.5) }
                    VStack(alignment: .leading) { Text("습도 (%): \(String(format: "%.0f", amHumid))"); Slider(value: $amHumid, in: 30...90, step: 1) }
                    Toggle("💩 배변 여부", isOn: $defecation)
                    Toggle("✨ 사육장 청소", isOn: $isCleaned)
                }
            }
            .navigationTitle("일지 작성")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let finalFoodType = selectedFoods.sorted().joined(separator: ", ")
                        gecko.dailyLogs.append(DailyLog(
                                                date: date,
                                                emptyWeight: Double(emptyWeightText) ?? 0.0,
                                                afterWeight: Double(afterWeightText) ?? 0.0,
                                                foodType: finalFoodType,
                                                foodAmount: Double(foodAmountText) ?? 0.0,
                                                foodMixRatio: selectedFoods.count >= 2 ? foodMixRatio : "",
                                                feedingMethod: feedingMethod,
                                                amTemp: amTemp,
                                                amHumid: amHumid,
                                                defecation: defecation,
                                                isCleaned: isCleaned,
                                                sheddingStatus: sheddingStatus // 🌟 우리가 만든 탈피 상태 추가!
                                            ))
                        dismiss()
                    }
                }
            }
        }
    }
}

// 📌 6. 일괄 피딩 (Quick Feed) 전용 화면
struct QuickFeedView: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Gecko.name) private var geckos: [Gecko] // 모든 개체 불러오기
    
    // 🌟 선택된 개체들을 담아둘 바구니
    @State private var selectedGeckos: Set<Gecko> = []
    
    let availableFoods = ["게코 뉴트리션 하이인섹트", "인섹트파이", "G- rap 인섹트", "크레팍스 칼슘"]
    @State private var selectedFoods: Set<String> = []
    @State private var foodMixRatio: String = ""
    
    @State private var foodAmountText: String = ""
    @State private var feedingMethod: String = "핸드 피딩"
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                // 1. 누구에게 줄 건지 체크박스로 선택
                Section(header: Text("1. 대상 개체 선택 (여러 마리 선택 가능)")) {
                    ForEach(geckos) { gecko in
                        Button(action: {
                            if selectedGeckos.contains(gecko) {
                                selectedGeckos.remove(gecko)
                            } else {
                                selectedGeckos.insert(gecko)
                            }
                        }) {
                            HStack {
                                Text(gecko.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                // 선택 여부에 따라 체크 동그라미 표시
                                if selectedGeckos.contains(gecko) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.indigo)
                                        .font(.title3)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                        .font(.title3)
                                }
                            }
                        }
                    }
                }
                
                // 2. 먹이 종류 선택 (기존과 동일)
                Section(header: Text("2. 먹이 종류 (중복 선택 가능)")) {
                    ForEach(availableFoods, id: \.self) { food in
                        Button(action: {
                            if selectedFoods.contains(food) {
                                selectedFoods.remove(food)
                            } else {
                                selectedFoods.insert(food)
                            }
                        }) {
                            HStack {
                                Text(food).foregroundColor(.primary)
                                Spacer()
                                if selectedFoods.contains(food) {
                                    Image(systemName: "checkmark").foregroundColor(.blue).bold()
                                }
                            }
                        }
                    }
                    if selectedFoods.count >= 2 {
                        TextField("배합 비율 입력 (예: 1:1, 2:1:1)", text: $foodMixRatio)
                    }
                }
                
                // 3. 급여량 및 방법 (일괄 피딩이므로 체중/온도 측정은 생략하여 속도를 높임)
                Section(header: Text("3. 급여 상세")) {
                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                    HStack {
                        Text("공통 급여량 (ml)")
                        Spacer()
                        TextField("입력", text: $foodAmountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("피딩 방법", selection: $feedingMethod) {
                        Text("핸드 피딩").tag("핸드 피딩")
                        Text("자율").tag("자율")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("일괄 피딩 ⚡")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("일괄 저장") {
                        saveQuickFeed()
                    }
                    // 개체와 먹이를 최소 1개 이상 선택해야 저장 가능!
                    .disabled(selectedGeckos.isEmpty || selectedFoods.isEmpty)
                }
            }
        }
    }
    
    // 💾 마법의 일괄 저장 함수!
    private func saveQuickFeed() {
        let finalFoodType = selectedFoods.sorted().joined(separator: ", ")
        let amount = Double(foodAmountText) ?? 0.0
        
        // 선택된 '모든' 개체들의 가방을 열어서 똑같은 일지를 하나씩 넣어줍니다.
        for gecko in selectedGeckos {
            let newLog = DailyLog(
                                date: date,
                                emptyWeight: 0.0,
                                afterWeight: 0.0,
                                foodType: finalFoodType,
                                foodAmount: amount,
                                foodMixRatio: selectedFoods.count >= 2 ? foodMixRatio : "",
                                feedingMethod: feedingMethod,
                                amTemp: 0.0,
                                amHumid: 0.0,
                                defecation: false,
                                isCleaned: false,
                                sheddingStatus: "없음" // 🌟 일괄 피딩이므로 탈피 상태는 기본값("없음")으로 패스!
                            )
            gecko.dailyLogs.append(newLog)
        }
        dismiss()
    }
}

// 📌 7. 모프별 현황 상세 화면 (카드 2를 누르면 나오는 화면)
struct MorphStatisticsView: View {
    // 홈 화면에서 넘겨받은 개체 전체 데이터
    var geckos: [Gecko]
    
    // 🌟 흩어져 있는 개체들을 '모프' 이름으로 묶고, 개수를 세어주는 스마트한 컴퓨터!
    var morphCounts: [(morph: String, count: Int)] {
        // 1. 모프별로 그룹을 묶고 마리수를 센다.
        let counts = Dictionary(grouping: geckos, by: { $0.morph }).mapValues { $0.count }
        
        // 2. 가장 마리수가 많은 모프가 맨 위에 오도록 내림차순 정렬한다.
        return counts.map { (morph: $0.key, count: $0.value) }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        List {
            Section(header: Text("모프별 보유 현황")) {
                // 모프 종류가 아예 없을 때
                if morphCounts.isEmpty {
                    Text("등록된 개체가 없습니다.")
                        .foregroundColor(.secondary)
                } else {
                    // 계산된 모프 리스트를 하나씩 화면에 뿌려줌!
                    ForEach(morphCounts, id: \.morph) { item in
                        HStack {
                            Text(item.morph) // 예: "아잔틱"
                                .font(.body)
                            Spacer()
                            Text("\(item.count)마리") // 예: "3마리"
                                .fontWeight(.bold)
                                .foregroundColor(.indigo)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("사육방 상세 현황")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// 📌 8. 새 알 등록 화면
struct AddEggView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var sireName: String = ""
    @State private var damName: String = ""
    @State private var layDate: Date = Date()
    
    // 🌟 크레는 보통 60일 전후로 해칭하므로, 기본값을 오늘 기준 +60일로 셋팅해 둠!
    @State private var expectedHatchDate: Date = Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("부모 정보 (페어링)")) {
                    TextField("아빠 (Sire) 이름", text: $sireName)
                    TextField("엄마 (Dam) 이름", text: $damName)
                }
                
                Section(header: Text("날짜 정보")) {
                    DatePicker("산란일", selection: $layDate, displayedComponents: .date)
                        .onChange(of: layDate) { _, newDate in
                            // 산란일을 바꾸면, 해칭 예정일도 자동으로 +60일 뒤로 스르륵 바뀜!
                            expectedHatchDate = Calendar.current.date(byAdding: .day, value: 60, to: newDate) ?? newDate
                        }
                    DatePicker("해칭 예정일", selection: $expectedHatchDate, displayedComponents: .date)
                }
            }
            .navigationTitle("새 알 등록 🥚")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        let newEgg = EggRecord(sireName: sireName, damName: damName, layDate: layDate, expectedHatchDate: expectedHatchDate)
                        modelContext.insert(newEgg)
                        dismiss()
                    }
                    .disabled(sireName.isEmpty || damName.isEmpty)
                }
            }
        }
    }
}
