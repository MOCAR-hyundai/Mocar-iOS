import Foundation
import FirebaseAuth
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
    private let recentHistoryRepository = RecentHistoryRepository()
    
    @Published var allMakers: [BrandFilterView.Maker] = []
    
    @Published var recentFilters: [RecentFilter] = []
    
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
    
    @Published var recentSearches: [RecentFilter] = []
    
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
    
    // 필터 저장
    func saveCurrentFiltersAsRecent() {
        let firestoreFilter = RecentFilter(
            userId: Auth.auth().currentUser?.uid,
            brand: selectedMaker,
            model: selectedModel,
            subModels: Array(selectedTrims),
            carTypes: Array(carTypeOptions.filter { $0.checked }.map { $0.name }),
            fuels: Array(fuelOptions.filter { $0.checked }.map { $0.name }),
            regions: [],
            minPrice: minPrice,
            maxPrice: maxPrice,
            minYear: minYear,
            maxYear: maxYear,
            minMileage: minMileage,
            maxMileage: maxMileage
        )
        
        Task {
            do {
                try await recentHistoryRepository.saveFilter(firestoreFilter)
                applyFilterToListings() // 저장 후 목록 갱신
                // 저장 후 Firestore에서 최신 목록 갱신
                self.recentSearches = try await recentHistoryRepository.fetchFilters()
            } catch {
                print("❌ 필터 저장/불러오기 실패:", error.localizedDescription)
            }
        }
    }
    
    func applyRecentSearch(_ filter: RecentFilter) {
        selectedMaker = filter.brand
        selectedModel = filter.model
        selectedTrims = Set(filter.subModels ?? [])
        carTypeOptions = carTypeOptions.map { CheckableItem(name: $0.name, checked: filter.carTypes?.contains($0.name) ?? false) }
        fuelOptions = fuelOptions.map { CheckableItem(name: $0.name, checked: filter.fuels?.contains($0.name) ?? false) }
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
        return allCars.filter { $0.title.contains(keyword) }
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
    
    func loadRecentKeywords() {
        Task {
            do {
                self.recentKeywords = try await recentHistoryRepository.fetchKeywords()
            } catch {
                print("❌ 최근 검색 로드 실패:", error.localizedDescription)
            }
        }
    }
    
    func addKeyword(_ keyword: String) {
        Task {
            do {
                try await recentHistoryRepository.saveKeyword(keyword)
                self.recentKeywords = try await recentHistoryRepository.fetchKeywords()
            } catch {
                print("❌ 키워드 저장 실패:", error.localizedDescription)
            }
        }
    }
    
    func clearKeywords() async {
        do {
            try await recentHistoryRepository.clearKeywords()
            self.recentKeywords = []
        } catch {
            print("❌ 최근 키워드 전체 삭제 실패:", error.localizedDescription)
        }
    }
    
    func removeKeyword(_ keyword: String) {
        Task {
            do {
                try await recentHistoryRepository.removeKeyword(keyword)
                // 로컬 배열에서도 제거
                if let index = recentKeywords.firstIndex(of: keyword) {
                    recentKeywords.remove(at: index)
                }
            } catch {
                print("키워드 삭제 실패:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - 필터 저장
    func saveFilter(_ filter: RecentFilter) {
        Task {
            do {
                try await recentHistoryRepository.saveFilter(filter)
                // 저장 후 최신 필터 목록 갱신
                self.recentSearches = try await recentHistoryRepository.fetchFilters()
            } catch {
                print("❌ 필터 저장 실패:", error.localizedDescription)
            }
        }
    }

        // MARK: - 특정 필터 삭제
    func removeFilter(_ filter: RecentFilter) {
        Task {
            do {
                try await recentHistoryRepository.removeFilter(filter.id)
                
                // Firestore에서 삭제 후 로컬 배열에서도 제거
                await MainActor.run {
                    self.recentSearches.removeAll { $0.id == filter.id }
                }
            } catch {
                print("❌ 필터 삭제 실패:", error.localizedDescription)
            }
        }
    }

        // MARK: - 전체 필터 삭제
    func clearFilters() {
        Task {
            do {
                try await recentHistoryRepository.clearFilters()
                
                // Firestore 삭제 후 로컬 배열에서도 제거
                await MainActor.run {
                    self.recentSearches.removeAll()
                }
            } catch {
                print("❌ 전체 필터 삭제 실패:", error.localizedDescription)
            }
        }
    }
        

        // MARK: - 최근 필터 불러오기
    func loadRecentFilters() {
        Task {
            do {
                self.recentSearches = try await recentHistoryRepository.fetchFilters()
            } catch {
                print("❌ 최근 필터 로드 실패:", error.localizedDescription)
            }
        }
    }
    @Published var listings: [SearchCar] = [] // 화면에 보여줄 차량 목록

    func applyFilterToListings() {
        // 최근 필터 기준으로 필터링
        listings = allCars.filter { car in
            matches(car)
        }
    }
}

