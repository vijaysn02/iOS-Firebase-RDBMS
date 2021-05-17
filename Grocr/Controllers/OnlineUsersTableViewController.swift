

import UIKit
import Firebase

//MARK: - View Controller - Initialization
class OnlineUsersTableViewController: UITableViewController {
  
    //Constants
    let userCell = "UserCell"

    //Properties
    var currentUsers: [String] = []
    let usersRef = Database.database().reference(withPath: "online")


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
  
}

//MARK: - Initial Setup
extension OnlineUsersTableViewController {
    
    func initialSetup() {
        observeOnlineUserAdded()
        observeOnlineUserRemoved()
    }
    
}

//MARK: - Firebase Methods
extension OnlineUsersTableViewController {
    
    func observeOnlineUserAdded(){

        FirebaseHandler.shared.observeChild(dataEvent: .childAdded, tableName: "online") { snap in
         
            guard let email = snap.value as? String else { return }
            self.currentUsers.append(email)
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.addUserRowToTableView(indexPath)
            
        }
        
    }
    func observeOnlineUserRemoved() {
        
        FirebaseHandler.shared.observeChild(dataEvent: .childRemoved, tableName: "online") { snap in
          
            guard let emailToFind = snap.value as? String else { return }
            self.deleteUserRowinTableView(emailToFind)
            
        }
        
    }
    
}

//MARK: - Button Actions
extension OnlineUsersTableViewController {
    
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {
    
        let user = Auth.auth().currentUser!
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")

        onlineRef.removeValue { (error, _) in
            
            if let error = error {
              print("Removing online failed: \(error)")
              return
            }

            do {
              try Auth.auth().signOut()
              self.dismiss(animated: true, completion: nil)
            } catch (let error) {
              print("Auth sign out failed: \(error)")
            }
            
        }
    }
    
}

//MARK: - Dynamic UI Updates
extension OnlineUsersTableViewController {
    
    func addUserRowToTableView(_ indexPath:IndexPath) {
        DispatchQueue.main.async {
            guard self.currentUsers.count > 0 else {
                return
            }
            self.tableView.reloadData()
        }
    }
    func deleteUserRowinTableView(_ emailToFind:String) {
        DispatchQueue.main.async {
            for (index, email) in self.currentUsers.enumerated() {
                if email == emailToFind {
                  let indexPath = IndexPath(row: index, section: 0)
                  self.currentUsers.remove(at: index)
                  self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
}

//MARK: - Table View - Delegates and DataSource
extension OnlineUsersTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
    
}
