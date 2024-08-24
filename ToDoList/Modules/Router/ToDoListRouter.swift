//
//  ToDoListRouter.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class ToDoListRouter {
    
    weak var viewController: UIViewController?
    
    static func assembleModule() -> UIViewController {
        let view = ToDoListViewController()
        let interactor = ToDoListInteractor()
        let router = ToDoListRouter()
        let presenter = ToDoListPresenter(view: view, interactor: interactor, router: router)
        
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToAddToDo() {
        let addToDoVC = AddToDoViewController()
        addToDoVC.modalPresentationStyle = .fullScreen
        viewController?.present(addToDoVC, animated: true, completion: nil)
    }
    
    func navigateToEditToDo(for toDo: ToDoItem) {
        let editToDoVC = EditToDoViewController()
        editToDoVC.toDoItem = toDo
        editToDoVC.modalPresentationStyle = .fullScreen
        viewController?.present(editToDoVC, animated: true, completion: nil)
    }
}

