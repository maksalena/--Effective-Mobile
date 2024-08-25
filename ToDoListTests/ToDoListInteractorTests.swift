//
//  ToDoListInteractorTests.swift
//  ToDoListTests
//
//  Created by Алёна Максимова on 25.08.2024.
//

import XCTest
@testable import ToDoList


// MARK: - Interactor Tests

final class ToDoListInteractorTests: XCTestCase {
    var interactor: ToDoListInteractor!
    var mockOutput: MockToDoListInteractorOutput!

    override func setUp() {
        super.setUp()
        interactor = ToDoListInteractor()
        mockOutput = MockToDoListInteractorOutput()
        interactor.output = mockOutput

        UserDefaults.standard.set(false, forKey: "hasFetchedToDos") // Reset for each test
        clearCoreDataStore()
        loadAndSaveTodosFromJSON()
    }

    override func tearDown() {
        interactor = nil
        mockOutput = nil
        super.tearDown()
    }

    func clearCoreDataStore() {
        let todos = CoreDataManager.shared.fetchToDos()
        for todo in todos {
            CoreDataManager.shared.deleteToDo(todo)
        }
    }

    func loadAndSaveTodosFromJSON() {
        guard let url = Bundle(for: type(of: self)).url(forResource: "todos", withExtension: "json") else {
            XCTFail("Failed to locate todos.json in test bundle")
            return
        }

        guard let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load data from todos.json")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let todosArray = json["todos"] as? [[String: Any]] {
                for todoDict in todosArray {
                    if let title = todoDict["todo"] as? String,
                       let completed = todoDict["completed"] as? Bool {
                        CoreDataManager.shared.createToDo(
                            title: title,
                            description: nil,
                            createdDate: Date(),
                            isCompleted: completed
                        )
                    }
                }
                print("Todos loaded from JSON and saved to Core Data. Todos count: \(CoreDataManager.shared.fetchToDos().count)")
            } else {
                XCTFail("Failed to parse JSON structure")
            }
        } catch {
            XCTFail("Failed to decode JSON: \(error)")
        }
    }

    func fetchToDos() {
        DispatchQueue.global(qos: .background).async {
            var toDos: [ToDoItem] = []
            
            // Check UserDefaults to see if this is the first launch
            let hasFetchedToDos = UserDefaults.standard.bool(forKey: "hasFetchedToDos")
            print("hasFetchedToDos: \(hasFetchedToDos)")
            if !hasFetchedToDos {
                // Fetch todos from API
                CoreDataManager.shared.firstFetchToDos { result in
                    switch result {
                    case .success(let todos):
                        toDos = todos
                        print("Fetched \(todos.count) todos from the first fetch")
                    case .failure(let error):
                        print("Failed to fetch todos with error: \(error)")
                        toDos = CoreDataManager.shared.fetchToDos()
                        print("Fetched \(toDos.count) todos from CoreData after failure")
                    }
                    DispatchQueue.main.async {
                        self.interactor.output?.didFetchToDos(toDos)
                    }
                }
                // Mark that firstFetchToDos has been called
                UserDefaults.standard.set(true, forKey: "hasFetchedToDos")
            } else {
                toDos = CoreDataManager.shared.fetchToDos()
                print("Fetched \(toDos.count) todos from CoreData")
                DispatchQueue.main.async {
                    self.interactor.output?.didFetchToDos(toDos)
                }
            }
        }
    }


    func testAddToDoItem() {
        let expectation = self.expectation(description: "didUpdateToDo")
        mockOutput.didUpdateToDoCompletion = {
            expectation.fulfill()
        }

        let initialCount = CoreDataManager.shared.fetchToDos().count

        interactor.addToDoItem(title: "Test ToDo", description: "Test Description", isCompleted: false)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockOutput.didUpdateToDoCalled, "Expected didUpdateToDo to be called")
        XCTAssertEqual(CoreDataManager.shared.fetchToDos().count, initialCount + 1, "Expected the to-do count to increase by 1")
    }

    func testUpdateToDoItem() {
        guard let todo = CoreDataManager.shared.fetchToDos().first else {
            XCTFail("Failed to load a to-do item from Core Data")
            return
        }

        let expectation = self.expectation(description: "didUpdateToDo")
        mockOutput.didUpdateToDoCompletion = {
            expectation.fulfill()
        }

        interactor.updateToDoItem(toDo: todo, title: "Updated Title", description: "Updated Description", isCompleted: true)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockOutput.didUpdateToDoCalled, "Expected didUpdateToDo to be called")
    }

    func testDeleteToDoItem() {
        guard let todo = CoreDataManager.shared.fetchToDos().first else {
            XCTFail("Failed to load a to-do item from Core Data")
            return
        }

        let expectation = self.expectation(description: "didUpdateToDo")
        mockOutput.didUpdateToDoCompletion = {
            expectation.fulfill()
        }

        let initialCount = CoreDataManager.shared.fetchToDos().count

        interactor.deleteToDoItem(toDo: todo)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockOutput.didUpdateToDoCalled, "Expected didUpdateToDo to be called")
        XCTAssertEqual(CoreDataManager.shared.fetchToDos().count, initialCount - 1, "Expected the to-do count to decrease by 1")
    }

    func testToggleComplete() {
        guard let todo = CoreDataManager.shared.fetchToDos().first else {
            XCTFail("Failed to load a to-do item from Core Data")
            return
        }

        let expectation = self.expectation(description: "didUpdateToDo")
        mockOutput.didUpdateToDoCompletion = {
            expectation.fulfill()
        }

        let initialStatus = todo.isCompleted

        interactor.toggleComplete(todo)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockOutput.didUpdateToDoCalled, "Expected didUpdateToDo to be called")
        XCTAssertEqual(todo.isCompleted, !initialStatus, "Expected the to-do completion status to be toggled")
    }
}


// MARK: - Mock modules

class MockToDoListInteractorOutput: ToDoListInteractorOutput {
    var didFetchToDosCalled = false
    var didUpdateToDoCalled = false

    var fetchedToDos: [ToDoItem] = []

    // Completion handlers for expectations
    var didFetchToDosCompletion: (() -> Void)?
    var didUpdateToDoCompletion: (() -> Void)?

    func didFetchToDos(_ toDos: [ToDoItem]) {
        didFetchToDosCalled = true
        fetchedToDos = toDos
        didFetchToDosCompletion?()
    }

    func didUpdateToDo() {
        didUpdateToDoCalled = true
        didUpdateToDoCompletion?()
    }
}


