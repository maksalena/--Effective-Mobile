//
//  EditToDoInteractor.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import Foundation

protocol EditToDoInteractorInput {
    func updateToDoItem(toDo: ToDoItem, title: String, description: String, isCompleted: Bool)
}

protocol EditToDoInteractorOutput: AnyObject {
    func didUpdateToDo()
    func didFailToUpdateToDo(with error: Error)
}

class EditToDoInteractor: EditToDoInteractorInput {
    weak var output: EditToDoInteractorOutput?
    
    func updateToDoItem(toDo: ToDoItem, title: String, description: String, isCompleted: Bool) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            CoreDataManager.shared.updateToDo(toDo: toDo, title: title, description: description, isCompleted: isCompleted)
            
            DispatchQueue.main.async {
                self?.output?.didUpdateToDo()
            }
        }
        
    }
}

