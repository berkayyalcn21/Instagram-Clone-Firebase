//
//  FeedCell.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 5.07.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FeedCell: UITableViewCell {
    
    let fireStoreDatabase = Firestore.firestore()
    var post: Post?
    var feedVC: FeedViewController!
    var index: Int!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func fill(post: Post) {
        self.post = post
        userEmailLabel.text = post.userName
        commentLabel.text = post.comment
        likeLabel.text = String(post.likes ?? 0)
        userImageView.sd_setImage(with: URL(string: post.imageUrl ?? ""))
        documentIdLabel.text = post.postId
        let currentUserID = Auth.auth().currentUser?.uid
        if currentUserID != post.userId {
            optionButton.isHidden = true
        }else{
            optionButton.isHidden = false
        }
    }

    @IBAction func likeButtonClicked(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
        if let likeCount = Int(likeLabel.text!){
            let likeStore = ["likes": likeCount + 1] as [String: Any]
            fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
        }
    }
    
    @IBAction func optionButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Edit", message: "What do you want?", preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { UIAlertAction in
            self.fireStoreDatabase.collection("Posts").document((self.post?.postId)!).delete()

            let storage = Storage.storage()
            let storageRef = storage.reference()
            let deleteImage = storageRef.child("media/").child("\((self.post?.imageId)!).jpg")
            
            deleteImage.delete { error in
                if error != nil {
                }else{
                }
            }
              
        }
        alert.addAction(cancelButton)
        alert.addAction(deleteButton)
        self.feedVC.present(alert, animated: true)
    }
    
    
}
