//
//  UploadViewController.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 5.07.2022.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    var userName: String?
    var likeControlArray: [String]?
    
    // DATABASE
    let firestoreDatabase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        let gestureRecognizerKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizerKeyboard)
        
        getDataFromFirestore()
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    func makeAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        uploadButton.isEnabled = false
        // References determine which folder we work in and where I save it.
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            // For photos different names
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            // DATABASE
                            var firestoreReference : DocumentReference? = nil
                            let firestorePost = ["imageUrl": imageUrl!, "postedBy": Auth.auth().currentUser!.uid, "postComment": self.commentText.text!, "date": FieldValue.serverTimestamp(), "likes": 0, "postedByUserName": self.userName!, "imageID": uuid, "likeControl": self.likeControlArray ?? [""]] as [String : Any]
                            firestoreReference = self.firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil {
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                    self.uploadButton.isEnabled = true
                                }else {
                                    self.imageView.image = UIImage(systemName: "photo")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                    self.uploadButton.isEnabled = true
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    // Login yapan kullanıcının userName textini alıp paylaşılan postun datasına ekleniyor.
    func getDataFromFirestore(){
        firestoreDatabase.collection("Users").addSnapshotListener { snapshot, error in
            if error != nil{
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            }else{
                if snapshot != nil {
                    for document in snapshot!.documents {
                        if document.documentID == Auth.auth().currentUser?.uid{
                            self.userName = document.data()["userName"]! as? String
                        }
                    }
                }
            }
        }
    }
    
    
}
