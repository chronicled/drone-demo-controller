import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var logView: UITextView!
    internal var history: NSMutableAttributedString = NSMutableAttributedString()

    internal var centralManager: CBCentralManager?
    internal var challengeChar: CBCharacteristic?
    internal var signatureChar: CBCharacteristic?
    internal var authStateChar: CBCharacteristic?
    internal var currentPeripheral: CBPeripheral?
    
    internal var challenge: String?
    internal var identity: String?

    internal var lastTimeSeen: NSDate?
    internal var lastTimeSeenTimer: NSTimer?

    internal var done = false

    override func viewDidLoad() {
        Network.configureLightIP {
            self.success("Welcome to the Chronicled Drone Demo")

            DemoState.standBy()

            let now = dispatch_time_t(DISPATCH_TIME_NOW)
            let delay = 10 * Int64(NSEC_PER_SEC)

            dispatch_after(dispatch_time(now, delay), dispatch_get_main_queue()) {
                self.log("Let's Begin")
                self.centralManager = CBCentralManager(delegate: self,
                    queue: dispatch_get_main_queue())
            }
        }
    }
}