import Foundation

extension NumberFormatter {
    /// A cached decimal NumberFormatter configured for grouping separators.
    static let decimal: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()
}
