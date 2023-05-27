//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 25/05/23.
//

import Foundation
import Vapor
import GroceryAppSharedDTO
import Fluent

class GroceryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        // /api/users/:userId
        let api = routes.grouped("api", "users", ":userId")
        
        // POST: Saving GroceryCategory
        // api/users/:userId/grocery-categories
        api.post("grocery-categories", use: saveGroceryCategory)
        
        // GET: /api/users/:userId/grocery-categories
        api.get("grocery-categories", use: getGroceryCategoriesByUser)
        
        //DELETE: /api/users/:userId/grocery-categories/:groceryCategoryId
        api.delete("grocery-categories", ":groceryCategoryId", use: deleteGroceryCategory)
        
    // POST: /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
        api.post("grocery-categories", ":groceryCategoryId", "grocery-items", use: saveGroceryItem)
        
    // POST: /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items
        api.get("grocery-categories", ":groceryCategoryId", "grocery-items", use: getGroceryItemsByGroceryCategory)
        
    // DEL: /api/users/:userId/grocery-categories/:groceryCategoryId/grocery-items/:groceryItemId
        
        api.delete("grocery-categories", ":groceryCategoryId", "grocery-items", ":groceryItemId", use: deleteGroceryItem)
        
    }
    
    func deleteGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        
        //get the id from the route parameters
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self),
              let groceryItemId = req.parameters.get("groceryItemId", as: UUID.self)
        else {
            throw Abort(.badRequest)
        }
        
        // make sure the category exists and belongs to the user
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard let groceryItem = try await GroceryItem.query(on: req.db)
            .filter(\.$id == groceryItemId)
            .filter(\.$groceryCategory.$id == groceryCategory.id!)
            .first() else {
                throw Abort(.notFound)
            }
        
        try await groceryItem.delete(on: req.db)
        
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        
        return groceryItemResponseDTO
        
    }
    
    func getGroceryItemsByGroceryCategory(req: Request) async throws -> [GroceryItemResponseDTO] {
        
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // validate the userId
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // find the grocery category
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        return try await GroceryItem.query(on: req.db)
            .filter(\.$groceryCategory.$id == groceryCategory.id!)
            .all()
            .compactMap(GroceryItemResponseDTO.init)
        
    }
    
    func saveGroceryItem(req: Request) async throws -> GroceryItemResponseDTO {
        
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        //find the user
        guard let _ = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        // find the grocery category
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
            throw Abort(.notFound)
        }
        
        //decoding // GroceryItemRequestDTO
        let groceryItemRequestDTO = try  req.content.decode(GroceryItemRequestDTO.self)
        
        let groceryItem = GroceryItem(title: groceryItemRequestDTO.title, price: groceryItemRequestDTO.price, quantity: groceryItemRequestDTO.quantity, groceryCategoryId: groceryCategory.id!)
        
        try await groceryItem.save(on: req.db)
        
        guard let groceryItemResponseDTO = GroceryItemResponseDTO(groceryItem) else {
            throw Abort(.internalServerError)
        }
        
        return groceryItemResponseDTO
    }
    
    func deleteGroceryCategory(req: Request) async throws -> GroceryCategoryResponseDTO {
        
        // get the userId, grcoeryCategoryId
        guard let userId = req.parameters.get("userId", as: UUID.self),
              let groceryCategoryId = req.parameters.get("groceryCategoryId", as: UUID.self)
        else {
            throw Abort(.badRequest)
        }
        
        guard let groceryCategory = try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$id == groceryCategoryId)
            .first() else {
                throw Abort(.notFound)
            }
        
        try await groceryCategory.delete(on: req.db)
        
        guard let groceryCategoryResponseDTO = GroceryCategoryResponseDTO(groceryCategory) else {
            throw Abort(.internalServerError)
        }
        
        return groceryCategoryResponseDTO
    }
    
    func getGroceryCategoriesByUser(req: Request) async throws -> [GroceryCategoryResponseDTO] {
        
        // get the user id
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return try await GroceryCategory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
            .compactMap(GroceryCategoryResponseDTO.init)
        
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
