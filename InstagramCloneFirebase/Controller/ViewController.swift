//
//  ViewController.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 4.07.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class ViewController: UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordAgainText: UITextField!
    
    let db = FirebaseFirestore.Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func singUpClicked(_ sender: Any) {
        if nameText.text != "" && surnameText.text != "" && userNameText.text != "" && emailText.text != "" && passwordText.text != "" && passwordAgainText.text != ""{
            if passwordText.text == passwordAgainText.text{
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (authdata, error) in
                    if error != nil{
                        self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                    }else{
                        self.makeAlert(title: "Information", message: "Registration successful")
                        self.emailText.text = ""
                        self.passwordText.text = ""
                        // DATABASE
                        let fireStoreUser = ["name": self.nameText.text, "surname": self.surnameText.text, "userName": self.userNameText.text]
                        let currentUser = Auth.auth().currentUser?.uid
                        self.db.collection("Users").document(currentUser!).setData(fireStoreUser as [String : Any], merge: true) { error in
                            if error != nil {
                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                            }else{
                                self.nameText.text = ""
                                self.surnameText.text = ""
                                self.userNameText.text = ""
                                self.emailText.text = ""
                                self.passwordText.text = ""
                                self.passwordAgainText.text = ""
                                self.performSegue(withIdentifier: "toLoginVC", sender: nil)
                            }
                        }
                    }
                }
            }else{
                makeAlert(title: "Warning", message: "Password not same")
            }
        }else{
            makeAlert(title: "Warning", message: "Please enter something into the text box")
        }
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    
}

