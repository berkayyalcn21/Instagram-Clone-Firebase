//
//  SettingsViewController.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 5.07.2022.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLoginVC", sender: nil)
        }catch{
            let alert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default)
            alert.addAction(okButton)
            present(alert, animated: true)
        }
    }
    
}
