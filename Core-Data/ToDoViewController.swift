//
//  ToDoViewController.swift
//  Core-Data
//
//  Created by Rajesh Kumar on 29/08/22.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {
    
    var todoArray = [Item]()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
       
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoList", for: indexPath)
        
        cell.textLabel?.text = todoArray[indexPath.row].title
        
        cell.accessoryType = todoArray[indexPath.row].done == true ? .checkmark : .none
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.context.delete(self.todoArray[indexPath.row])
            self.todoArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveItems()
        }
        
        let done = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            self.todoArray[indexPath.row].done = !self.todoArray[indexPath.row].done
            self.saveItems()
        }
        delete.backgroundColor = .red
        done.backgroundColor = .systemBlue
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete, done])
        
        return swipeActions
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        todoArray[indexPath.row].done = !todoArray[indexPath.row].done
        
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    @IBAction func AddButton(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New List", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add List", style: .default) { (action) in

            
            let item = Item(context: self.context)
            
            if textField.text != "" {
                guard let newItem = textField.text else { return }
                item.title = newItem
                item.done = false
                item.parentCategory = self.selectedCategory
                self.todoArray.append(item)
                self.saveItems()
            }
            
        }

        alert.addTextField { alerttextField in
            alerttextField.placeholder = "Create New List"
            textField = alerttextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)

    }
    
    
    func saveItems() {
       
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
            
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            
            if let addtionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
            } else {
                request.predicate = categoryPredicate
            }

            
            do {
                todoArray = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            tableView.reloadData()
            
        }

}

extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        guard let text = searchBar.text else {
            return
        }
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
        
        let descriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [descriptor]
        
        loadItems(with: request)
        
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
