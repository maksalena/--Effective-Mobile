//
//  ToDoListInteractor.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import Foundation

protocol ToDoListInteractorInput {
    func fetchToDos()
    func addToDo(title: String, description: String)
    func updateToDo(toDo: ToDoItem)
    func deleteToDo(id: UUID)
}

protocol ToDoListInteractorOutput: AnyObject {
    func didFetchToDos(_ toDos: [ToDoItem])
    func didFailToFetchToDos(error: Error)
}

class ToDoListInteractor: ToDoListInteractorInput {
    
    weak var output: ToDoListInteractorOutput?
    
    func fetchToDos() {
        DispatchQueue.global(qos: .background).async {
            let toDos = CoreDataManager.shared.fetchToDos()
            DispatchQueue.main.async {
                self.output?.didFetchToDos(toDos)
            }
        }
    }
    
    func addToDo(title: String, description: String) {
        DispatchQueue.global(qos: .background).async {
            CoreDataManager.shared.createToDo(title: title, description: description, createdDate: Date(), isCompleted: false)
            self.fetchToDos()
        }
    }
    
    func updateToDo(toDo: ToDoItem) {
        DispatchQueue.global(qos: .background).async {
            CoreDataManager.shared.updateToDo(toDo: toDo, title: toDo.title ?? "", description: toDo.todoDescription, isCompleted: toDo.isCompleted)
            self.fetchToDos()
        }
    }
    
    func deleteToDo(id: UUID) {
        DispatchQueue.global(qos: .background).async {
            if let toDo = CoreDataManager.shared.fetchToDo(with: id) {
                CoreDataManager.shared.deleteToDo(toDo)
            }
            self.fetchToDos()
        }
    }
}

