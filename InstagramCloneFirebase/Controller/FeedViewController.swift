//
//  FeedViewController.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 5.07.2022.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import FirebaseAuth

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    // For posts delete
    var takePostUID: String?
    var userIdArray = [String]()
    var commentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var documentIdArray = [String]()
    var userNameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // For posts data
        getDataFromFirestore()
        
        // For toggle keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    func getDataFromFirestore(){
        
        fireStoreDatabase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }else{
                if snapshot?.isEmpty != true && snapshot != nil {
                    self.userIdArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.userImageArray.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    self.userNameArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        // Posts IDs
                        let documentID = document.documentID
                        self.documentIdArray.append(documentID)
                        if let postedBy = document.get("postedBy") as? String{
                            self.userIdArray.append(postedBy)
                            
                            if let postComment = document.get("postComment") as? String{
                                self.commentArray.append(postComment)
                                
                                if let likes = document.get("likes") as? Int{
                                    self.likeArray.append(likes)
                                    
                                    if let imageUrl = document.get("imageUrl") as? String{
                                        self.userImageArray.append(imageUrl)
                                        
                                        if let postedByUserName = document.get("postedByUserName") as? String{
                                            self.userNameArray.append(postedByUserName)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.userIdLabel.text = userNameArray[indexPath.row]
        cell.commentLabel.text = commentArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        cell.userImageView.sd_setImage(with: URL(string: self.userImageArray[indexPath.row]))
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        takePostUID = cell.documentIdLabel.text
        return cell
    }
    
    @IBAction func optionsButton(_ sender: Any){
        let currentUserID = Auth.auth().currentUser?.uid
        let alert = UIAlertController(title: "Edit", message: "What do you want?", preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { UIAlertAction in
            for id in self.userIdArray{
                if currentUserID == id{
                    self.fireStoreDatabase.collection("Posts").document(self.takePostUID!).delete()
                    self.tableView.reloadData()
                }else{
                    self.makeAlert(title: "Error", message: "This post not your.")
                }
            }
        }
        alert.addAction(cancelButton)
        alert.addAction(deleteButton)
        present(alert, animated: true)
    }


}
