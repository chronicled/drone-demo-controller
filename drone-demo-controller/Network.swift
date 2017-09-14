import Foundation
import Alamofire

private let headers = ["Authorization" : "Bearer \(Config.bearer)"]
private var IP: String = "";

struct Network {
    static func requestChallenge(identity: String, cb: (Response<AnyObject, NSError> -> ())) {
        let req = Alamofire.request(.POST,
                                    "\(Config.domain)requestChallenge",
                                    parameters: ["identity" : identity],
                                    encoding: .JSON,
                                    headers: headers)

        req.responseJSON(completionHandler: cb)
    }

    static func sendVerification(identity: String,
                                 challenge: String,
                                 signature: String,
                                 cb: (Response<AnyObject, NSError> -> ())) {
        let params = [
            "identity" : identity,
            "challenge" : challenge,
            "signature" : signature
        ]

        let req = Alamofire.request(.POST,
                                    "\(Config.domain)verifyChallenge",
                                    parameters: params,
                                    encoding: .JSON,
                                    headers: headers)

        req.responseJSON(completionHandler: cb)
    }

    static func changeLights(to status: LightStatus) {
        let (strip, bulb) = status.lightConfigurations()

        Alamofire.request(.PUT,
            "http://\(IP)/api/\(Config.phillipsID)/lights/1/state",
            parameters: strip,
            encoding: .JSON).responseJSON { _ in }

        Alamofire.request(.PUT,
            "http://\(IP)/api/\(Config.phillipsID)/lights/2/state",
            parameters: bulb,
            encoding: .JSON).responseJSON { _ in }
    }

    static func openDoor() {
        let url = "\(Config.makerDomain)granted/with/key/\(Config.makerKey)"
        Alamofire.request(.GET, url)
    }

    static func closeDoor() {
        let url = "\(Config.makerDomain)standby/with/key/\(Config.makerKey)"
        Alamofire.request(.GET, url)
    }

    static func configureLightIP(completion: () -> ()) {
        Alamofire.request(.GET, Config.phillipsDomain).responseJSON() { response in
            if let data = response.result.value {
                guard let array = data as? [Dictionary<String, AnyObject>] else {
                    return
                }

                guard let value = array.first else {
                    return
                }

                IP = String(value["internalipaddress"]!)
                completion()
            }
        }
    }
}
