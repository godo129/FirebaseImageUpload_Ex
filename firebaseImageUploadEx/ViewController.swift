//
//  ViewController.swift
//  firebaseImageUploadEx
//
//  Created by hong on 2021/11/04.
//

import UIKit
import FirebaseStorage


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageView = UIImageView()
    let label = UILabel()
    
    private let storage = Storage.storage().reference()
    
    let uploadButton: UIButton = {
        let uploadButton = UIButton()
        uploadButton.setTitle("upload", for: .normal)
        uploadButton.setTitleColor(.black, for: .normal)
        return uploadButton
    }()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.numberOfLines = 0
        label.textAlignment = .center
        imageView.contentMode = .scaleAspectFit
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
              let url = URL(string: urlString) else {

            return
        }
        
        label.text = urlString
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
            
        }
        
        task.resume()
        

        
        view.addSubview(uploadButton)
        view.addSubview(imageView)
        view.addSubview(label)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)

    }
    
    @objc private func uploadButtonTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        /*
          /Desktop/file.png
         */
        
        
        storage.child("images/file.png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Faild to upload")
                return
            }
            
            self.storage.child("images/file.png").downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                
                DispatchQueue.main.async {
                    self.label.text = urlString
                    self.imageView.image = image
                }
                
                print("Download URL : \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            }
        }
        
        //upload image data
        // get download url
        // save download url to userDefault
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        uploadButton.frame = CGRect(x: 100, y: 300, width: 100, height: 100)
        imageView.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        label.frame = CGRect(x: 100, y: 500, width: 200, height: 200)
        
        
    }

}

