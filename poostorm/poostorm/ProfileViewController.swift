//
//  ProfileViewController.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/25/22.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

public var displayName:String = ""

protocol PersonalProfileTableViewControllerDelegate {
    func changeText()
}

protocol changeDisplayName {
    func changeDispName()
}

protocol changePassword {
    func changePw()
}

class ProfileViewController: UIViewController, ProfileViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, changeDisplayName, changePassword{
    
    var profileTableViewController: PersonalProfileTableViewController?
    let picker = UIImagePickerController()
    let profileImage = UIImageView()
    var userStorage:StorageReference!
    var ref:DatabaseReference!
    var delegate3: PersonalProfileTableViewControllerDelegate?
    @IBOutlet weak var dummyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://poostorm-a074d.appspot.com")
        userStorage = storage.child("users")
        profileImage.contentMode = UIView.ContentMode.scaleAspectFill
        profileImage.frame.size.width = 100
        profileImage.frame.size.height = 100
        profileImage.layer.cornerRadius = 50
        profileImage.clipsToBounds = true
        profileImage.center = CGPoint(x: 80, y: 200)
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.black.cgColor
        // Reference to an image file in Firebase Storage
        getProfileImage()
        getDisplayName()
        self.view.addSubview(profileImage)
        profileTableViewController = self.children[0] as? PersonalProfileTableViewController
        profileTableViewController?.delegate = self
        profileTableViewController?.delegate2 = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getDisplayName()
        getProfileImage()
    }
    
    func getProfileImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            profileImage.image = UIImage(named: "default.jpeg")
            return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let profileImgeURL = dictionary["urlToImage"] as? String else { return}
            guard let url = URL(string: profileImgeURL) else {return}
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let err = error {
                    print("failed to show", err)
                    return
                }
                guard let data = data else {return}
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.profileImage.image = image}}.resume()
        })
    }
    
    func getDisplayName(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let dispName = dictionary["displayName"] as? String else { return }
            displayName = dispName
            if let delegate3 = self.delegate3 {
                delegate3.changeText()
            }
            self.dummyLabel.text = displayName
            print(self.dummyLabel.text!)
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as! UIImage
        profileImage.image = chosenImage
        dismiss(animated: true)
    }

    func changeImg() {
        let profilePicAlert = UIAlertController(title: "Change Profile Picture",
                                                message: "",
                                                preferredStyle: .actionSheet)
        profilePicAlert.addAction(UIAlertAction(title: "Take a Photo",
                                                style: .default,
                                               handler: {
            _ in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                // use the rear camera
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .notDetermined:
                    // we don't know
                    AVCaptureDevice.requestAccess(for: .video) {
                        accessGranted in
                        guard accessGranted == true else { return }
                    }
                case .authorized:
                    // we have permission already
                    break
                default:
                    // we know we don't have access
                    print("Access denied")
                    return
                }
            
                self.picker.allowsEditing = false
                self.picker.sourceType = .camera
                self.picker.cameraCaptureMode = .photo
                self.present(self.picker, animated: true)
                
            } else {
                // no rear camera is available
                
                let alertVC = UIAlertController(
                    title: "No camera",
                    message: "Sorry, this device has no rear camera",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(
                    title: "OK",
                    style: .default)
                alertVC.addAction(okAction)
                self.present(alertVC,animated:true)
            }
        }))
        profilePicAlert.addAction(UIAlertAction(title: "Choose a photo",
                                                style: .default,
                                               handler: {
            _ in
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        }))
        profilePicAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(profilePicAlert, animated: true)
        
        let user = Auth.auth().currentUser
        if let user = user {
            let imageRef = self.userStorage.child("\(user.uid).jpg")
            let data = profileImage.image!.jpegData(compressionQuality: 0.5)
            let uploadImage = imageRef.putData(data!,
                                                      metadata: nil,
                                                      completion:
                {(metadata, error) in
                imageRef.downloadURL(completion: {(url, error) in
                        let userInfo: [String:Any] = ["uid":user.uid,
                                                      "urlToImage": url!.absoluteString,
                                                    "displayName": user.email!]
                        self.ref.child("users").child(user.uid).setValue(userInfo)

                        })
                    })
            uploadImage.resume()
        }
    }
    
    func changeDispName() {
        let changeUserAlert = UIAlertController(title: "Username Change",
                                                message: "Please enter your new desired display name below:",
                                                preferredStyle: .alert)
        changeUserAlert.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Enter new display name"
        })
        changeUserAlert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {
                (paramAction:UIAlertAction!) in
                if let textFieldArray = changeUserAlert.textFields {
                    let textFields = textFieldArray as [UITextField]
                    let enteredText = textFields[0].text
                    let dispNameChangeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    dispNameChangeRequest.displayName = enteredText!
                    dispNameChangeRequest.commitChanges(completion: nil)
                    let user = Auth.auth().currentUser
                    self.ref.child("users").child(user!.uid).child("displayName").setValue(enteredText!)
                }
                if let delegate3 = self.delegate3 {
                    delegate3.changeText()
                    self.viewDidLoad()
                }
            }))
        changeUserAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(changeUserAlert, animated: true)
    }
    
    func changePw() {
        let changePassAlert = UIAlertController(title: "Password Change",
                                                message: "Enter and confirm new password:",
                                                preferredStyle: .alert)
        changePassAlert.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Enter new password"
        })
        changePassAlert.addTextField(configurationHandler: {
            (textField:UITextField!) in
            textField.placeholder = "Re-enter new password"
        })
        changePassAlert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: {
                (paramAction:UIAlertAction!) in
                if let passTextFieldArray = changePassAlert.textFields {
                    if passTextFieldArray[0] == passTextFieldArray[1] {
                        Auth.auth().currentUser!.updatePassword(to: passTextFieldArray[0].text!) {
                            error in
                            if error != nil{
                                print("An error occurred")
                            }
                        }
                    }
                }
            }))
        changePassAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(changePassAlert, animated: true)
    }
    
}
