//
//  FirebaseHandler.swift
//  Grocr
//
//  Created by Sagaya Navis Vijay on 15/05/21.
//  Copyright © 2021 Razeware LLC. All rights reserved.
//

import Foundation
import Firebase

//MARK: - Configuration
class FirebaseHandler {
    
    static let shared = FirebaseHandler()
    
    func configure() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
    
}

//MARK: - Authentication
extension FirebaseHandler {
    
    func signIn(email:String,password:String,completionBlock: @escaping (Bool,Error?,User?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
          if let error = error, user == nil {
            completionBlock(false,error, nil)
          } else {
            completionBlock(true,nil,user)
          }
        }
        
    }
    func createUser(email:String,password:String,completionBlock: @escaping (Bool,Error?,User?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                self.signIn(email: email, password: password) { authSuccess, authError, user  in
                    completionBlock(authSuccess,authError,user)
                }
            } else {
                completionBlock(false,error,nil)
            }
        }
        
    }
    func observeAuthorizationState(completionBlock: @escaping (Bool,User?) -> Void) {
            
        Auth.auth().addStateDidChangeListener() { auth, user in
          
            if user != nil {
                completionBlock(true,user)
            } else {
                completionBlock(false,nil)
            }
            
        }
        
    }
    
}

//MARK: - Write and Delete
extension FirebaseHandler {
    
    func writeData(json:Any,tableName:String,referenceId:String) {
    
        let databaseReference = Database.database().reference(withPath: tableName)
        let groceryItemRef = databaseReference.child(referenceId.lowercased())
        groceryItemRef.setValue(json)
        
    }
    func updateData(dbReference:DatabaseReference?,dataToUpdate:[String:Any]) {
        dbReference?.updateChildValues(dataToUpdate)
    }
    func deleteData(dbReference:DatabaseReference?) {
        dbReference?.removeValue()
    }
    
}

//MARK: - Read
extension FirebaseHandler {
    
    func observeValue(tableName:String,completionBlock: @escaping (DataSnapshot) -> Void) {
        
        let databaseReference = Database.database().reference(withPath: tableName)
        databaseReference.observe(.value, with: { snapshot in
            completionBlock(snapshot)
        })
        
    }
    func observeChangeInQueryOrdered(tableName:String,keyValueForSorting:String,completionBlock: @escaping (DataSnapshot) -> Void) {
        
        let databaseReference = Database.database().reference(withPath: tableName)
        databaseReference.queryOrdered(byChild: keyValueForSorting).observe(.value, with: { snapshot in
            completionBlock(snapshot)
        })
    }
    
}

//MARK: - Observing Child Events
extension FirebaseHandler {
    
    func observeChild(dataEvent:DataEventType,tableName:String,completionBlock: @escaping (DataSnapshot) -> Void) {
        
        let databaseReference = Database.database().reference(withPath: tableName)
        databaseReference.observe(dataEvent, with: { snapshot in
            completionBlock(snapshot)
        })
        
    }
    
}
