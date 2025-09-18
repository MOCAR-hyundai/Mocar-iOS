import Foundation
import SwiftUI

final class SearchDetailViewModel: ObservableObject {
    struct MakerSummary: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
        let imageName: String
    }
    
    struct ModelSummary: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
    }
    
    @Published var selectedMaker: String?
    @Published var selectedModel: String?
    @Published var recentKeyword: String = ""
    @Published var recentSearches: [String] = []
    @Published var recentKeywords: [String] = []
    @Published var minPrice: Int
    @Published var maxPrice: Int
    @Published var minYear: Int
    @Published var maxYear: Int
    @Published var minMileage: Int
    @Published var maxMileage: Int
    @Published var fuelOptions: [CheckableItem]
    @Published var areaOptions: [CheckableItem]
    @Published var carTypeOptions: [CheckableItem]
    
    let priceRange: ClosedRange<Int> = 0...10000
    let mileageRange: ClosedRange<Int> = 0...200000
    let yearRange: ClosedRange<Int>
    
    private let makerImages: [String: String] = [
        "현대": "hyundai 1",
        "제네시스": "genesis",
        "기아": "kia",
        "르노코리아": "renault",
        "쉐보레": "chevrolet",
        "벤츠": "benz",
        "BMW": "BMW",
        "아우디": "audi",
        "테슬라": "tesla",
        "페라리": "ferrari"
    ]
    
    private(set) var allCars: [SearchCar]
    private let makerToModels: [String: [String]]
    
    private enum FilterDimension: Hashable {
        case carType
        case fuel
        case area
    }
    
    init() {
        allCars = SearchMockData.cars
        var grouped: [String: Set<String>] = [:]
        for car in allCars {
            grouped[car.maker, default: []].insert(car.model)
        }
        makerToModels = grouped.mapValues { Array($0).sorted() }
        let currentYear = Calendar.current.component(.year, from: Date())
        let lowerYear = max(currentYear - 20, 2006)
        yearRange = lowerYear...currentYear
        minPrice = priceRange.lowerBound
        maxPrice = priceRange.upperBound
        minYear = lowerYear
        maxYear = yearRange.upperBound
        minMileage = mileageRange.lowerBound
        maxMileage = mileageRange.upperBound
        fuelOptions = [
            CheckableItem(name: "가솔린(휘발유)", checked: false),
            CheckableItem(name: "디젤(경유)", checked: false),
            CheckableItem(name: "전기", checked: false),
            CheckableItem(name: "LPG", checked: false),
            CheckableItem(name: "하이브리드", checked: false)
        ]
        areaOptions = [
            CheckableItem(name: "서울", checked: false),
            CheckableItem(name: "인천", checked: false),
            CheckableItem(name: "대전", checked: false),
            CheckableItem(name: "대구", checked: false),
            CheckableItem(name: "광주", checked: false),
            CheckableItem(name: "부산", checked: false),
            CheckableItem(name: "울산", checked: false),
            CheckableItem(name: "세종", checked: false),
            CheckableItem(name: "경기", checked: false),
            CheckableItem(name: "강원", checked: false),
            CheckableItem(name: "경남", checked: false),
            CheckableItem(name: "경북", checked: false),
            CheckableItem(name: "전남", checked: false),
            CheckableItem(name: "전북", checked: false),
            CheckableItem(name: "충남", checked: false),
            CheckableItem(name: "충북", checked: false),
            CheckableItem(name: "제주", checked: false)
        ]
        carTypeOptions = [
            CheckableItem(name: "경차", checked: false),
            CheckableItem(name: "소형", checked: false),
            CheckableItem(name: "준중형", checked: false),
            CheckableItem(name: "중형", checked: false),
            CheckableItem(name: "대형", checked: false),
            CheckableItem(name: "스포츠카", checked: false),
            CheckableItem(name: "SUV", checked: false),
            CheckableItem(name: "RV", checked: false),
            CheckableItem(name: "승합", checked: false),
            CheckableItem(name: "트럭", checked: false),
            CheckableItem(name: "버스", checked: false)
        ]
    }
    
    var filteredCars: [SearchCar] {
        allCars.filter { matches($0) }
    }
    
    var filteredCount: Int { filteredCars.count }
    
    var makerSummaries: [MakerSummary] {
        var counts: [String: Int] = [:]
        for car in allCars where matches(car, ignoreMaker: true, ignoreModel: true) {
            counts[car.maker, default: 0] += 1
        }
        let makers = makerToModels.keys.sorted()
        return makers.map { maker in
            MakerSummary(name: maker, count: counts[maker] ?? 0, imageName: makerImages[maker] ?? "hyundai 1")
        }
        .sorted { left, right in
            if left.count == right.count {
                return left.name < right.name
            }
            return left.count > right.count
        }
    }

    func models(for maker: String) -> [ModelSummary] {
        var counts: [String: Int] = [:]
        for car in allCars where car.maker == maker {
            if matches(car, ignoreModel: true) {
                counts[car.model, default: 0] += 1
            }
        }
        let base = makerToModels[maker] ?? []
        let summaries = base.map { name in
            ModelSummary(name: name, count: counts[name] ?? 0)
        }
        return summaries.sorted { $0.name < $1.name }
    }
    
    func countForCarType(_ name: String) -> Int {
        allCars.filter { $0.category == name && matches($0, ignoring: [.carType]) }.count
    }
    
    func countForFuel(_ name: String) -> Int {
        allCars.filter { $0.fuel == name && matches($0, ignoring: [.fuel]) }.count
    }
    
    func countForArea(_ name: String) -> Int {
        allCars.filter { $0.area == name && matches($0, ignoring: [.area]) }.count
    }

    func selectMaker(_ maker: String) {
        guard selectedMaker != maker else { return }
        selectedMaker = maker
        if let model = selectedModel, models(for: maker).contains(where: { $0.name == model }) == false {
            selectedModel = nil
        }
    }
    
    func selectModel(_ model: String, for maker: String) {
        if selectedMaker != maker {
            selectedMaker = maker
            selectedModel = model
            return
        }
        if selectedModel == model {
            selectedModel = nil
        } else {
            selectedModel = model
        }
    }
    
    func clearMaker() {
        selectedMaker = nil
        selectedModel = nil
    }
    
    func clearModel() {
        selectedModel = nil
    }
    
    func hasActiveFilters(for category: String) -> Bool {
        switch category {
        case "제조사":
            return selectedMaker != nil || selectedModel != nil
        case "가격":
            return minPrice > priceRange.lowerBound || maxPrice < priceRange.upperBound
        case "연식":
            return minYear > yearRange.lowerBound || maxYear < yearRange.upperBound
        case "주행거리":
            return minMileage > mileageRange.lowerBound || maxMileage < mileageRange.upperBound
        case "차종":
            return !selectedCarTypes.isEmpty
        case "연료":
            return !selectedFuels.isEmpty
        case "지역":
            return !selectedAreas.isEmpty
        default:
            return false
        }
    }
    
    func resetFilters() {
        selectedMaker = nil
        selectedModel = nil
        minPrice = priceRange.lowerBound
        maxPrice = priceRange.upperBound
        minYear = yearRange.lowerBound
        maxYear = yearRange.upperBound
        minMileage = mileageRange.lowerBound
        maxMileage = mileageRange.upperBound
        fuelOptions = fuelOptions.map { CheckableItem(name: $0.name, checked: false) }
        areaOptions = areaOptions.map { CheckableItem(name: $0.name, checked: false) }
        carTypeOptions = carTypeOptions.map { CheckableItem(name: $0.name, checked: false) }
    }
    
    private var selectedFuels: Set<String> {
        Set(fuelOptions.filter { $0.checked }.map { $0.name })
    }
    
    private var selectedAreas: Set<String> {
        Set(areaOptions.filter { $0.checked }.map { $0.name })
    }
    
    private var selectedCarTypes: Set<String> {
        Set(carTypeOptions.filter { $0.checked }.map { $0.name })
    }

    func debugLogAppliedFilters() {
        let maker = selectedMaker ?? "없음"
        let model = selectedModel ?? "없음"
        let fuels = Array(selectedFuels).sorted()
        let areas = Array(selectedAreas).sorted()
        let carTypes = Array(selectedCarTypes).sorted()
        let searchKeyword = recentKeyword.isEmpty ? "없음" : recentKeyword

        print("===== 검색 필터 =====")
        print("검색어: \(searchKeyword)")
        print("제조사: \(maker)")
        print("모델: \(model)")
        print("가격: \(minPrice)만원 ~ \(maxPrice)만원")
        print("연식: \(minYear)년 ~ \(maxYear)년")
        print("주행거리: \(minMileage)km ~ \(maxMileage)km")
        print("연료: \(fuels.isEmpty ? "없음" : fuels.joined(separator: ", "))")
        print("지역: \(areas.isEmpty ? "없음" : areas.joined(separator: ", "))")
        print("차종: \(carTypes.isEmpty ? "없음" : carTypes.joined(separator: ", "))")
        print("총 결과 수: \(filteredCount)")
        print("====================")
    }

    func addRecentSearch(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0 == trimmed }
        recentSearches.insert(trimmed, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }

    func addRecentKeyword(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentKeywords.removeAll { $0 == trimmed }
        recentKeywords.insert(trimmed, at: 0)
        if recentKeywords.count > 10 {
            recentKeywords = Array(recentKeywords.prefix(10))
        }
    }

    func removeRecentSearch(_ summary: String) {
        recentSearches.removeAll { $0 == summary }
    }

    func removeRecentKeyword(_ keyword: String) {
        recentKeywords.removeAll { $0 == keyword }
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
    }

    func clearRecentKeywords() {
        recentKeywords.removeAll()
    }

    func saveCurrentFiltersAsRecent() {
        var parts: [String] = []
        if let maker = selectedMaker {
            if let model = selectedModel {
                parts.append("제조사: \(maker) / 모델: \(model)")
            } else {
                parts.append("제조사: \(maker)")
            }
        }
        if minPrice > priceRange.lowerBound || maxPrice < priceRange.upperBound {
            parts.append("가격: \(minPrice)-\(maxPrice)")
        }
        if minYear > yearRange.lowerBound || maxYear < yearRange.upperBound {
            parts.append("연식: \(minYear)-\(maxYear)")
        }
        if minMileage > mileageRange.lowerBound || maxMileage < mileageRange.upperBound {
            parts.append("주행: \(minMileage)-\(maxMileage)km")
        }
        let carTypes = Array(selectedCarTypes).sorted()
        if !carTypes.isEmpty {
            parts.append("차종: \(carTypes.joined(separator: ", "))")
        }
        let fuels = Array(selectedFuels).sorted()
        if !fuels.isEmpty {
            parts.append("연료: \(fuels.joined(separator: ", "))")
        }

        let summary = parts.joined(separator: " | ")
        addRecentSearch(summary)
    }

    func applyRecentSearch(_ summary: String) {
        resetFilters()

        let parts = summary.components(separatedBy: " | ")
        for part in parts {
            if part.hasPrefix("차종:") {
                let value = part.replacingOccurrences(of: "차종:", with: "").trimmingCharacters(in: .whitespaces)
                let names = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                carTypeOptions = carTypeOptions.map { item in
                    CheckableItem(name: item.name, checked: names.contains(item.name))
                }
            } else if part.hasPrefix("제조사:") {
                let rest = part.replacingOccurrences(of: "제조사:", with: "").trimmingCharacters(in: .whitespaces)
                if rest.contains("/ 모델:") {
                    let comps = rest.components(separatedBy: "/ 모델:")
                    let maker = comps[0].trimmingCharacters(in: .whitespaces)
                    let model = comps[1].trimmingCharacters(in: .whitespaces)
                    selectedMaker = maker
                    selectedModel = model
                } else {
                    selectedMaker = rest
                }
            } else if part.hasPrefix("가격:") {
                let rest = part.replacingOccurrences(of: "가격:", with: "").trimmingCharacters(in: .whitespaces)
                let nums = rest.components(separatedBy: "-")
                if nums.count == 2, let a = Int(nums[0]), let b = Int(nums[1]) {
                    minPrice = a
                    maxPrice = b
                }
            } else if part.hasPrefix("연식:") {
                let rest = part.replacingOccurrences(of: "연식:", with: "").trimmingCharacters(in: .whitespaces)
                let nums = rest.components(separatedBy: "-")
                if nums.count == 2, let a = Int(nums[0]), let b = Int(nums[1]) {
                    minYear = a
                    maxYear = b
                }
            } else if part.hasPrefix("주행:") {
                var rest = part.replacingOccurrences(of: "주행:", with: "").trimmingCharacters(in: .whitespaces)
                rest = rest.replacingOccurrences(of: "km", with: "")
                let nums = rest.components(separatedBy: "-")
                if nums.count == 2, let a = Int(nums[0]), let b = Int(nums[1]) {
                    minMileage = a
                    maxMileage = b
                }
            } else if part.hasPrefix("연료:") {
                let rest = part.replacingOccurrences(of: "연료:", with: "").trimmingCharacters(in: .whitespaces)
                let fuels = rest.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                fuelOptions = fuelOptions.map { item in
                    CheckableItem(name: item.name, checked: fuels.contains(item.name))
                }
            }
        }
    }

    private func matches(
        _ car: SearchCar,
        ignoring dimensions: Set<FilterDimension> = [],
        ignoreMaker: Bool = false,
        ignoreModel: Bool = false
    ) -> Bool {
        if !ignoreMaker, let maker = selectedMaker, car.maker != maker {
            return false
        }
        if !ignoreModel, let model = selectedModel, car.model != model {
            return false
        }
        if car.price < minPrice || car.price > maxPrice {
            return false
        }
        if car.year < minYear || car.year > maxYear {
            return false
        }
        if car.mileage < minMileage || car.mileage > maxMileage {
            return false
        }
        if !dimensions.contains(.fuel) && !selectedFuels.isEmpty && !selectedFuels.contains(car.fuel) {
            return false
        }
        if !dimensions.contains(.area) && !selectedAreas.isEmpty && !selectedAreas.contains(car.area) {
            return false
        }
        if !dimensions.contains(.carType) && !selectedCarTypes.isEmpty && !selectedCarTypes.contains(car.category) {
            return false
        }
        return true
    }

    func searchCars(keyword: String) -> [SearchCar] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return [] }
        let lowered = trimmed.lowercased()
        return allCars.filter { car in
            car.model.lowercased().contains(lowered)
        }
    }
}
