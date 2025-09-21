import Foundation
import SwiftUI

@MainActor
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
    
    struct TrimSummary: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
    }

    @Published var selectedMaker: String?
    @Published var selectedModel: String?
    @Published var selectedTrim: String?
    @Published var selectedTrims: Set<String> = []
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
    @Published var isLoading: Bool = false
    @Published var loadErrorMessage: String?
    
    let priceRange: ClosedRange<Int> = 0...10000
    let mileageRange: ClosedRange<Int> = 0...300000
    let yearRange: ClosedRange<Int>
    
    private let makerImages: [String: String] = [
        "현대": "hyundai 1",
        "hyundai": "hyundai 1",
        "제네시스": "genesis",
        "genesis": "genesis",
        "기아": "kia",
        "kia": "kia",
        "르노코리아": "renault",
        "renault": "renault",
        "쉐보레": "chevrolet",
        "chevrolet": "chevrolet",
        "벤츠": "benz",
        "mercedes-benz": "benz",
        "bmw": "BMW",
        "아우디": "audi",
        "audi": "audi",
        "테슬라": "tesla",
        "tesla": "tesla",
        "페라리": "ferrari",
        "ferrari": "ferrari"
    ]
    
    private(set) var allCars: [SearchCar]
    private var makerToModels: [String: [String]]
    private var makerModelToTrims: [String: [String: [String]]]
    private let repository = SearchListingRepository()
    
    private enum FilterDimension: Hashable {
        case carType
        case fuel
        case area
    }
    
    init() {
        allCars = []
        makerToModels = [:]
        makerModelToTrims = [:]
        let currentYear = Calendar.current.component(.year, from: Date())
        let lowerYear = max(currentYear - 20, 2006)
        yearRange = lowerYear...currentYear
        minPrice = priceRange.lowerBound
        maxPrice = priceRange.upperBound
        minYear = lowerYear
        maxYear = yearRange.upperBound
        minMileage = mileageRange.lowerBound
        maxMileage = mileageRange.upperBound
        fuelOptions = []
        areaOptions = []
        carTypeOptions = []

        Task { await loadListings() }
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
            MakerSummary(name: maker, count: counts[maker] ?? 0, imageName: imageName(for: maker))
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
    
    // 제조사 + 모델에 해당하는 트림 목록 반환
    func trims(for maker: String, model: String) -> [String] {
        return makerModelToTrims[maker]?[model] ?? []
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
            selectedTrim = nil
            selectedTrims.removeAll()
            return
        }
        if selectedModel == model {
            selectedModel = nil
            selectedTrim = nil
            selectedTrims.removeAll()
        } else {
            selectedModel = model
            selectedTrim = nil
            selectedTrims.removeAll()
        }
    }
    
    // 단일 트림 선택 유지용
    func selectTrim(_ model: String, for maker: String, for trim: String) {
        if selectedMaker != maker {
            selectedMaker = maker
            selectedModel = model
            selectedTrim = trim
            selectedTrims = [trim]
            return
        }
        if selectedTrim == trim {
            selectedTrim = nil
            selectedTrims.remove(trim)
        } else {
            selectedTrim = trim
            selectedTrims = [trim]
        }
    }
    
    // 트림 다중 선택 토글 (ModelSelectonView에서 사용)
    func toggleTrim(_ trim: String, for maker: String, model: String) {
        if selectedMaker != maker || selectedModel != model {
            selectedMaker = maker
            selectedModel = model
            selectedTrim = trim
            selectedTrims = [trim]
            return
        }
        if selectedTrims.contains(trim) {
            selectedTrims.remove(trim)
        } else {
            selectedTrims.insert(trim)
        }
    }
    
    func clearTrims() {
        selectedTrims.removeAll()
        selectedTrim = nil
    }
        
    func countForTrim(maker: String, model: String, trim: String) -> Int {
        allCars.filter {
            $0.maker == maker && $0.model == model && ($0.trim ?? "") == trim
        }.count
    }
    
    func clearMaker() {
        selectedMaker = nil
        selectedModel = nil
        selectedTrims = []
    }
    
    func clearModel() {
        selectedModel = nil
        selectedTrims = []
    }
    
    func clearTrim() {
        selectedTrims = []
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
        selectedTrims = []
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
        let trims = selectedTrims.isEmpty ? "없음" : selectedTrims.joined(separator: "\n\t")
        let fuels = Array(selectedFuels).sorted()
        let areas = Array(selectedAreas).sorted()
        let carTypes = Array(selectedCarTypes).sorted()

        print("===== 검색 필터 =====")
        print("제조사: \(maker)")
        print("모델: \(model)")
        print("트림: \(trims)")
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

        // 우선순위: 세부모델 > 모델 > 제조사
        if !selectedTrims.isEmpty {
            let trimsString = selectedTrims.joined(separator: "\n")
            parts.append("\(trimsString)")
        } else if let model = selectedModel, let maker = selectedMaker {
            parts.append("\(maker) \(model)")
        } else if let maker = selectedMaker {
            parts.append("\(maker)")
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
            } else if part.hasPrefix("세부모델:") {
                let rest = part.replacingOccurrences(of: "세부모델:", with: "").trimmingCharacters(in: .whitespaces)
                let trims = rest.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                selectedTrims = Set(trims)
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

    func searchCarsTrim(maker: String, model: String) -> [SearchCar] {
        allCars.filter { $0.maker == maker && $0.model == model }
    }
    
    func searchCars(keyword: String) -> [SearchCar] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()
        let filtered = allCars.filter { car in
            car.title.lowercased().contains(lowered)
        }
        
        // title 기준 중복 제거
        var seenTitles = Set<String>()
        let uniqueTitle = filtered.filter { car in
            if seenTitles.contains(car.title) {
                return false
            } else {
                seenTitles.insert(car.title)
                return true
            }
        }
        return uniqueTitle
    }
    
    private func loadListings() async {
        isLoading = true
        loadErrorMessage = nil
        do {
            let remoteCars = try await repository.fetchAvailableListings()
            applyDataset(remoteCars)
        } catch {
            loadErrorMessage = error.localizedDescription
            print("검색 목록 로드 실패: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func applyDataset(_ cars: [SearchCar]) {
        guard !cars.isEmpty else { return }
        allCars = cars
        let (modelsMap, trimsMap) = Self.groupModelsAndTrims(from: cars)
        makerToModels = modelsMap
        makerModelToTrims = trimsMap
        configureFilterOptions(with: cars)
        normalizeSelectionBounds()
    }
    
    private func configureFilterOptions(with cars: [SearchCar]) {
        let selectedFuelSet = selectedFuels
        let selectedAreaSet = selectedAreas
        let selectedCarTypeSet = selectedCarTypes
        
        fuelOptions = Self.buildOptions(from: cars.map { $0.fuel }, selected: selectedFuelSet)
        areaOptions = Self.buildOptions(from: cars.map { $0.area }, selected: selectedAreaSet)
        carTypeOptions = Self.buildOptions(from: cars.map { $0.category }, selected: selectedCarTypeSet)
    }
    
    private func normalizeSelectionBounds() {
        let years = allCars.map { $0.year }
        if let minYearAvailable = years.min(), let maxYearAvailable = years.max() {
            minYear = max(minYear, minYearAvailable)
            maxYear = min(maxYear, maxYearAvailable)
        }
        let prices = allCars.map { $0.price }
        if let minPriceAvailable = prices.min(), let maxPriceAvailable = prices.max() {
            minPrice = max(minPrice, minPriceAvailable)
            maxPrice = min(maxPrice, maxPriceAvailable)
        }
        let mileages = allCars.map { $0.mileage }
        if let minMileageAvailable = mileages.min(), let maxMileageAvailable = mileages.max() {
            minMileage = max(minMileage, minMileageAvailable)
            maxMileage = min(maxMileage, maxMileageAvailable)
        }
    }
    
    private static func buildOptions(from names: [String], selected: Set<String> = []) -> [CheckableItem] {
        let uniqueNames = Array(Set(names)).sorted()
        return uniqueNames.map { name in
            CheckableItem(name: name, checked: selected.contains(name))
        }
    }
    
    // 제조사 -> 모델 목록, 제조사 -> 모델 -> 트림 목록 생성
    private static func groupModelsAndTrims(from cars: [SearchCar]) -> ([String: [String]], [String: [String: [String]]]) {
    var modelsMap: [String: Set<String>] = [:]
    var trimsMap: [String: [String: Set<String>]] = [:]
    
    for car in cars {
                modelsMap[car.maker, default: []].insert(car.model)
                let trimName = (car.trim ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimName.isEmpty {
                    var modelDict = trimsMap[car.maker] ?? [:]
                    modelDict[car.model, default: []].insert(trimName)
                    trimsMap[car.maker] = modelDict
                }
            }
    
            let modelsFinal = modelsMap.mapValues { Array($0).sorted() }
            var trimsFinal: [String: [String: [String]]] = [:]
            for (maker, modelDict) in trimsMap {
                var inner: [String: [String]] = [:]
                for (model, trimsSet) in modelDict {
                    inner[model] = Array(trimsSet).sorted()
                }
                trimsFinal[maker] = inner
            }
        return (modelsFinal, trimsFinal)
        }

    private func imageName(for maker: String) -> String {
        if let direct = makerImages[maker] {
            return direct
        }
        let lowercased = maker.lowercased()
        if let normalized = makerImages[lowercased] {
            return normalized
        }
        return "hyundai 1"
    }
}
