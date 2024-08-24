//
//  AddToDoRouter.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class AddToDoRouter {
    
    weak var viewController: UIViewController?
    
    static func assembleModule(rootPresenter: ToDoListPresenter) -> UIViewController {
        let view = AddToDoViewController()
        let interactor = AddToDoInteractor()
        let presenter = AddToDoPresenterImpl(view: view, interactor: interactor)
        let router = AddToDoRouter()
        
        view.presenter = presenter
        view.rootPresenter = rootPresenter
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
}

