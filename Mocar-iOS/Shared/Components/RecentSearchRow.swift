import SwiftUI

public struct RecentSearchRow: View {
    private let summary: String
    private let onApply: () -> Void
    private let onDelete: () -> Void
    
    private var components: [String] {
        summary.components(separatedBy: " | ")
    }
    
    public init(summary: String, onApply: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.summary = summary
        self.onApply = onApply
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(components.enumerated()), id: \.offset) { _, part in
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
                .fill(Color(UIColor.systemGray6))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onApply()
        }
    }
}
