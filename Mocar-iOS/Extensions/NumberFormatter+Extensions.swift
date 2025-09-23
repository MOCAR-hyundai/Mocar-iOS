
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
    
    /// 한국식 억/만원 단위 포맷
       static func koreanPriceString(from price: Int) -> String {
           let 억 = price / 100_000_000
           let 만 = (price % 100_000_000) / 10_000
           
           if 억 > 0 {
               if 만 > 0 {
                   return "\(decimal.string(from: NSNumber(value: 억)) ?? "\(억)")억 " +
                          "\(decimal.string(from: NSNumber(value: 만)) ?? "\(만)")만원"
               } else {
                   return "\(decimal.string(from: NSNumber(value: 억)) ?? "\(억)")억"
               }
           } else {
               return "\(decimal.string(from: NSNumber(value: 만)) ?? "\(만)")만원"
           }
       }
}

// MARK: - 숫자 포맷 Extension
extension Int {
    var decimalString: String {
            NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? "\(self)"
        }
}

