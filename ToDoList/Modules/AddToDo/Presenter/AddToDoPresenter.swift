//
//  AddToDoPresenter.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import Foundation

protocol AddToDoPresenter: AnyObject {
    func saveToDo(title: String, description: String)
}

class AddToDoPresenterImpl: AddToDoPresenter {
    
    weak var view: AddToDoView?
    var interactor: AddToDoInteractorInput!
    
    init(view: AddToDoView, interactor: AddToDoInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
    
    func saveToDo(title: String, description: String) {
        interactor.addToDoItem(title: title, description: description)
    }
}

extension AddToDoPresenterImpl: AddToDoInteractorOutput {
    func didAddToDo() {
        view?.displaySuccess()
    }
    
    func didFailToAddToDo(with error: Error) {
        view?.displayError(error.localizedDescription)
    }
}

