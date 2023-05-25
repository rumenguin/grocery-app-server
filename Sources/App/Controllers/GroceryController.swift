//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 25/05/23.
//

import Foundation
import Vapor
import GroceryAppSharedDTO

class GroceryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        // /api/users/:userId
        let api = routes.grouped("api", "users", ":userId")
        
        // POST: Saving GroceryCategory
        // api/users/:userId/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)
        
    }
    
    func saveGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        // get the user id
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // DTO for the request
        let groceryCategoryRequestDTO = try req.content.decode(GroceryCategoryRequestDTO.self)
        
        let groceryCategory = GroceryCategory(title: groceryCategoryRequestDTO.title, colorCode: groceryCategoryRequestDTO.colorCode, userId: userId)
        
        try await groceryCategory.save(on: req.db)
        
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        // DTO for the response
        return groceryCategoryResponseDTO
    }
}
