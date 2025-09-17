import SwiftUI

enum SearchCategory: String, CaseIterable, Identifiable {
    case brand = "제조사"
    case price = "가격"
    case year = "연식"
    case mileage = "주행거리"
    case bodyType = "차종"
    case fuel = "연료"
    case region = "지역"

    var id: String { rawValue }

    var title: String { rawValue }
}

final class SearchViewModel: ObservableObject {
    struct BrandInfo: Identifiable, Hashable {
        let id = UUID()
        let key: String
        let displayName: String
        let imageName: String?
    }

    @Published var searchText: String = ""
    @Published var selectedCategory: SearchCategory = .brand

    @Published var minPrice: Int = 0
    @Published var maxPrice: Int = 10000

    @Published var minYear: Int
    @Published var maxYear: Int

    @Published var minMileage: Int = 0
    @Published var maxMileage: Int = 200000

    @Published private(set) var selectedBrandKeys: Set<String> = []
    @Published var expandedBrandKey: String?
    @Published private var selectedModelsByBrand: [String: Set<String>] = [:]

    @Published var carTypeOptions: [CheckableItem]
    @Published var fuelOptions: [CheckableItem]
    @Published var regionOptions: [CheckableItem]

    private let listings: [Listing]
    private let brandInfos: [BrandInfo] = [
        BrandInfo(key: "Hyundai", displayName: "현대", imageName: "hyundai 1"),
        BrandInfo(key: "Genesis", displayName: "제네시스", imageName: "genesis"),
        BrandInfo(key: "Kia", displayName: "기아", imageName: "kia"),
        BrandInfo(key: "Renault", displayName: "르노코리아", imageName: "renault"),
        BrandInfo(key: "Chevrolet", displayName: "쉐보레", imageName: "chevrolet"),
        BrandInfo(key: "Mercedes-Benz", displayName: "벤츠", imageName: "benz"),
        BrandInfo(key: "BMW", displayName: "BMW", imageName: "bmw"),
        BrandInfo(key: "Audi", displayName: "아우디", imageName: "audi"),
        BrandInfo(key: "Tesla", displayName: "테슬라", imageName: "tesla"),
        BrandInfo(key: "Ferrari", displayName: "페라리", imageName: "ferrari")
    ]

    private let fuelDisplayToRaw: [String: String] = [
        "가솔린(휘발유)": "Gasoline",
        "디젤(경유)": "Diesel",
        "전기": "Electric",
        "LPG": "LPG",
        "하이브리드": "Hybrid"
    ]

    private let carTypeMapping: [String: String] = [
        "488 GTB": "스포츠카",
        "M3": "스포츠카",
        "Sonata": "중형",
        "A6": "중형",
        "Model 3": "중형"
    ]

    private let yearRange: ClosedRange<Int>
    private let priceRange: ClosedRange<Int> = 0...10000
    private let mileageRange: ClosedRange<Int> = 0...200000

    init(listings: [Listing] = Listing.listingData) {
        self.listings = listings

        let currentYear = Calendar.current.component(.year, from: Date())
        yearRange = 2006...currentYear
        minYear = yearRange.lowerBound
        maxYear = yearRange.upperBound

        carTypeOptions = SearchViewModel.defaultCarTypes
        fuelOptions = SearchViewModel.defaultFuelOptions
        regionOptions = SearchViewModel.defaultRegionOptions
    }

    var categories: [SearchCategory] {
        SearchCategory.allCases
    }

    var brands: [BrandInfo] {
        brandInfos.sorted { lhs, rhs in
            let lhsCount = count(for: lhs.key)
            let rhsCount = count(for: rhs.key)
            if lhsCount == rhsCount {
                return lhs.displayName < rhs.displayName
            }
            return lhsCount > rhsCount
        }
    }

