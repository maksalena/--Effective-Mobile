//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class ToDoListViewController: UIViewController, ToDoListView {
    
    var presenter: ToDoListPresenter?
    var toDos: [ToDoItem] = []
    
    // Create a UITableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ToDoTableViewCell.self, forCellReuseIdentifier: ToDoTableViewCell.identifier)
        return table
    }()
    
    // Array to hold ToDo items
    var todos: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ToDo List"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Check UserDefaults to see if this is the first launch
        let hasFetchedToDos = UserDefaults.standard.bool(forKey: "hasFetchedToDos")
        if !hasFetchedToDos {
            firstFetchToDos()
            // Mark that firstFetchToDos has been called
            UserDefaults.standard.set(true, forKey: "hasFetchedToDos")
        } else {
            fetchToDos()
        }
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToDo))
        navigationItem.rightBarButtonItem = addButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchToDos), name: .didAddNewToDo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchToDos), name: .didUpdateToDo, object: nil)
    }
    
    @objc private func firstFetchToDos() {
        CoreDataManager.shared.firstFetchToDos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.todos.append(contentsOf: todos)
                
                // Reload the table view on the main thread
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                // Handle the error (e.g., show an alert)
                print("Error: \(error.localizedDescription)")
                
                // Optionally reload the table view with an error state
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    @objc private func fetchToDos() {
        // Assuming CoreDataManager is set up to fetch ToDo items
        todos = CoreDataManager.shared.fetchToDos()
        tableView.reloadData()
    }
    
    @objc private func addToDo() {
        let addToDoViewController = AddToDoViewController()
        let navController = UINavigationController(rootViewController: addToDoViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func showToDos(_ toDos: [ToDoItem]) {
        self.toDos = toDos
        tableView.reloadData()
    }
    
    func showError(_ error: Error) {
        // Display the error message to the user
    }
    
}

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.identifier, for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        let todo = todos[indexPath.row]
        cell.configure(with: todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the selected ToDo item
        let selectedToDo = todos[indexPath.row]
        
        // Create the edit view controller
        let editToDoVC = EditToDoViewController()
        editToDoVC.toDoItem = selectedToDo
        
        let navController = UINavigationController(rootViewController: editToDoVC)
        present(navController, animated: true, completion: nil)
    }
    
    // Swipe to delete functionality using trailing swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let toDoToDelete = self.todos[indexPath.row]
            CoreDataManager.shared.deleteToDo(toDoToDelete)
            self.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    // Swipe to complete functionality using leading swipe actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toDo = todos[indexPath.row]
        let title = toDo.isCompleted ? "Not Completed" : "Completed"
        
        let completeAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completionHandler in
            guard self != nil else { return }
            
            // Toggle completion status
            toDo.isCompleted.toggle()
            CoreDataManager.shared.updateToDo(toDo: toDo, title: toDo.title ?? "", description: toDo.todoDescription, isCompleted: toDo.isCompleted)
            
            // Reload the specific row
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        completeAction.backgroundColor = toDo.isCompleted ? .systemOrange : .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [completeAction])
        return configuration
    }
}

extension Notification.Name {
    static let didAddNewToDo = Notification.Name("didAddNewToDo")
    static let didUpdateToDo = Notification.Name("didUpdateToDo")
}
