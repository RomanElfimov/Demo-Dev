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
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
   
    @IBOutlet weak var accessLevelLabel: UILabel!
   
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        ref.observe(.value) { [weak self] (snapshot) in

            guard let self = self else { return }
            
            for item in snapshot.children {
                //Получаем данные
                let userData = User(snapshot: item as! DataSnapshot)

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

    // MARK: - Actions
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
