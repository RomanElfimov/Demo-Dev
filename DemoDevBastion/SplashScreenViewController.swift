//
//  ViewController.swift
//  DemoDevBastion
//
//  Created by Роман Елфимов on 19.04.2021.
//

import UIKit

import Firebase

class SplashScreenViewController: UIViewController {
    
    // MARK: - Private Properties
    private var ref: DatabaseReference!
    private var deviceUID: String = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIsUserSignedIn()    
    }
    
    // MARK: - Actions
    
    @IBAction func connectDirectlyButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let navVC = storyboard.instantiateViewController(identifier: "ActiveDevicesListViewController") as? UINavigationController else { return }
        guard let activeDevicesVC = navVC.viewControllers.first as? ActiveDevicesListViewController else { return }
        activeDevicesVC.isDirectly = true
        present(navVC, animated: true, completion: nil)
    }
    
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        checkIsUserSignedIn()
    }
    
    private func checkIsUserSignedIn() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                
                // В зависимотси от того, есть у нас в БД deviceUID или нет, переходим на разные экраны
                // (Например после регистрации пользователь не выбрал устройтво6 а закрыл приложение)
                guard let currentUser = Auth.auth().currentUser else { return }
                self?.ref = Database.database().reference(withPath: "users")//.child(currentUser.uid)
                self?.ref.observe(.value) { (snapshot) in
                    
                    for item in snapshot.children {
                        let userData = User(snapshot: item as! DataSnapshot) //получаем пользователя
                        self?.deviceUID = userData.deviceUID // смотрbм deviceUID пользователя
            
                        // Если deviceUID нету, предлагаем выбрать устройство из списка доступных
                        
                        if userData.userID == currentUser.uid {
                            
                            if self?.deviceUID == "" {
                        
                                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                guard let navVC = storyboard.instantiateViewController(identifier: "ActiveDevicesListViewController") as? UINavigationController else { return }
                                self?.present(navVC, animated: true, completion: nil)
                            } else {
     
                                // Если deviceUID есть, показываем экран управления
                                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                guard let navVC = storyboard.instantiateViewController(identifier: "DeviceControlViewController") as? UINavigationController else { return }
                                self?.present(navVC, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
}







