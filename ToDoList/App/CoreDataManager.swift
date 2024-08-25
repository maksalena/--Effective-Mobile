//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Алёна Максимова on 24.08.2024.
//

import UIKit
import CoreData
import Alamofire

public final class CoreDataManager: NSObject {
    
    public static let shared = CoreDataManager()
    private override init() {}
    
    private var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    private var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - ToDo CRUD Operations
    
    public func createToDo(title: String, description: String?, createdDate: Date, isCompleted: Bool) {
        guard let toDoEntityDescription = NSEntityDescription.entity(forEntityName: "ToDoItem", in: context) else { return }
        
        let toDo = NSManagedObject(entity: toDoEntityDescription, insertInto: context) as! ToDoItem
        toDo.id = UUID()
        toDo.title = title
        toDo.todoDescription = description
        toDo.createdDate = createdDate
        toDo.isCompleted = isCompleted
        
        saveContext()
    }
    
    func firstFetchToDos(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        let url = "https://dummyjson.com/todos"
        var toDos: [ToDoItem] = []
        
        AF.request(url).validate().responseDecodable(of: TodoResponse.self) { response in
            switch response.result {
            case .success(let todoResponse):
                for todo in todoResponse.todos {
                    self.createToDo(title: todo.todo, description: nil, createdDate: Date(), isCompleted: todo.completed)
                }
                toDos = self.fetchToDos()
                completion(.success(toDos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func fetchToDos() -> [ToDoItem] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoItem")
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return (try context.fetch(fetchRequest) as? [ToDoItem]) ?? []
        } catch {
            print("Failed to fetch ToDos: \(error)")
            return []
        }
    }
    
    public func fetchToDo(with id: UUID) -> ToDoItem? {
        let fetchRequest = NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch ToDo with id \(id): \(error)")
            return nil
        }
    }
    
    public func updateToDo(toDo: ToDoItem, title: String, description: String?, isCompleted: Bool) {
        toDo.title = title
        toDo.todoDescription = description
        toDo.isCompleted = isCompleted
        
        saveContext()
    }
    
    public func deleteToDo(_ toDo: ToDoItem) {
        context.delete(toDo)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

