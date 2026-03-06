import Foundation

class AIServiceManager {
    static let shared = AIServiceManager()
    
    private init() {}
    
    /// 향후 AI 분석을 통해 개체의 성장 및 사육 데이터를 기반으로 Insight를 제공하는 함수
    /// 현재는 로컬 데이터를 바탕으로 한 스마트 룰 기반(Rule-based) 분석을 제공합니다.
    func analyzeGeckoData(gecko: Gecko) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 가상의 분석 시간 1초
        
        // 데이터가 없는 경우
        let logs = gecko.dailyLogs.sorted { $0.date < $1.date }
        guard !logs.isEmpty else {
            return "기록된 데이터가 부족하여 분석할 수 없습니다. 꾸준히 일지를 기록해주세요!"
        }
        
        var adviceParts: [String] = []
        let lastLog = logs.last!
        
        // 1. 체중 정체기 체크 (최근 3번의 기록)
        if logs.count >= 3 {
            let recentLogs = Array(logs.suffix(3))
            let weight1 = recentLogs[0].emptyWeight
            let weight2 = recentLogs[1].emptyWeight
            let weight3 = recentLogs[2].emptyWeight
            
            if weight1 > 0 && weight2 > 0 && weight3 > 0,
               abs(weight3 - weight1) <= 0.5 {
                adviceParts.append("현재 체중 정체기일 수 있습니다. 먹이 종류를 변경해보거나 피딩 간격을 조절하여 식욕을 자극해보세요.")
            } else if weight3 < weight1 {
                adviceParts.append("최근 공복 체중이 꾸준히 감소하고 있습니다. 온도와 스트레스 요인을 점검하고, 필요시 수의사 검진을 권장합니다.")
            }
        }
        
        // 2. 온도/습도 체크 (마지막 기록 기준)
        if lastLog.amHumid < 40 {
            adviceParts.append("현재 사육장 습도가 너무 낮아 탈피 부전이 올 수 있으니 분무량을 늘려 60~70% 선을 유지해주세요.")
        } else if lastLog.amHumid > 80 {
            adviceParts.append("현재 사육장 습도가 너무 높습니다. 환기를 통해 곰팡이 및 호흡기 질환을 예방하세요.")
        }
        
        if lastLog.amTemp < 20 {
            adviceParts.append("온도가 평균보다 낮아 소화 불량이 발생할 수 있습니다. 바닥망이나 상부 열원을 확인해주세요.")
        } else if lastLog.amTemp > 30 {
            adviceParts.append("온도가 너무 높아 개체가 스트레스를 받을 수 있습니다. 서늘하게 유지해주세요.")
        }
        
        // 3. 탈피 임박 체크
        if gecko.daysUntilShedding <= 3 && gecko.daysUntilShedding > 0 {
            adviceParts.append("며칠 내로 탈피가 예상됩니다. 건조하지 않게 습식 은신처를 제공해주세요.")
        }
        
        // 총평 조합
        if adviceParts.isEmpty {
            return "상태: 매우 건강함. 체중 밸런스와 사육 환경 모두 훌륭합니다. 지금처럼 꾸준히 케어해주세요!"
        } else {
            return "💡 AI 수의사 조언:\n" + adviceParts.map { "• \($0)" }.joined(separator: "\n")
        }
    }
}
