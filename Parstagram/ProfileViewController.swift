//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Joy Paul on 3/27/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var profilePic: UIImageView!
    
    var ProfileImage: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicPlaceholder()
    }
    
    //func to determine if the imageView should display a placeholder or the actual image
    func profilePicPlaceholder(){
        //querying the database with currentUser as a query parameter
        let query = PFQuery(className: "ProfilePic").order(byDescending: "createdAt").whereKey("author", equalTo: PFUser.current())
        query.includeKeys(["author", "image"])
        query.limit = 1
        
        //if the return value is empty, just show the placeholder
        //if not empty and not nil grab the first item from the array
        query.findObjectsInBackground{(pic, error) in
            if pic == []{
                self.profilePic.image = #imageLiteral(resourceName: "profile_tab")
            }
            else if pic != nil{
                self.ProfileImage = pic
                let index = self.ProfileImage[0]
                let file = index["image"] as! PFFileObject
                let fileUrl = file.url!
                
                let url = URL(string: fileUrl)
                self.profilePic.af_setImage(withURL: url!)
            }
        }
    }
    
    //tapGestureRecognizer, launches camera/photoLibrary on tap
    @IBAction func onImageViewTap(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self //allows vc to receive the data
        picker.allowsEditing = true //presents a built-in vc to edit the photo
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    //presents the image after selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        profilePic.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    //closes the page itself
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //submits image to the database
    @IBAction func onSubmit(_ sender: UIButton) {
        
        let profileImage = PFObject(className: "ProfilePic")
        
        profileImage["author"] = PFUser.current()
        
        let imageData = profilePic.image?.pngData()
        let file = PFFileObject(data: imageData!)
        
        profileImage["image"] = file
        
        profileImage.saveInBackground(){(success, error) in
            if success{
                print("updated profile pic")
                self.dismiss(animated: true, completion: nil)
            }else{
                print("trouble updating pic")
            }
        }
        
    }
    
}
