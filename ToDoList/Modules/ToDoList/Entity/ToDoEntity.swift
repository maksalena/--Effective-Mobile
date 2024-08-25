//
//  ToDoEntity.swift
//  ToDoList
//
//  Created by Алёна Максимова on 25.08.2024.
//

import Foundation


// MARK: - Response model

struct TodoResponse: Decodable {
    let todos: [Todo]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Todo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
