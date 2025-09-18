import SwiftUI

public struct SearchKeywordChipsView: View {
    private let keywords: [String]
    private let onTap: (String) -> Void
    private let onDelete: (String) -> Void
    
    public init(keywords: [String], onTap: @escaping (String) -> Void, onDelete: @escaping (String) -> Void) {
        self.keywords = keywords
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(keywords, id: \.self) { keyword in
                    SearchKeywordChip(
                        keyword: keyword,
                        onTap: { onTap(keyword) },
                        onDelete: { onDelete(keyword) }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
}

public struct SearchKeywordChip: View {
    private let keyword: String
    private let onTap: () -> Void
    private let onDelete: () -> Void
    
    public init(keyword: String, onTap: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.keyword = keyword
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            Text(keyword)
                .font(.footnote)
                .foregroundColor(.black)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(Color(UIColor.systemGray6))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
