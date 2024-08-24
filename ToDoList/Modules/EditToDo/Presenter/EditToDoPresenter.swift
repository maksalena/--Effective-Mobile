//
//  EditToDoPresenter.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import Foundation

protocol EditToDoPresenter: AnyObject {
    func saveToDo(toDoItem: ToDoItem, title: String, description: String)
}

class EditToDoPresenterImpl: EditToDoPresenter {
    
    weak var view: EditToDoView?
    var interactor: EditToDoInteractorInput!
    
    init(view: EditToDoView, interactor: EditToDoInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
    
    func saveToDo(toDoItem: ToDoItem, title: String, description: String) {
        interactor.updateToDoItem(toDo: toDoItem, title: title, description: description, isCompleted: toDoItem.isCompleted)
    }
}

extension EditToDoPresenterImpl: EditToDoInteractorOutput {
    func didUpdateToDo() {
        view?.displaySuccess()
    }
    
    func didFailToUpdateToDo(with error: Error) {
        view?.displayError(error.localizedDescription)
    }
}
