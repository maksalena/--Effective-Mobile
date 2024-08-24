//
//  AddToDoViewController.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit

class AddToDoViewController: UIViewController {

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter title"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add New ToDo"
        view.backgroundColor = .white
        
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        saveButton.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func saveToDo() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            CoreDataManager.shared.createToDo(title: title, description: self?.descriptionTextView.text, createdDate: Date(), isCompleted: false)
            
            DispatchQueue.main.async {
                // Notify observers about the addition of a new ToDo
                NotificationCenter.default.post(name: .didAddNewToDo, object: nil)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
}

