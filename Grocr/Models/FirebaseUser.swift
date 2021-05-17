
import Foundation
import Firebase

struct FirebaseUser {
  
  
  let uid: String
  let email: String
  
  //Initialisation
  init(authData: Firebase.User) {
    uid = authData.uid
    email = authData.email!
  }
  
  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
    
}
