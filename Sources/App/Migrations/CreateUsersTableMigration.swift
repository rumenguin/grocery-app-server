//
//  File.swift
//  
//
//  Created by RUMEN GUIN on 23/05/23.
//

import Foundation
import Fluent

struct CreateUsersTableMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required).unique(on: "username")
            .field("password", .string, .required)
            .create()
    }
    
    //UNDO
    func revert(on database: Database) async throws {
        try await database.schema("users")
            .delete()
    }
}
