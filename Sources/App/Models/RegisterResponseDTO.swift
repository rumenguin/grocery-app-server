//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 23/05/23.
//

import Foundation
import Vapor

struct RegisterResponseDTO: Content {
    let error: Bool
    var reason: String? = nil
}
