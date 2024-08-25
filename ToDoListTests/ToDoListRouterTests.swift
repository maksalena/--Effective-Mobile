//
//  ToDoListRouterTests.swift
//  ToDoListTests
//
//  Created by Алёна Максимова on 25.08.2024.
//

import XCTest
@testable import ToDoList


// MARK: - Router Tests

final class ToDoListRouterTests: XCTestCase {

    var router: ToDoListRouter!
    var mockNavigationController: MockNavigationController!
    var rootPresenter: MockToDoListPresenter!

    override func setUp() {
        super.setUp()
        router = ToDoListRouter()
        mockNavigationController = MockNavigationController()
        
        // Set the router's viewController to the mockNavigationController
        router.viewController = mockNavigationController
        rootPresenter = MockToDoListPresenter(view: ToDoListViewController(), interactor: ToDoListInteractor(), router: ToDoListRouter())
    }

    override func tearDown() {
        router = nil
        mockNavigationController = nil
        rootPresenter = nil
        super.tearDown()
    }

    func testNavigateToToDoDetail() {
        CoreDataManager.shared.createToDo(title: "Sample ToDo", description: "Sample Description", createdDate: Date(), isCompleted: false)
        let toDo = CoreDataManager.shared.fetchToDos().first

        router.navigateToEditToDo(for: toDo ?? ToDoItem(), rootPresenter: rootPresenter)

        guard let presentedVC = mockNavigationController.presentedVC as? EditToDoViewController else {
            XCTFail("Expected EditToDoViewController to be presented, but got \(String(describing: mockNavigationController.presentedVC))")
            return
        }
        
        XCTAssertEqual(presentedVC.toDoItem, toDo, "Expected EditToDoViewController to have the correct to-do item passed")
    }

    func testPresentAddToDoModal() {
        router.navigateToAddToDo(rootPresenter: rootPresenter)

        guard let presentedVC = mockNavigationController.presentedVC as? AddToDoViewController else {
            XCTFail("Expected AddToDoViewController to be presented, but got \(String(describing: mockNavigationController.presentedVC))")
            return
        }

        XCTAssertTrue(presentedVC.modalPresentationStyle == .fullScreen, "Expected the AddToDoViewController to be presented in a full screen style")
    }
}


// MARK: - Mock modules

// Mock Navigation Controller to observe transitions
class MockNavigationController: UINavigationController {
    var pushedViewController: UIViewController?
    var presentedVC: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        presentedVC = viewControllerToPresent
        super.present(viewControllerToPresent, animated: animated, completion: completion)
    }
}

// Mock ToDoListPresenter class to simulate presenter's behavior
class MockToDoListPresenter: ToDoListPresenter {
    var isToDoDetailPresented = false
    var isAddToDoModalPresented = false
    var presentedToDoItem: ToDoItem?

    // Mock method for navigating to todo detail
    func presentToDoDetail(toDo: ToDoItem) {
        isToDoDetailPresented = true
        presentedToDoItem = toDo
    }

    // Mock method for presenting the add todo modal
    func presentAddToDoModal() {
        isAddToDoModalPresented = true
    }
}
