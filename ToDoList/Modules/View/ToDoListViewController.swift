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
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        fetchToDos()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToDo))
        navigationItem.rightBarButtonItem = addButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchToDos), name: .didAddNewToDo, object: nil)
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
        // Handle cell selection if necessary
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Notification.Name {
    static let didAddNewToDo = Notification.Name("didAddNewToDo")
}
