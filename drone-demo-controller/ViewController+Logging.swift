import Foundation
import UIKit

private let red = UIColor(red: 0.85, green: 0.33, blue: 0.30, alpha: 1)
private let gray = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1)
private let green = UIColor(red: 0.59, green: 0.84, blue: 0.67, alpha: 1)

extension ViewController {
    func log(string: String) {
        message(string, color: gray)
    }

    func success(string: String) {
        message(string, color: green)
    }

    func error(string: String) {
        message(string, color: red)
    }

    private func message(string: String, color: UIColor) {
        let attributedOptions = [NSForegroundColorAttributeName : color]
        let message = "\(getTime()) \(string)"

        let attributedString = NSAttributedString(string: "\(message)\n",
                                                  attributes: attributedOptions)

        history.appendAttributedString(attributedString)
        logView.attributedText = history

        let bottom = logView.attributedText.length - 1
        logView.scrollRangeToVisible(NSMakeRange(bottom, 1))
    }

    private func getTime() -> String {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let units: NSCalendarUnit = [.Hour, .Minute, .Second]

        guard let comps = calendar?.components(units, fromDate: NSDate()) else {
            return ""
        }

        return "[\(comps.hour):\(comps.minute):\(comps.second)]"
    }
}

