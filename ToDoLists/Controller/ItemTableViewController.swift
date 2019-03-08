//
//  MainTableViewController.swift
//  ToDoLists
//
//  Created by Jane Zhu on 3/5/19.
//  Copyright © 2019 JaneZhu. All rights reserved.
//

import UIKit
import CoreData

class ItemTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    private var itemsArray = [Item]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        fetchItems()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title!
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
           textField.placeholder = "new item"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            guard let itemTitle = alert.textFields!.first!.text else {
                return
            }
            let newItem = Item(context: self.context)
            newItem.title = itemTitle
            newItem.done = false
            self.itemsArray.append(newItem)
            self.saveItems()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        context.delete(itemsArray[indexPath.row])
        itemsArray.remove(at: indexPath.row)
        saveItems()
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("error saving context")
        }
        tableView.reloadData()
        title = "Items (\(itemsArray.count))"
    }
    
    fileprivate func fetchItems(_ request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("error fetching serached term")
        }
        tableView.reloadData()
        title = "Items (\(itemsArray.count))"
    }
}

extension ItemTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchItems(request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}