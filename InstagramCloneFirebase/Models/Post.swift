//
//  Post.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 8.07.2022.
//

import Foundation


class Post {

    var postId: String?
    var userId: String?
    var comment: String?
    var userName: String?
    var likes: Int?
    var likeControl: [String]?
    var imageUrl: String?
    var imageId: String?
    
    init() {
        
    }
    
    init(postId: String, userId: String, comment: String, userName: String, likes: Int, likeControl: [String], imageUrl: String, imageId: String) {
        self.postId = postId
        self.userId = userId
        self.comment = comment
        self.userName = userName
        self.likes = likes
        self.likeControl = likeControl
        self.imageUrl = imageUrl
        self.imageId = imageId
    }
}
