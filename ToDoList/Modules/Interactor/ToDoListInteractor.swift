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
        // Perform the fetch operation in a background thread
        DispatchQueue.global(qos: .background).async {
            let toDos = CoreDataManager.shared.fetchToDos()
            
            DispatchQueue.main.async {
                self.output?.didFetchToDos(toDos)
            }
        }
    }
    
    func addToDo(title: String, description: String) {
        // Perform the add operation in a background thread
        DispatchQueue.global(qos: .background).async {
            CoreDataManager.shared.createToDo(title: title, description: description, createdDate: Date(), isCompleted: false)
            
            // Notify observers about the update of a ToDo on the main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateToDo, object: nil)
            }
        }
    }
    
    func updateToDo(toDo: ToDoItem) {
        // Perform the update operation in a background thread
        DispatchQueue.global(qos: .background).async {
            CoreDataManager.shared.updateToDo(toDo: toDo, title: toDo.title ?? "", description: toDo.todoDescription, isCompleted: toDo.isCompleted)
            
            // Notify observers about the update of a ToDo on the main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateToDo, object: nil)
            }
        }
    }
    
    func deleteToDo(id: UUID) {
        // Perform the delete operation in a background thread
        DispatchQueue.global(qos: .background).async {
            if let toDo = CoreDataManager.shared.fetchToDo(with: id) {
                CoreDataManager.shared.deleteToDo(toDo)
            }
            
            // Notify observers about the deletion of a ToDo on the main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateToDo, object: nil)
            }
        }
    }
}

