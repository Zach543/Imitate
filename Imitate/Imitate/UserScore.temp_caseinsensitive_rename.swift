//
//  userScore.swift
//  Imitate
//
//  Created by Zach Kobes on 11/27/17.
//  Copyright © 2017 Zach Kobes. All rights reserved.
//

import ObjectMapper

class BaseResponse: Mappable {
    var statusCode: Int?
    var name, message: String?
    var details: Details?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        statusCode      <- map["statusCode"]
        name            <- map["name"]
        message         <- map["message"]
        details         <- map["details"]
    }
    
    func getError()->Error? {
        if let message = message {
            return NSError(
                domain: "com.churchmutual.now",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
        return nil
    }
}
