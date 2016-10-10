import Foundation

extension String {
    func dataWithHexString() -> NSData {
        var hex = self
        let data = NSMutableData()

        while hex.characters.count > 0 {
            let c = hex.substringToIndex(hex.startIndex.advancedBy(2))
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(2))
            
            var ch: UInt32 = 0
            NSScanner(string: c).scanHexInt(&ch)
            data.appendBytes(&ch, length: 1)
        }

        return data
    }
}
