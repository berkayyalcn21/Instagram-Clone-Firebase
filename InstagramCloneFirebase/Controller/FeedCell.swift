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
    var likeControl: Bool?
    let currentUserID = Auth.auth().currentUser?.uid
     
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
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
        if currentUserID != post.userId {
            optionButton.isHidden = true
        }else{
            optionButton.isHidden = false
        }
        
        var control = false
        
        for i in post.likeControl! {
            if i == currentUserID {
                control = true
                print("Gördü")
                break
            }else {
                control = false
                print("Görmedi")
            }
        }
        if control {
            likeButton.setTitle("", for: .normal)
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else {
            likeButton.setTitle("", for: .normal)
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

    @IBAction func likeButtonClicked(_ sender: Any) {
        var control = false
        if var likeControlList = post?.likeControl {
            for userId in likeControlList {
                if userId != currentUserID {
                    control = true
                }else{
                    control = false
                    break
                }
            }
            if control {
                let fireStoreDatabase = Firestore.firestore()
                if let likeCount = Int(likeLabel.text!){
                    let likeStore = ["likes": likeCount + 1] as [String: Any]
                    fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
                  }
                likeControlList.append(currentUserID!)
                let liked = ["likeControl": likeControlList]
                fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(liked, merge: true)
                likeButton.setTitle("", for: .normal)
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }else {
                let fireStoreDatabase = Firestore.firestore()
                if let likeCount = Int(likeLabel.text!){
                    let likeStore = ["likes": likeCount - 1] as [String: Any]
                    fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
                  }
                
                let delete = likeControlList.filter { $0 != currentUserID}
                let sendLikeControl = ["likeControl": delete]
                fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(sendLikeControl, merge: true)

                likeButton.setTitle("", for: .normal)
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
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
