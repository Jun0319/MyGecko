import SwiftUI

struct EditDailyLogView: View {
    @Environment(\.dismiss) var dismiss
    var log: DailyLog // 🌟 추가 화면과 다르게 '수정할 일지' 데이터를 통째로 받아옵니다!
    
    let availableFoods = ["게코 뉴트리션 하이인섹트", "인섹트파이", "G- rap 인섹트", "크레팍스 칼슘"]
    
    // 빈 보관함들 (화면이 켜질 때 기존 데이터로 채워질 예정입니다)
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
    @State private var sheddingStatus = "없음"
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
            .navigationTitle("일지 수정") // 타이틀 변경
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("수정 완료") {
                        // 🌟 새로 추가하는 게 아니라, 기존 log의 정보를 덮어씌웁니다!
                        log.date = date
                        log.emptyWeight = Double(emptyWeightText) ?? 0.0
                        log.afterWeight = Double(afterWeightText) ?? 0.0
                        log.foodType = selectedFoods.sorted().joined(separator: ", ")
                        log.foodAmount = Double(foodAmountText) ?? 0.0
                        log.foodMixRatio = selectedFoods.count >= 2 ? foodMixRatio : ""
                        log.feedingMethod = feedingMethod
                        log.amTemp = amTemp
                        log.amHumid = amHumid
                        log.defecation = defecation
                        log.isCleaned = isCleaned
                        log.sheddingStatus = sheddingStatus
                        
                        dismiss()
                    }
                }
            }
            // 🪄 화면이 켜질 때 기존 데이터를 미리 채워주는 마법의 코드!
            .onAppear {
                date = log.date
                emptyWeightText = log.emptyWeight == 0 ? "" : String(log.emptyWeight)
                afterWeightText = log.afterWeight == 0 ? "" : String(log.afterWeight)
                foodAmountText = log.foodAmount == 0 ? "" : String(log.foodAmount)
                foodMixRatio = log.foodMixRatio
                feedingMethod = log.feedingMethod
                amTemp = log.amTemp
                amHumid = log.amHumid
                defecation = log.defecation
                isCleaned = log.isCleaned
                sheddingStatus = log.sheddingStatus
                
                // "음식1, 음식2" 처럼 저장된 텍스트를 다시 분리해서 체크 표시 띄우기
                let foodsArray = log.foodType.components(separatedBy: ", ")
                selectedFoods = Set(foodsArray.filter { !$0.isEmpty })
            }
        }
    }
}
