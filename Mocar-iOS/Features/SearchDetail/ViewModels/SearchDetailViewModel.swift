import Foundation
import SwiftUI

@MainActor
final class SearchDetailViewModel: ObservableObject {
    struct MakerSummary: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
        let imageName: UIImage?
        let countryType: String
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
    
    @Published var carBrands : [CarBrand] = []
    @Published private(set) var makerImages: [String: UIImage] = [:]  // 이름 → 로고 URL 매핑
    private var makerCountryType: [String: String] = [:] // 이름 → "국산차"/"수입차"
    private let carBrandRepository = CarBrandRepository()
    
    @Published var allMakers: [BrandFilterView.Maker] = []

    @Published var selectedMaker: String?
    @Published var selectedModel: String?
    @Published var selectedTrim: String?
    @Published var selectedTrims: Set<String> = []
    @Published var recentKeyword: String = ""
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
    
    let priceRange: ClosedRange<Int> = 0...100000
    let mileageRange: ClosedRange<Int> = 0...300000
    let yearRange: ClosedRange<Int>
    
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
        let lowerYear = 1990
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
        
        Task {
            await loadListings()
            await loadCarBrands()
        }
    }
    
    /// Firestore에서 브랜드 데이터를 불러와 매핑
    private func loadCarBrands() async {
        do {
            let brands = try await carBrandRepository.fetchCarBrands()
            
            // 로컬 배열에 먼저 모든 데이터를 준비
            var imagesMap: [String: UIImage] = [:]
            var countryMap: [String: String] = [:]
            
            await withTaskGroup(of: (String, UIImage?).self) { group in
                for brand in brands {
                    group.addTask {
                        var downloadedImage: UIImage? = nil
                        if let url = URL(string: brand.logoUrl) {
                            do {
                                let (data, _) = try await URLSession.shared.data(from: url)
                                downloadedImage = UIImage(data: data)
                            } catch {
                                print("이미지 다운로드 실패: \(brand.name), \(error.localizedDescription)")
                            }
                        }
                        return (brand.name, downloadedImage)
                    }
                }
                
                for await (name, image) in group {
                    if let image = image {
                        imagesMap[name] = image
                    }
                }
            }
            
            // countryType 매핑
            for brand in brands {
                let countryString = brand.countryType.isEmpty ? "기타" : brand.countryType
                let type: String
                switch countryString.lowercased() {
                case "imported":
                    type = "수입차"
                case "domestic":
                    type = "국산차"
                default:
                    type = "기타"
                }
                countryMap[brand.name] = type
            }
            
            // MainActor에서 한 번에 업데이트
            await MainActor.run {
                self.carBrands = brands
                self.makerImages = imagesMap
                self.makerCountryType = countryMap
            }
            
        } catch {
            print("브랜드 데이터 로드 실패: \(error.localizedDescription)")
        }
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
            MakerSummary(name: maker, count: counts[maker] ?? 0, imageName: imageName(for: maker), countryType: countryType(for: maker))
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
    
    func addRecentKeyword(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentKeywords.removeAll { $0 == trimmed }
        recentKeywords.insert(trimmed, at: 0)
        if recentKeywords.count > 10 {
            recentKeywords = Array(recentKeywords.prefix(10))
        }
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

    @Published var recentSearches: [RecentSearchFilter] = []

    struct RecentSearchFilter: Codable, Hashable, Identifiable {
        let id = UUID()
        var maker: String?
        var model: String?
        var trims: Set<String>
        var carTypes: Set<String>
        var fuels: Set<String>
        var minPrice: Int?
        var maxPrice: Int?
        var minYear: Int?
        var maxYear: Int?
        var minMileage: Int?
        var maxMileage: Int?
        var name: String?
        
        static func == (lhs: RecentSearchFilter, rhs: RecentSearchFilter) -> Bool {
            lhs.maker == rhs.maker &&
            lhs.model == rhs.model &&
            lhs.trims == rhs.trims &&
            lhs.carTypes == rhs.carTypes &&
            lhs.fuels == rhs.fuels &&
            lhs.minPrice == rhs.minPrice &&
            lhs.maxPrice == rhs.maxPrice &&
            lhs.minYear == rhs.minYear &&
            lhs.maxYear == rhs.maxYear &&
            lhs.minMileage == rhs.minMileage &&
            lhs.maxMileage == rhs.maxMileage
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(maker)
            hasher.combine(model)
            hasher.combine(trims)
            hasher.combine(carTypes)
            hasher.combine(fuels)
            hasher.combine(minPrice)
            hasher.combine(maxPrice)
            hasher.combine(minYear)
            hasher.combine(maxYear)
            hasher.combine(minMileage)
            hasher.combine(maxMileage)
        }
    }

    func saveCurrentFiltersAsRecent() {
        let filter = RecentSearchFilter(
            maker: selectedMaker,
            model: selectedModel,
            trims: selectedTrims,
            carTypes: Set(carTypeOptions.filter { $0.checked }.map { $0.name }),
            fuels: Set(fuelOptions.filter { $0.checked }.map { $0.name }),
            minPrice: minPrice,
            maxPrice: maxPrice,
            minYear: minYear,
            maxYear: maxYear,
            minMileage: minMileage,
            maxMileage: maxMileage,
            name: "필터 \(recentSearches.count + 1)"
        )

        // 중복 제거
        recentSearches.removeAll { $0 == filter }
        recentSearches.insert(filter, at: 0)
        
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }

    func applyRecentSearch(_ filter: RecentSearchFilter) {
        selectedMaker = filter.maker
        selectedModel = filter.model
        selectedTrims = filter.trims

        carTypeOptions = carTypeOptions.map { CheckableItem(name: $0.name, checked: filter.carTypes.contains($0.name)) }
        fuelOptions = fuelOptions.map { CheckableItem(name: $0.name, checked: filter.fuels.contains($0.name)) }

        minPrice = filter.minPrice ?? priceRange.lowerBound
        maxPrice = filter.maxPrice ?? priceRange.upperBound
        minYear = filter.minYear ?? yearRange.lowerBound
        maxYear = filter.maxYear ?? yearRange.upperBound
        minMileage = filter.minMileage ?? mileageRange.lowerBound
        maxMileage = filter.maxMileage ?? mileageRange.upperBound
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
    
    private func imageName(for maker: String) -> UIImage? {
        if let image = makerImages[maker] {
            return image
        }
        let lowercased = maker.lowercased()
        if let image = makerImages[lowercased] {
            return image
        }
        return nil
    }
    
    func countryType(for maker: String) -> String {
        return makerCountryType[maker] ?? "기타"
    }
}
