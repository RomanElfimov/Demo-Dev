//
//  PrivateOfficeTableViewController.swift
//  DemoDevBastion
//
//  Created by Роман Елфимов on 20.04.2021.
//

import UIKit
import Firebase

class PrivateOfficeTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var ref: DatabaseReference!
    private var accessLevel: String = ""
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var accessLevelLabel: UILabel!
    
    //Удаляем наблюдателя по выходу
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        ref = Database.database().reference(withPath: "users")
        
        ref.observe(.value) { [weak self] (snapshot) in
            
            guard let self = self else { return }
            
            for item in snapshot.children {
                //Получаем данные
                let userData = User(snapshot: item as! DataSnapshot)
                
                if userData.userID == currentUser.uid {
                    
                    print(userData)
                    
                    DispatchQueue.main.async {
                        self.nameLabel.text = "\(userData.name) \(userData.surname)"
                        self.emailLabel.text = userData.email
                        
                        var accessLevelText: String = ""
                        switch userData.accessLevel {
                        case "0":
                            accessLevelText = "Производитель"
                        case "1":
                            accessLevelText = "Владелец"
                        case "2":
                            accessLevelText = "Пользователь"
                        case "4":
                            accessLevelText = "Гость"
                        default:
                            break
                        }
                        self.accessLevelLabel.text = accessLevelText
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func forgetDeviceButtonTapped(_ sender: Any) {
        print("forget device")
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child(currentUser.uid).updateChildValues(["deviceUID": ""])
        performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }

        performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
    }
    
    @IBAction func changeAccessLevelButtonTapped(_ sender: Any) {
        
        // showAlert
        // ref.updateChildValues
        guard let currentUser = Auth.auth().currentUser else { return }
        let alertController = UIAlertController(title: "", message: "Зарегистрируйтесь как:", preferredStyle: .alert)
        let factroyAction = UIAlertAction(title: "Производитель", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.accessLevel = "0"
            self.ref.child(currentUser.uid).updateChildValues(["accessLevel": self.accessLevel])
            self.performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
        }
        let ownerAction = UIAlertAction(title: "Владелец", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.accessLevel = "1"
            self.ref.child(currentUser.uid).updateChildValues(["accessLevel": self.accessLevel])
            self.performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
        }
        let userAction = UIAlertAction(title: "Пользователь", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.accessLevel = "2"
            self.ref.child(currentUser.uid).updateChildValues(["accessLevel": self.accessLevel])
            self.performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
        }
        let guestAction = UIAlertAction(title: "Гость", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            self.accessLevel = "4"
            self.ref.child(currentUser.uid).updateChildValues(["accessLevel": self.accessLevel])
            self.performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        alertController.addAction(factroyAction)
        alertController.addAction(ownerAction)
        alertController.addAction(userAction)
        alertController.addAction(guestAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        currentUser.delete { [weak self] (error) in
            if error == nil {
                self?.performSegue(withIdentifier: "unwindToSplashFromPrivateOffice", sender: self)
            } else {
                let alertController = UIAlertController(title: "Не получилось удалить пользователя", message: "Попробуйте снова", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
                alertController.addAction(cancelAction)
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
}
