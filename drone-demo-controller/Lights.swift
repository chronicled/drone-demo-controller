import Foundation

enum LightStatus {
    case StandBy, Processing, Granted, Refused
    
    typealias Params = Dictionary<String, AnyObject>

    func lightConfigurations() -> (Params, Params) {
        switch self {
        case .StandBy: return (Strip.standBy, Bulb.standBy)
        case .Granted: return (Strip.granted, Bulb.granted)
        case .Refused: return (Strip.refused, Bulb.refused)
        case .Processing: return (Strip.proccessing, Bulb.proccessing)
        }
    }
}

private struct Strip {
    static let standBy = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 6000]
    static let granted = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 13000]
    static let refused = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 0]
    static let proccessing = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 44000]
}

private struct Bulb {
    static let standBy = ["on" : true, "sat" : 254, "bri" : 1, "hue" : 11000]
    static let granted = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 25000, "alert" : "lselect"]
    static let refused = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 0]
    static let proccessing = ["on" : true, "sat" : 254, "bri" : 254, "hue" : 44000, "alert" : "lselect"]
}
