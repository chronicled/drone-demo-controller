import Foundation

struct BeaconParser {
    private static let deviceIdLocation = 12
    private static let deviceIdLength = 6
    private static let txPowerLocation = 1
    private static let txPowerLength = 1

    private static let eddystoneKey = "kCBAdvDataServiceData"
    private static let eddystoneLength = 20

    internal static func getBeaconDataFrom(advertisementData: AdvertisementData) -> DeviceData? {
        guard let eddystoneData = parseEddystoneBeacon(advertisementData) else {
            return nil
        }

        let deviceId = getDeviceIdFrom(eddystoneData)
        let txPower = getTxPowerFrom(eddystoneData)

        return (deviceId, txPower)
    }

    private static func parseEddystoneBeacon(advertisementData: AdvertisementData) -> NSData? {
        guard let eddystone = advertisementData[BeaconParser.eddystoneKey] as? Optional<NSDictionary> else {
            return nil
        }

        guard let eddystoneAsData = eddystone?.allValues.first as? NSData
            where eddystoneAsData.length == BeaconParser.eddystoneLength else {
                return nil
        }

        return eddystoneAsData
    }

    private static func getTxPowerFrom(eddystoneData: NSData) -> UInt8 {
        let txPowerRange = NSRange(location: BeaconParser.txPowerLocation,
                                   length: BeaconParser.txPowerLength)

        let txPowerData = eddystoneData.subdataWithRange(txPowerRange)
        var power: UInt8 = 0

        txPowerData.getBytes(&power, length: sizeof(UInt8))

        return power
    }

    private static func getDeviceIdFrom(eddystoneData: NSData) -> String {
        let deviceIdRange = NSRange(location: BeaconParser.deviceIdLocation,
                                    length: BeaconParser.deviceIdLength)

        let deviceIdData = eddystoneData.subdataWithRange(deviceIdRange)

        return deviceIdData.hexadecimalString
    }
}

internal extension NSData {
    internal var hexadecimalString: String {
        var bytes = [UInt8](count: length, repeatedValue: 0)
        getBytes(&bytes, length: length)

        let hexString = NSMutableString()

        for byte in bytes {
            hexString.appendFormat("%02x", UInt8(byte))
        }
        
        return String(hexString)
    }
}