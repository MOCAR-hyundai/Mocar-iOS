import Foundation
import FirebaseFirestore

struct ListingEntity: Codable {
    let listingId: String?
    let title: String?
    let brand: String?
    let model: String?
    let trim: String?
    let carType: String?
    let fuel: String?
    let region: String?
    let year: Int?
    let price: Int?
    let mileage: Int?
    let status: String?
}

final class SearchListingRepository {
    private let db = Firestore.firestore()
    private let collectionName = "listings"
    
    func fetchAvailableListings() async throws -> [SearchCar] {
        let snapshot = try await db.collection(collectionName)
            .getDocuments()

        let documents = snapshot.documents
        print("Firestore에서 가져온 문서 수: \(documents.count)개, 컬렉션 \(collectionName)")

        var skipped: [(id: String, reason: String)] = []
        var results: [SearchCar] = []

        for document in documents {
            do {
                let entity = try document.data(as: ListingEntity.self)
                if let car = mapToSearchCar(entity: entity) {
                    results.append(car)
                } else {
                    skipped.append((id: document.documentID, reason: "필수 필드 누락으로 매핑 실패"))
                }
            } catch {
                skipped.append((id: document.documentID, reason: "디코딩 오류: \(error.localizedDescription)"))
            }
        }

        if !skipped.isEmpty {
            print("매핑 실패한 문서 수: \(skipped.count)개. 샘플 실패 문서 ID와 이유:")
            for s in skipped.prefix(10) {
                print("   - id=\(s.id): \(s.reason)")
            }
        }

        print("매핑된 차량 수: \(results.count)개")
        return results
    }
    
    private func mapToSearchCar(entity: ListingEntity) -> SearchCar? {
        guard let title = entity.title?.trimmingCharacters(in: .whitespacesAndNewlines),
              let brand = entity.brand?.trimmingCharacters(in: .whitespacesAndNewlines),
              let model = entity.model?.trimmingCharacters(in: .whitespacesAndNewlines),
              let trim = entity.trim?.trimmingCharacters(in: .whitespacesAndNewlines),
              let region = entity.region?.trimmingCharacters(in: .whitespacesAndNewlines),
              let year = entity.year,
              let rawPrice = entity.price,
              let mileage = entity.mileage
        else {
            return nil
        }
        
        let normalizedCarType = normalize(entity.carType)
        let normalizedFuel = normalize(entity.fuel)
        let priceInTenThousands = max(0, rawPrice / 10000)
        
        return SearchCar(
            title: title,
            maker: brand,
            model: model,
            trim: trim,
            category: normalizedCarType,
            fuel: normalizedFuel,
            area: region,
            year: year,
            price: priceInTenThousands,
            mileage: mileage
        )
    }
    
    private func normalize(_ value: String?) -> String {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return "기타"
        }
        if value.count <= 1 { return value.uppercased() }
        let first = value.prefix(1).uppercased()
        let rest = value.dropFirst().lowercased()
        return first + rest
    }
}
