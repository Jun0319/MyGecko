import SwiftData
import Foundation

enum Gender: String, Codable {
    case male = "수컷"
    case female = "암컷"
    case unsexed = "미구분"
}

@Model
final class Gecko {
    var id: UUID
    var name: String
    var morph: String
    var gender: Gender
    var hatchDate: Date // 🌟 핵심 1: 나이 계산을 위한 해칭일 추가!
    var profileImageData: Data? = nil
    
    @Relationship(deleteRule: .cascade) var dailyLogs: [DailyLog]
    
    init(name: String, morph: String, gender: Gender, hatchDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.morph = morph
        self.gender = gender
        self.hatchDate = hatchDate
        self.dailyLogs = []
    }
    
    // 🧠 [스마트 로직 1] 현재 나이(개월 수) 자동 계산 (@Transient는 DB에 저장하지 않고 실시간 계산만 하겠다는 뜻!)
    @Transient var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: hatchDate, to: Date()).month ?? 0
    }
    
    // 🧠 [스마트 로직 2] 연령별 맞춤 탈피 주기 (베이비 14일, 아성체 28일, 성체 40일)
    @Transient var sheddingCycleDays: Int {
        if ageInMonths < 3 { return 14 }
        else if ageInMonths < 10 { return 28 }
        else { return 40 }
    }
    
    // 🧠 [스마트 로직 3] 마지막으로 "탈피 완료"를 찍은 날짜 찾기 (기록이 없으면 해칭일 기준)
    @Transient var lastSheddingDate: Date {
        let completeLogs = dailyLogs.filter { $0.sheddingStatus == "탈피 완료" }
        return completeLogs.max(by: { $0.date < $1.date })?.date ?? hatchDate
    }
    
    // 🧠 [스마트 로직 4] 다음 예정일 = 마지막 탈피일 + 맞춤 주기
    @Transient var nextSheddingDate: Date {
        Calendar.current.date(byAdding: .day, value: sheddingCycleDays, to: lastSheddingDate) ?? Date()
    }
    
    // 🧠 [스마트 로직 5] D-Day 남은 날짜 계산
    @Transient var daysUntilShedding: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextSheddingDate)).day ?? 0
    }
}

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    
    // 🌟 브리더님의 디테일한 기록 공간 복구!
    var emptyWeight: Double
    var afterWeight: Double
    var foodType: String
    var foodAmount: Double
    var foodMixRatio: String
    var feedingMethod: String
    var amTemp: Double
    var amHumid: Double
    var defecation: Bool
    var isCleaned: Bool
    
    // 🌟 이번에 새로 추가한 스마트 탈피 상태
    var sheddingStatus: String
    
    init(date: Date = Date(),
         emptyWeight: Double = 0.0,
         afterWeight: Double = 0.0,
         foodType: String = "",
         foodAmount: Double = 0.0,
         foodMixRatio: String = "",
         feedingMethod: String = "핸드 피딩",
         amTemp: Double = 23.0,
         amHumid: Double = 60.0,
         defecation: Bool = false,
         isCleaned: Bool = false,
         sheddingStatus: String = "없음") {
        
        self.id = UUID()
        self.date = date
        self.emptyWeight = emptyWeight
        self.afterWeight = afterWeight
        self.foodType = foodType
        self.foodAmount = foodAmount
        self.foodMixRatio = foodMixRatio
        self.feedingMethod = feedingMethod
        self.amTemp = amTemp
        self.amHumid = amHumid
        self.defecation = defecation
        self.isCleaned = isCleaned
        self.sheddingStatus = sheddingStatus
    }
}

// 📌 인큐베이터(산란실)에 보관 중인 알 모델
@Model
final class EggRecord {
    var id: UUID
    var sireName: String // 아빠 개체 (Sire)
    var damName: String  // 엄마 개체 (Dam)
    var layDate: Date    // 산란일
    var expectedHatchDate: Date // 해칭 예정일
    var status: String   // 상태 (예: "인큐베이팅", "해칭 완료")
    
    init(sireName: String, damName: String, layDate: Date = Date(), expectedHatchDate: Date, status: String = "인큐베이팅") {
        self.id = UUID()
        self.sireName = sireName
        self.damName = damName
        self.layDate = layDate
        self.expectedHatchDate = expectedHatchDate
        self.status = status
    }
}
