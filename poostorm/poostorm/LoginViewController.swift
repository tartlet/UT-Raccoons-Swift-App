//
//  LoginViewController.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/24/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var signSegment: UISegmentedControl!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // onload, animate login iamge
        imageView.addSubview(iconImageView)
        imageView.backgroundColor = UIColor(named: "LaunchScreenBackground")
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 3, y: 3)
        })
        //stylize segment control
        let font = UIFont(name:"Menlo", size: 10.0)
        let boldFont = UIFont(name:"Menlo", size: 10.0)
        let normalAttribute: [NSAttributedString.Key: Any] = [.font: font!,
                                                              .foregroundColor: UIColor.white]
        signSegment.setTitleTextAttributes(normalAttribute, for: .normal)
        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: boldFont!,
                                                                .foregroundColor: UIColor.black]
        signSegment.setTitleTextAttributes(selectedAttribute, for: .selected)
        
        view.backgroundColor = UIColor(named: "LaunchScreenBackground")
        userField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        statusLabel.numberOfLines = 0
        confirmPasswordField.isHidden = true
        confirmPasswordLabel.isHidden = true
        signButton.setTitle("Sign In", for: .normal)
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                
                self.userField.text = nil
                self.passwordField.text = nil
                self.confirmPasswordLabel.text = nil
            }
        }
    }
    
    @IBAction func signType(_ sender: Any) {
        switch
            signSegment
            .selectedSegmentIndex {
        case 0:
            confirmPasswordField.isHidden = true
            confirmPasswordLabel.isHidden = true
            signButton.setTitle("Sign In", for: .normal)
        case 1:
            confirmPasswordField.isHidden = false
            confirmPasswordLabel.isHidden = false
            signButton.setTitle("Sign Up", for: .normal)
        default:
            break
        }
    }
    
    @IBAction func signButton(_ sender: Any) {
        if signButton.currentTitle == "Sign In" {
            Auth.auth().signIn(withEmail: userField.text!, password: passwordField.text!) {
                authResult, error in
                if let error = error as NSError? {
                    self.statusLabel.text = "\(error.localizedDescription)"
                } else {
                    self.statusLabel.text = ""
                }
            }
        } else {
            if passwordField.text == confirmPasswordField.text {
                Auth.auth().createUser(withEmail: userField.text!, password: passwordField.text!) {
                    authResult, error in
                    if let error = error as NSError? {
                        self.statusLabel.text = "\(error.localizedDescription)"
                    } else {
                        self.statusLabel.text = ""
                    }
                }
            } else {
                self.statusLabel.text = "Passwords must match"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

