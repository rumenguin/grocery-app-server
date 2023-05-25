//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 25/05/23.
//

import Foundation
import GroceryAppSharedDTO
import Vapor

extension GroceryCategoryResponseDTO: Content {
    
    init?(_ groceryCategory: GroceryCategory) {
        guard let id = groceryCategory.id else {
            return nil
        }
        
        self.init(id: id, title: groceryCategory.title, colorCode: groceryCategory.colorCode)
    }
    
}
