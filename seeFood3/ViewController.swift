//
//  ViewController.swift
//  seeFood3
//
//  Created by John Fake on 7/18/18.
//  Copyright © 2018 John Fake. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    let apiKey = "Wp-RNnC_Ja1AAO9bnC22LRPj7001LF_y7k6SSt9clw8w"
    let version = "2018-05-18"
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var staticHotdog: UIImageView!
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        shareButton.isHidden = true
        staticHotdog.image = UIImage(named:"hotdogBackground")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        if let userPickedimage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedimage
           // guard let ciimage = CIImage(image:userPickedimage) else {fatalError("Could not covert to CIImage")}
            imagePicker.dismiss(animated: true, completion: nil)
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            let imageData = UIImageJPEGRepresentation(userPickedimage, 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            visualRecognition.classify(imagesFile: fileURL) { (classifiedimages) in
                let classes = classifiedimages.images.first!.classifiers.first!.classes
                self.classificationResults = []
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                print( self.classificationResults)
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                if self.classificationResults.contains("hotdog") {
                    // best practice to change UI is to use a displatchQueue
                    DispatchQueue.main.async{
                       self.navigationItem.title = "HOTDOG!"
                       self.navigationController?.navigationBar.barTintColor = UIColor.green
                       self.navigationController?.navigationBar.isTranslucent = false
                       self.topImageView.image = UIImage(named:"hotdog")
                    }
                   
                } else {
                    DispatchQueue.main.async{
                        self.navigationItem.title = "NOT HOTDOG!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                         self.topImageView.image = UIImage(named:"not-hotdog")
                        
                    }
                }
         
            }
        } else {
            print("There was an error picking the image")
        }
        
       
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
         staticHotdog.isHidden = true
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title!)")
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
            
        } else {
            self.navigationItem.title = "Please log in to Twitter"
        }
    }
    
}

