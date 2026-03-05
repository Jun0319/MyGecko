import Foundation
import SwiftData

class CSVExportManager {
    static let shared = CSVExportManager()
    
    private init() {}
    
    func generateCSV(for geckos: [Gecko]) -> URL? {
        var csvString = "개체명,성별,모프,기록일자,먹이종류,급여량(ml),공복체중(g),식후체중(g),온도(℃),습도(%),배변여부,탈피상태\n"
        
        for gecko in geckos {
            let sortedLogs = gecko.dailyLogs.sorted { $0.date > $1.date }
            for log in sortedLogs {
                let dateStr = log.date.formatted(date: .numeric, time: .omitted)
                let defecationStr = log.defecation ? "O" : "X"
                
                let row = "\(gecko.name),\(gecko.gender.rawValue),\(gecko.morph),\(dateStr),\(log.foodType),\(log.foodAmount),\(log.emptyWeight),\(log.afterWeight),\(log.amTemp),\(log.amHumid),\(defecationStr),\(log.sheddingStatus)\n"
                csvString.append(row)
            }
        }
        
        let fileName = "Eclat_Prive_Data_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Write with BOM for Excel compatibility (UTF-8)
            var dataInfo = Data([0xEF, 0xBB, 0xBF])
            if let csvData = csvString.data(using: .utf8) {
                dataInfo.append(csvData)
                try dataInfo.write(to: fileURL, options: .atomic)
                return fileURL
            }
        } catch {
            print("CSV 파일 쓰기 실패: \(error)")
        }
        
        return nil
    }
}
