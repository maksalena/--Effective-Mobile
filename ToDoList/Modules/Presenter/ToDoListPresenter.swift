//
//  ToDoListPresenter.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import Foundation

protocol ToDoListView: AnyObject {
    func showToDos(_ toDos: [ToDoItem])
    func showError(_ error: Error)
}

class ToDoListPresenter {
    
    weak var view: ToDoListView?
    var interactor: ToDoListInteractorInput?
    var router: ToDoListRouter?
    
    func viewDidLoad() {
        interactor?.fetchToDos()
    }
    
    func addNewToDo(title: String, description: String) {
        interactor?.addToDo(title: title, description: description)
    }
    
    func updateExistingToDo(toDo: ToDoItem) {
        interactor?.updateToDo(toDo: toDo)
    }
    
    func deleteToDoById(_ id: UUID) {
        interactor?.deleteToDo(id: id)
    }
}

extension ToDoListPresenter: ToDoListInteractorOutput {
    func didFetchToDos(_ toDos: [ToDoItem]) {
        view?.showToDos(toDos)
    }
    
    func didFailToFetchToDos(error: Error) {
        view?.showError(error)
    }
}

