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

class FeedViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDatabase = Firestore.firestore()
    // For posts delete
    var userEmailArray = [String]()
    var commentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var documentIdArray = [String]()
    var userNameArray = [String]()
    var posts: [Post] = [Post]()
    
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
                    self.posts.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        // Posts IDs
                        let documentID = document.documentID
                        self.documentIdArray.append(documentID)
                        if let postedBy = document.get("postedBy") as? String,
                           let postComment = document.get("postComment") as? String,
                           let likes = document.get("likes") as? Int,
                           let imageUrl = document.get("imageUrl") as? String,
                           let postedByUserName = document.get("postedByUserName") as? String,
                           let imageId = document.get("imageID") as? String,
                           let likeControl = document.get("likeControl") as? [String]{
                            
                            let post = Post(postId: documentID, userId: postedBy, comment: postComment, userName: postedByUserName, likes: likes, likeControl: likeControl, imageUrl: imageUrl, imageId: imageId)
                            self.posts.append(post)
                        }   
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.fill(post: posts[indexPath.row])
        cell.feedVC = self
        cell.index = indexPath.row
        return cell
    }
}
