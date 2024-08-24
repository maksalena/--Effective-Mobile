//
//  EditToDoViewController.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class EditToDoViewController: UIViewController {
    
    var toDoItem: ToDoItem? // The item being edited
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Edit ToDo"
        
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(saveButton)
        
        setupConstraints()
        
        // Set initial values
        titleTextField.text = toDoItem?.title
        descriptionTextView.text = toDoItem?.todoDescription
        
        saveButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func saveToDo() {
        guard let toDoItem = toDoItem else { return }
        
        // Get updated values
        let newTitle = titleTextField.text ?? ""
        let newDescription = descriptionTextView.text
        
        // Update the ToDo item
        CoreDataManager.shared.updateToDo(toDo: toDoItem, title: newTitle, description: newDescription, isCompleted: toDoItem.isCompleted)
        
        // Dismiss the edit view controller
        dismiss(animated: true) {
            // Notify observers that a ToDo item was updated
            NotificationCenter.default.post(name: .didUpdateToDo, object: nil)
        }
    }
}
