//
//  ToDoListRouter.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class ToDoListRouter {
    
    static func createModule() -> ToDoListViewController {
        let view = ToDoListViewController()
        let presenter = ToDoListPresenter()
        let interactor = ToDoListInteractor()
        let router = ToDoListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        
        return view
    }
    
    func navigateToDetailScreen(from view: ToDoListView, with toDo: ToDoItem) {
        // Логика навигации на экран деталей задачи
    }
}

