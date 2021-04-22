//
//  SignUpTableViewController.swift
//  DemoDevBastion
//
//  Created by Роман Елфимов on 20.04.2021.
//

import UIKit
import Firebase

class SignUpTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var ref: DatabaseReference!
    private var accessLevel: String = ""
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        signUpButton.backgroundColor = .clear
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor(named: "BastColor")?.cgColor
        
        tableView.tableFooterView = UIView()
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    // MARK: - Actions
    @IBAction func chooseAccessLevelButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: "Зарегистрируйтесь как:", preferredStyle: .alert)
        let factroyAction = UIAlertAction(title: "Производитель", style: .default) { (_) in
            self.accessLevel = "0"
        }
        let ownerAction = UIAlertAction(title: "Владелец", style: .default) { (_) in
            self.accessLevel = "1"
        }
        let userAction = UIAlertAction(title: "Пользователь", style: .default) { (_) in
            self.accessLevel = "2"
        }
        let guestAction = UIAlertAction(title: "Гость", style: .default) { (_) in
            self.accessLevel = "4"
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        alertController.addAction(factroyAction)
        alertController.addAction(ownerAction)
        alertController.addAction(userAction)
        alertController.addAction(guestAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        guard let userEmail = emailTextField.text, userEmail != "", let userPassword = passwordTextField.text, userPassword != "", let username = nameTextField.text, username != "", let userSurname = surnameTextField.text, userSurname != "" else {
            
            let alertController = UIAlertController(title: "Некорректные данные", message: "Убедитесь в заполнении всех полей", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard accessLevel != "" else {
            let alertController = UIAlertController(title: "", message: "Укажите уровень доступа к устройству", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
//            // TODO: 2
//            // save to data base
            let user = User(email: userEmail, name: username, surname: userSurname, accessLevel: self.accessLevel, deviceUID: "")
            let userRef = self.ref.child(user.surname.lowercased())
            userRef.setValue(["email": user.email, "name": user.name, "surname": user.surname, "accessLevel": user.accessLevel, "deviceUID": user.deviceUID])

            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            guard let navVC = storyboard.instantiateViewController(identifier: "ActiveDevicesListViewController") as? UINavigationController else { return }
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Extension UITextField
extension SignUpTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            surnameTextField.becomeFirstResponder()
        } else if textField == surnameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
}
