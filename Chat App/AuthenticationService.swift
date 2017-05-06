//
//  AuthenticationService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias UserCompletion = (_ errorMsg: String?, _ data: FIRUser?) -> Void
typealias DeletionCompletion = () -> ()

class AuthenticationService {
    fileprivate static let _shared = AuthenticationService()
    fileprivate var currentCredential: FIRAuthCredential?
    
    static var shared: AuthenticationService {
        return _shared
    }
    
    func currentId() -> String? {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            return id
        }
        
        return nil
    }
    
    func createUser(email: String, password: String, onComplete: UserCompletion?) {
    
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            }
            self?.currentCredential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
            
            
            
            let data = [email.replacingOccurrences(of: ".", with: "%2E"): 1] as Dictionary<String, AnyObject>
            
            DatabaseService.shared.saveData(type: .email, data: data, firstChild: nil, secondChild: nil, appendAutoId: false, onComplete: { (error, _) in
                if error != nil {
                    AuthenticationService.shared.deleteCurrentUser { return }
                    return
                }
                
                onComplete?(nil, user)
            })
        })
    }
    
    func renewEmailCredential(email: String, password: String) {
        currentCredential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
    }
 
    func reauthenticate(onComplete: UserCompletion?) {
        if currentCredential == nil { renewEmailCredential(email: "dummy@dummy.com", password: "dummy1234") }
        FIRAuth.auth()?.currentUser?.reauthenticate(with: currentCredential!, completion: { [weak self] (error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, nil)
            }
        })
    }
    
    
    func signIn(email: String, password: String, onComplete: UserCompletion?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            } else {
                self?.currentCredential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
                onComplete?(nil, user)
            }
        })
    }
    
    func signOut(onCompletion: UserCompletion?) {
        do {
            try FIRAuth.auth()?.signOut()
            onCompletion?(nil, nil)
        } catch {
            onCompletion?("There was an error while logging you out. Please try again.", nil)
        }
    }
    
    func deleteCurrentUser(onCompletion: DeletionCompletion?) {
        let user = FIRAuth.auth()?.currentUser
        
        user?.delete(completion: { _ in
            onCompletion?()
        })
    }
    
    func updateEmail(email: String, onComplete: UserCompletion?) {
        FIRAuth.auth()?.currentUser?.updateEmail(email, completion: { [weak self] (error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, nil)
            }
        })
    }
    
    func updatePassword(password: String, onComplete: UserCompletion?) {
        FIRAuth.auth()?.currentUser?.updatePassword(password, completion: { [weak self] (error) in
            if let error = error {
                self?.processFirebaseErrors(error: error as NSError, onComplete: onComplete)
            } else {
                onComplete?(nil, nil)
            }
        })
    }
    
    fileprivate func processFirebaseErrors(error: NSError, onComplete: UserCompletion?) {
        if let errorCode = FIRAuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .errorCodeUserNotFound:
                onComplete?("No account exists with the provided email.", nil)
            case .errorCodeInvalidEmail:
                onComplete?("Invalid Email Address Format", nil)
            case .errorCodeWeakPassword:
                onComplete?("Password must be at least 6 characters", nil)
            case .errorCodeWrongPassword:
                onComplete?("Invalid Email Address/Password Combination", nil)
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Email is already in use", nil)
            default:
                onComplete?("There was a problem authenticating. Please try again", nil)
            }
        }
    }
    
}
