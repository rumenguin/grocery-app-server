//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 23/05/23.
//

import Foundation
import Vapor
import Fluent

// /api/register
// /api/login

class UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        let api = routes.grouped("api")
        
        // /api/register
        api.post("register", use: register)
        
    }
    
    func register(req: Request) async throws -> RegisterResponseDTO {
        
        // validate the user // validations
        try User.validate(content: req)
        
        let user = try req.content.decode(User.self)
        
        //find if the user already exists using the username
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "Username is already taken.")
        }
        
        // hash the password
        user.password = try await req.password.async.hash(user.password)
        
        //save the user to database
        try await user.save(on: req.db)
        
        return RegisterResponseDTO(error: false) //there is no error
        
    }
    
}
