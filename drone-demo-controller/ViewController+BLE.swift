import Foundation
import CoreBluetooth

private let demoDeviceID = "c1002fc891f1"
private let bleUUIDs = [CBUUID(string: "FEAA")]
private let options = [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true)]

// MARK: CBCentralManagerDelegate Implementation
extension ViewController {
    func centralManagerDidUpdateState(central: CBCentralManager) {
        log("#centralManagerDidUpdateState CALLED")

        centralManager = central
        centralManager?.scanForPeripheralsWithServices(bleUUIDs, options: options)
    }

    func centralManager(central: CBCentralManager,
                        didDiscoverPeripheral peripheral: CBPeripheral,
                                              advertisementData: [String : AnyObject],
                                              RSSI: NSNumber) {

        guard let (deviceID, _) = BeaconParser.getBeaconDataFrom(advertisementData)
            /*where deviceID == demoDeviceID*/ else {
                return
        }

        log("#didDiscoverPeripheral - \(deviceID)")

        if !done && currentPeripheral == nil {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                DemoState.startProcessing()

                peripheral.delegate = self

                self.currentPeripheral = peripheral
                self.identity = "ble:1.0:\(deviceID)"
                self.sendChallengeRequestFor(peripheral)
            }
        } else if (done && currentPeripheral != nil) {
            log("ranging \(deviceID)")
            updateLastSeenTime()
        }
    }

    func centralManager(central: CBCentralManager,
                        didConnectPeripheral peripheral: CBPeripheral) {
        log("#didConnectPeripheral CALLED")
        peripheral.discoverServices([CBUUID(string: Service.Authentication.rawValue)])
    }
}

// MARK: CBPeripheralDelegate Implementation
extension ViewController {
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        log("#didDiscoverServices CALLED")

        guard let service = peripheral.services?.first else {
            return
        }

        let uuids = [CBUUID(string: Characteristic.Unlock.rawValue),
                     CBUUID(string: Characteristic.Signature.rawValue)]

        peripheral.discoverCharacteristics(uuids, forService: service)
    }

    func peripheral(peripheral: CBPeripheral,
                    didDiscoverCharacteristicsForService service: CBService,
                                                         error: NSError?) {

        log("#didDiscoverCharacteristicsForService CALLED")

        guard let chars = service.characteristics where chars.count == 2 else {
            self.denyAccess()
            self.error("#didDiscoverCharacteristicsForService - invalid count")
            return
        }

        guard challenge?.characters.count == 64 else {
            self.denyAccess()
            self.error("#didDiscoverCharacteristicsForService - invalidi challenge")
            return
        }

        (challengeChar, signatureChar) = (chars[0], chars[1])

        peripheral.writeValue(challenge!.dataWithHexString(),
                              forCharacteristic: challengeChar!,
                              type: .WithResponse)

        let now = dispatch_time_t(DISPATCH_TIME_NOW)
        let delay = 4 * Int64(NSEC_PER_SEC)

        dispatch_after(dispatch_time(now, delay), dispatch_get_main_queue()) {
            peripheral.readValueForCharacteristic(self.signatureChar!)
        }
    }

    func peripheral(peripheral: CBPeripheral,
                    didUpdateValueForCharacteristic characteristic: CBCharacteristic,
                                                    error: NSError?) {
        log("#didUpdateValueForCharacteristic CALLED")

        guard let signature = characteristic.value?.hexadecimalString else {
            self.denyAccess()
            return
        }

        sendVerificationRequestWith(signature)
    }
}

extension ViewController {
    private func sendChallengeRequestFor(peripheral: CBPeripheral) {
        Network.requestChallenge(identity!) { response in
            switch response.result {
            case .Success(let value):
                self.log("#requestChallenge")

                guard let data = value as? [String : AnyObject] else {
                    self.denyAccess()
                    return
                }

                guard data["reason"] == nil else {
                    self.denyAccess()
                    self.error("#requestChallenge - FAILED: \(value["reason"])")
                    return
                }

                guard let chal = data["challenge"] as? String else {
                    self.denyAccess()
                    self.error("#requestChallenge - NO CHALLENGE)")
                    return
                }

                self.challenge = chal
                self.centralManager?.connectPeripheral(peripheral, options: nil)

            case .Failure(let error):
                self.error("#requestChallenge - \(error)")
                self.denyAccess()
            }
        }
    }

    private func sendVerificationRequestWith(signature: String) {
        Network.sendVerification(identity!,
                                 challenge: challenge!,
                                 signature: signature) { response in

            switch response.result {
            case .Success(let data):
                guard let verified = data["verified"] as? Bool else {
                    self.error("#didUpdateValueForCharacteristic - VERIFIED FALSE)")
                    self.denyAccess()
                    return
                }

                if verified {
                    self.success("VERIFIED - OPEN")
                    self.grantAccess()
                } else {
                    self.denyAccess()
                    self.log("identity: \(self.identity!)")
                    self.log("challenge: \(self.challenge!)")
                    self.log("signature: \(signature)")
                }

            case .Failure(let error):
                self.error("#didUpdateValueForCharacteristic - \(error)")
                self.denyAccess()
            }
        }
    }

    private func grantAccess() {
        done = true
        DemoState.grantAccess()
        centralManager?.cancelPeripheralConnection(currentPeripheral!)
        updateLastSeenTime()
        startOutOfRangeTimer()
    }

    private func denyAccess() {
        done = true
        DemoState.rejectAccess()
        centralManager?.cancelPeripheralConnection(currentPeripheral!)
        updateLastSeenTime()
        startOutOfRangeTimer()
    }
}
