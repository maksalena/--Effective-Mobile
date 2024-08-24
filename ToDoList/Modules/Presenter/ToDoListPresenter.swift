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

protocol ToDoListPresenterInput {
    func viewDidLoad()
    func fetchToDos()
    func showAddToDo()
    func showEditToDo(for toDo: ToDoItem)
    func deleteToDoItem(_ toDo: ToDoItem)
    func toggleComplete(_ toDo: ToDoItem)
}

class ToDoListPresenter: ToDoListPresenterInput, ToDoListInteractorOutput {
    
    weak var view: ToDoListView?
    var interactor: ToDoListInteractorInput?
    var router: ToDoListRouter?
    
    init(view: ToDoListView, interactor: ToDoListInteractorInput, router: ToDoListRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        fetchToDos()
    }
    
    func fetchToDos() {
        interactor?.fetchToDos()
    }
    
    func showAddToDo() {
        router?.navigateToAddToDo()
    }
    
    func showEditToDo(for toDo: ToDoItem) {
        router?.navigateToEditToDo(for: toDo)
    }
    
    func deleteToDoItem(_ toDo: ToDoItem) {
        interactor?.deleteToDoItem(toDo: toDo)
    }
    
    func toggleComplete(_ toDo: ToDoItem) {
        interactor?.toggleComplete(toDo)
    }
    
    // MARK: - Interactor Output
    
    func didFetchToDos(_ toDos: [ToDoItem]) {
        view?.showToDos(toDos)
    }
    
    func didFailToFetchToDos(with error: Error) {
        view?.showError(error)
    }
    
    func didUpdateToDo() {
        fetchToDos()
    }
}

