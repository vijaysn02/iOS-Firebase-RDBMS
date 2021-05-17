

import UIKit
import Firebase

//MARK: - View Controller - Initialization
class LoginViewController: UIViewController {
  
    // MARK: Constants
    let loginToList = "LoginToList"

    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      initialSetup()
    }

}

//MARK: - Initial Setup
extension LoginViewController {
    
    func initialSetup() {
        observeAuthorization()
    }
    
}

//MARK: - Firebase Methods
extension LoginViewController {
    
    func observeAuthorization() {
       
        FirebaseHandler.shared.observeAuthorizationState { authSuccess, user in
            if authSuccess {
                self.clearTextFields()
                self.moveToGroceryList()
            }
        }
        
    }
    func signIn(email:String,password:String) {
        
        FirebaseHandler.shared.signIn(email: email, password: password) { authSuccess, authError, user  in
            if let uwAuthError = authError,!authSuccess {
                self.showAuthFailureAlert(uwAuthError)
            }
        }
        
    }
    func createUser(email:String,password:String) {
        
        FirebaseHandler.shared.createUser(email: email, password: password) { authSuccess, authError, user  in
            if let uwAuthError = authError,!authSuccess {
                self.showAuthFailureAlert(uwAuthError,errorTitle: "Sign Up Failed")
            }
        }
        
    }
    
}

//MARK: - Button Actions
extension LoginViewController {
   
    @IBAction func loginDidTouch(_ sender: AnyObject) {
      
      guard
        let email = textFieldLoginEmail.text,
        let password = textFieldLoginPassword.text,
        email.count > 0,
        password.count > 0
        else {
          return
      }

      self.signIn(email: email, password: password)
      
    }
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        
      let alert = UIAlertController(title: "Register",
                                    message: "Register",
                                    preferredStyle: .alert)
      
      let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
          
        guard let email = alert.textFields?[0].text, let password = alert.textFields?[1].text else {
            return
        }

        self.createUser(email: email, password: password)
          
      }
      
      let cancelAction = UIAlertAction(title: "Cancel",
                                       style: .cancel)
      
      alert.addTextField { textEmail in
        textEmail.placeholder = "Enter your email"
      }
      
      alert.addTextField { textPassword in
        textPassword.isSecureTextEntry = true
        textPassword.placeholder = "Enter your password"
      }
      
      alert.addAction(saveAction)
      alert.addAction(cancelAction)
      
      present(alert, animated: true, completion: nil)
    
    }
    
}

//MARK: - Dynamic UI Updates
extension LoginViewController {
    
    func clearTextFields() {
        DispatchQueue.main.async {
            self.textFieldLoginEmail.text = nil
            self.textFieldLoginPassword.text = nil
        }
    }
    func showAuthFailureAlert(_ error:Error, errorTitle:String = "Sign In Failed") {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: errorTitle,
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}

//MARK: - Text Field - Delegates
extension LoginViewController: UITextFieldDelegate {
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
          textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
          textField.resignFirstResponder()
        }
        return true
    }
    
}


//MARK: - Navigation
extension LoginViewController {
    
    func moveToGroceryList() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.loginToList, sender: nil)
        }
    }
    
}