    var filteredListings: [Listing] {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedQuery = trimmedQuery.lowercased()
        let activeBrandKeys = selectedBrandKeys
        let selectedModels = selectedModelsByBrand
        let selectedCarTypes = Set(carTypeOptions.filter { $0.checked }.map { $0.name })
        let selectedFuels = Set(fuelOptions.compactMap { item -> String? in
            guard item.checked else { return nil }
            return fuelDisplayToRaw[item.name]
        })
        let selectedRegions = Set(regionOptions.filter { $0.checked }.map { $0.name })

        return listings.filter { listing in
            if !normalizedQuery.isEmpty {
                if !listing.title.lowercased().contains(normalizedQuery) &&
                    !listing.brand.lowercased().contains(normalizedQuery) &&
                    !listing.model.lowercased().contains(normalizedQuery) &&
                    !listing.plateNumber.lowercased().contains(normalizedQuery) {
                    return false
                }
            }

            if listing.price < minPrice || listing.price > maxPrice { return false }
            if listing.year < minYear || listing.year > maxYear { return false }
            if listing.mileage < minMileage || listing.mileage > maxMileage { return false }

            if !activeBrandKeys.isEmpty {
                guard activeBrandKeys.contains(listing.brand) else { return false }
                if let models = selectedModels[listing.brand], !models.isEmpty {
                    guard models.contains(listing.model) else { return false }
                }
            } else if let models = selectedModels[listing.brand], !models.isEmpty {
                guard models.contains(listing.model) else { return false }
            }

            if !selectedCarTypes.isEmpty {
                guard let carType = carTypeMapping[listing.model], selectedCarTypes.contains(carType) else { return false }
            }

            if !selectedFuels.isEmpty && !selectedFuels.contains(listing.fuel) { return false }

            if !selectedRegions.isEmpty && !selectedRegions.contains(listing.region) { return false }

            return true
        }
    }

    func count(for brandKey: String) -> Int {
        listings.filter { $0.brand == brandKey }.count
    }

    func models(for brandKey: String) -> [String] {
        let models = listings
            .filter { $0.brand == brandKey }
            .map { $0.model }
        return Array(Set(models)).sorted()
    }

    func isBrandSelected(_ brandKey: String) -> Bool {
        selectedBrandKeys.contains(brandKey)
    }

    func toggleBrandSelection(_ brandKey: String) {
        if selectedBrandKeys.contains(brandKey) {
            selectedBrandKeys.remove(brandKey)
            selectedModelsByBrand.removeValue(forKey: brandKey)
        } else {
            selectedBrandKeys.insert(brandKey)
        }
    }

    func toggleBrandExpansion(_ brandKey: String) {
        if expandedBrandKey == brandKey {
            expandedBrandKey = nil
        } else {
            expandedBrandKey = brandKey
        }
    }

    func isModelSelected(_ model: String, for brandKey: String) -> Bool {
        selectedModelsByBrand[brandKey]?.contains(model) ?? false
    }

    func toggleModelSelection(_ model: String, for brandKey: String) {
        var models = selectedModelsByBrand[brandKey] ?? []
        if models.contains(model) {
            models.remove(model)
        } else {
            models.insert(model)
            selectedBrandKeys.insert(brandKey)
        }
        if models.isEmpty {
            selectedModelsByBrand.removeValue(forKey: brandKey)
        } else {
            selectedModelsByBrand[brandKey] = models
        }
    }

    func resetFilters() {
        searchText = ""
        selectedCategory = .brand

        minPrice = priceRange.lowerBound
        maxPrice = priceRange.upperBound

        minYear = yearRange.lowerBound
        maxYear = yearRange.upperBound

        minMileage = mileageRange.lowerBound
        maxMileage = mileageRange.upperBound

        selectedBrandKeys.removeAll()
        expandedBrandKey = nil
        selectedModelsByBrand.removeAll()

        carTypeOptions = SearchViewModel.defaultCarTypes
        fuelOptions = SearchViewModel.defaultFuelOptions
        regionOptions = SearchViewModel.defaultRegionOptions
    }
}

private extension SearchViewModel {
    static var defaultCarTypes: [CheckableItem] {
        [
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

    static var defaultFuelOptions: [CheckableItem] {
        [
            CheckableItem(name: "가솔린(휘발유)", checked: false),
            CheckableItem(name: "디젤(경유)", checked: false),
            CheckableItem(name: "전기", checked: false),
            CheckableItem(name: "LPG", checked: false),
            CheckableItem(name: "하이브리드", checked: false)
        ]
    }

    static var defaultRegionOptions: [CheckableItem] {
        [
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
    }
}
