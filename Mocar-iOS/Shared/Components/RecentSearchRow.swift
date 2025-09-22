import SwiftUI

struct RecentSearchRow: View {
    let filter: SearchDetailViewModel.RecentSearchFilter
    let onApply: () -> Void
    let onDelete: () -> Void

    private var components: [String] {
        var parts: [String] = []

        if let maker = filter.maker {
            parts.append("제조사: \(maker)")
        }
        if let model = filter.model {
            parts.append("모델: \(model)")
        }
        if !filter.trims.isEmpty {
            parts.append("세부모델: \(filter.trims.joined(separator: ", "))")
        }
        if (filter.minPrice ?? 0) != 0 || (filter.maxPrice ?? 100_000) != 100_000 {
            parts.append("가격: \((filter.minPrice ?? 0))-\((filter.maxPrice ?? 100_000))")
        }
        if (filter.minYear ?? 1990) != 1990 || (filter.maxYear ?? Calendar.current.component(.year, from: Date())) != Calendar.current.component(.year, from: Date()) {
            parts.append("연식: \((filter.minYear ?? 1990))-\((filter.maxYear ?? Calendar.current.component(.year, from: Date())))")
        }
        if (filter.minMileage ?? 0) != 0 || (filter.maxMileage ?? 300_000) != 300_000 {
            parts.append("주행: \((filter.minMileage ?? 0))-\((filter.maxMileage ?? 300_000))km")
        }
        if !filter.carTypes.isEmpty {
            parts.append("차종: \(filter.carTypes.joined(separator: ", "))")
        }
        if !filter.fuels.isEmpty {
            parts.append("연료: \(filter.fuels.joined(separator: ", "))")
        }

        return parts
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(components, id: \.self) { part in
                    Text(part)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onApply()
        }
    }
}
