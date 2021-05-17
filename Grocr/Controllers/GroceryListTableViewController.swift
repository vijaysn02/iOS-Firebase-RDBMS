

import UIKit
import Firebase

//MARK: - View Controller - Initialization
class GroceryListTableViewController: UITableViewController {

  //Variables
  let listToUsers = "ListToUsers"
  
  //Properties
  var items: [GroceryItem] = [] {
    didSet {
        refreshTableView()
    }
  }
  var user: FirebaseUser!
  var userCountBarButtonItem: UIBarButtonItem!
    
  //Properties - Firebase
  let groceryRef = Database.database().reference(withPath: "grocery-items")
  let usersRef = Database.database().reference(withPath: "online")

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    user = FirebaseUser(uid: "FakeId", email: "hungry@person.food")
    initialSetup()

  }
  
}

//MARK: - Initial Setup
extension GroceryListTableViewController {
    
    func initialSetup() {
        initialViewSetup()
        observeFirebaseEvents()
    }
    func initialViewSetup() {
        tableView.allowsMultipleSelectionDuringEditing = false
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
    }
    
}

//MARK: - Button Actions
extension GroceryListTableViewController {
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
     
      let alert = UIAlertController(title: "Grocery Item",
                                    message: "Add an Item",
                                    preferredStyle: .alert)
      let saveAction = UIAlertAction(title: "Save",
                                     style: .default) { _ in
          
          guard let textField = alert.textFields?.first,
          let text = textField.text else { return }
          self.addAnItemtoGroceryList(itemName: text)
      }

      let cancelAction = UIAlertAction(title: "Cancel",
                                       style: .cancel)
      
      alert.addTextField()
      
      alert.addAction(saveAction)
      alert.addAction(cancelAction)
      
      present(alert, animated: true, completion: nil)
        
    }
    @objc func userCountButtonDidTouch() {
      performSegue(withIdentifier: listToUsers, sender: nil)
    }
    
}

//MARK: - Firebase Methods
extension GroceryListTableViewController {
    
    func observeFirebaseEvents() {
        observeAuthorization()
        observeChangeInValues()
        observeChangeInSortingOrder()
        observeOnlineUsers()
    }
    func observeAuthorization() {
        
        FirebaseHandler.shared.observeAuthorizationState { authSuccess, user in
            
          guard let user = user else { return }
          self.user = FirebaseUser(authData: user)
            
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()

        }
        
    }
    func observeChangeInValues() {
        
        FirebaseHandler.shared.observeValue(tableName: "grocery-items") { snapshot in
            
          var newItems: [GroceryItem] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
               let groceryItem = GroceryItem(snapshot: snapshot) {
              newItems.append(groceryItem)
            }
          }

          self.items = newItems
            
        }
        
    }
    func observeChangeInSortingOrder() {
        
        FirebaseHandler.shared.observeChangeInQueryOrdered(tableName: "grocery-items", keyValueForSorting: "completed") { snapshot in
            
          var newItems: [GroceryItem] = []
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
               let groceryItem = GroceryItem(snapshot: snapshot) {
              newItems.append(groceryItem)
            }
          }
          
          self.items = newItems
          
        }
        
    }
    func observeOnlineUsers() {
        
        FirebaseHandler.shared.observeValue(tableName: "online") { snapshot in
          if snapshot.exists() {
            self.updateCountLabel(snapshot.childrenCount.description)
          } else {
            self.updateCountLabel("0")
          }
        }
        
    }
    func addAnItemtoGroceryList(itemName:String) {
        
        let groceryItem = GroceryItem(name: itemName,
                               addedByUser: self.user.email,
                                 completed: false)
        FirebaseHandler.shared.writeData(json: groceryItem.toAnyObject(), tableName: "grocery-items", referenceId: itemName)
        
        
    }
    func removeAnItemFromGroceryList(index:Int) {
        let groceryItem = items[index]
        FirebaseHandler.shared.deleteData(dbReference: groceryItem.ref)

    }
    func updateCompletedInGroceryList(groceryItem:GroceryItem,toggledCompletion:Bool) {
        let completionStatus:[String:Any] = ["completed": toggledCompletion]
        FirebaseHandler.shared.updateData(dbReference: groceryItem.ref, dataToUpdate: completionStatus)
    }
    
}

//MARK: - Dynamic UI Updates
extension GroceryListTableViewController {
    
    func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func updateCountLabel(_ text:String) {
        DispatchQueue.main.async {
            self.userCountBarButtonItem?.title = text
        }
    }
    
    
}

//MARK: - Table View - Delegates and Data Source
extension GroceryListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
      let groceryItem = items[indexPath.row]
      
      cell.textLabel?.text = groceryItem.name
      cell.detailTextLabel?.text = groceryItem.addedByUser
      
      toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
      
      return cell
    }
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
      
      if !isCompleted {
        cell.accessoryType = .none
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
      } else {
        cell.accessoryType = .checkmark
        cell.textLabel?.textColor = .gray
        cell.detailTextLabel?.textColor = .gray
      }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        removeAnItemFromGroceryList(index: indexPath.row)
      }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      guard let cell = tableView.cellForRow(at: indexPath) else { return }
      let groceryItem = items[indexPath.row]
      let toggledCompletion = !groceryItem.completed
      toggleCellCheckbox(cell, isCompleted: toggledCompletion)
      updateCompletedInGroceryList(groceryItem: groceryItem, toggledCompletion: toggledCompletion)

    }
    
}
