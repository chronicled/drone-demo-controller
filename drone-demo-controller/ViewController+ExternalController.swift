import Foundation

extension ViewController {
    struct DemoState {
        static func standBy() {
            Network.changeLights(to: .StandBy)
            Network.closeDoor()
        }

        static func startProcessing() {
            Network.changeLights(to: .Processing)
        }

        static func grantAccess() {
            Network.changeLights(to: .Granted)
            Network.openDoor()
        }

        static func rejectAccess() {
            Network.changeLights(to: .Refused)
        }
    }
}