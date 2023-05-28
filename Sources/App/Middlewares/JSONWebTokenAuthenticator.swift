//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 28/05/23.
//

import Foundation
import Vapor

struct JSONWebTokenAuthenticator: AsyncRequestAuthenticator {
    
    func authenticate(request: Request) async throws {
        try request.jwt.verify(as: AuthPayload.self)
    }
    
}
