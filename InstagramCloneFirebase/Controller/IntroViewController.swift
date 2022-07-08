//
//  IntroViewController.swift
//  InstagramCloneFirebase
//
//  Created by Berkay on 6.07.2022.
//

import UIKit

class IntroViewController: UIViewController {
    
    @IBOutlet weak var singInButton: UIButton!
    @IBOutlet weak var singUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        singInButton.setTitle("", for: .normal)
        singUpButton.setTitle("", for: .normal)
        let singInImage = UIImage(named: "singIn")
        let singUpImage = UIImage(named: "singUp")
        singInButton.setImage(singInImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        singUpButton.setImage(singUpImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    

}
