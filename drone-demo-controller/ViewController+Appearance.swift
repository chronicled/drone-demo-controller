import Foundation
import UIKit

extension ViewController {
    override func viewWillAppear(animated: Bool) {
        let app = UIApplication.sharedApplication()
        guard let bar = app.valueForKey("statusBar") else {
            return
        }

        guard let statusBar = bar as? UIView else {
            return
        }

        guard statusBar.respondsToSelector(Selector("setBackgroundColor:")) else {
            return
        }

        app.statusBarHidden = false
        app.statusBarStyle = .LightContent

        let color = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1)
        statusBar.backgroundColor = color
    }
}
