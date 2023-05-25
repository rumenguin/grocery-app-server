//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 23/05/23.
//

import Foundation
import JWT

struct AuthPayload: JWTPayload {
    
    typealias Payload = AuthPayload
    
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case userId = "uid"
    }
    
    var expiration: ExpirationClaim
    var userId: UUID
    
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

