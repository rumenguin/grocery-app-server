//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 26/05/23.
//

import Foundation
import Vapor
import GroceryAppSharedDTO

extension GroceryItemResponseDTO: Content {
    
    init?(_ groceryItem: GroceryItem) {
        
        guard let groceryItemId = groceryItem.id else {
            return nil
        }
        
        self.init(id: groceryItemId, title: groceryItem.title, price: groceryItem.price, quantity: groceryItem.quantity)
        
    }
    
}
