//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Joy Paul on 3/20/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit
import AlamofireImage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var photoTag: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        
    }
    
    @IBAction func onCameraTap(_ sender: UITapGestureRecognizer) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        cameraImage.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
}

