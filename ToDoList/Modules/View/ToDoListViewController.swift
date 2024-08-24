//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class ToDoListViewController: UIViewController, ToDoListView {
    
    var presenter: ToDoListPresenterInput?
    var toDos: [ToDoItem] = []
    
    // Create a UITableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ToDoTableViewCell.self, forCellReuseIdentifier: ToDoTableViewCell.identifier)
        return table
    }()
    
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
        
        // Initialize the presenter
        presenter?.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToDo))
        navigationItem.rightBarButtonItem = addButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchToDos), name: .didAddNewToDo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchToDos), name: .didUpdateToDo, object: nil)
    }
    
    @objc private func fetchToDos() {
        presenter?.fetchToDos()
    }
    
    @objc private func addToDo() {
        presenter?.showAddToDo()
    }
    
    func showToDos(_ toDos: [ToDoItem]) {
        self.toDos = toDos
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showError(_ error: Error) {
        // Display the error message to the user
    }
}

extension ToDoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.identifier, for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        let todo = toDos[indexPath.row]
        cell.configure(with: todo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the selected ToDo item
        let selectedToDo = toDos[indexPath.row]
        
        // Create the edit view controller
        presenter?.showEditToDo(for: selectedToDo)
    }
    
    // Swipe to delete functionality using trailing swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let toDoToDelete = self.toDos[indexPath.row]
            self.presenter?.deleteToDoItem(toDoToDelete)
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    // Swipe to complete functionality using leading swipe actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toDo = toDos[indexPath.row]
        let title = toDo.isCompleted ? "Not Completed" : "Completed"
        
        let completeAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            self.presenter?.toggleComplete(toDo)
            
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
