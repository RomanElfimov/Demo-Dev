//
//  DeviceControlViewController.swift
//  DemoDevBastion
//
//  Created by Роман Елфимов on 20.04.2021.
//

import UIKit
import CocoaMQTT
import Firebase

class DeviceControlViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var ref: DatabaseReference!
    private var deviceUID: String = "" // при подключении напрямую приходит с предыдущего экрана, при автоматической авторизации приходит из Firebase
    private var accessLevel: String = ""
    
    private var mqtt: CocoaMQTT!
    private var globalTopic: String = ""
    
    // MARK: - Outlets
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    @IBOutlet weak var ledOneSwitch: UISwitch!
    @IBOutlet weak var ledTwoSwitch: UISwitch!
    @IBOutlet weak var ledThreeSwitch: UISwitch!
    @IBOutlet weak var ledFourSwitch: UISwitch!
    @IBOutlet weak var buzerButton: UIButton!
    
    
    // MARK: - LifeCycle
    // Для получения данных создадим наблюдателя
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ref = Database.database().reference(withPath: "users")
        
        ref.observe(.value) { (snapshot) in
            
            var level: String = ""
            var uid: String = ""
            
            for item in snapshot.children {
                //Получаем данные
                let userData = User(snapshot: item as! DataSnapshot)

                uid = userData.deviceUID
                level = userData.accessLevel
                print("//--")
                print(userData)
                print("--//")
            }
            
            self.deviceUID = uid
            self.accessLevel = level
            
        }
    }
    
    //Удаляем наблюдателя по выходу
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        ref.removeAllObservers()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загрузить из Firebase deviceUID
        
        let logo = UIImage(named: "logo")        
        setTitle("DemoDev", andImage: logo!)
        
        setupMQTT()
        connectAck()
        receiveMessage()
        
        tableView.tableFooterView = UIView()
        buzerButton.layer.cornerRadius = buzerButton.frame.size.height / 2
        buzerButton.clipsToBounds = true
        
    
    }
    
    
    // MARK: - Actions
    @IBAction func ledOneSwitchTapped(_ sender: UISwitch) {
        publishSwitchMessage(led: "led01", sender: sender)
    }
    
    @IBAction func ledTwoSwitchTapped(_ sender: UISwitch) {
        publishSwitchMessage(led: "led02", sender: sender)
    }
    
    @IBAction func ledThreeSwitchTapped(_ sender: UISwitch) {
        publishSwitchMessage(led: "led03", sender: sender)
    }
    
    @IBAction func ledFourSwitchTapped(_ sender: UISwitch) {
        publishSwitchMessage(led: "led04", sender: sender)
    }
    
    @IBAction func buzerButtonTapped(_ sender: Any) {
        
        let message = CocoaMQTTMessage(topic: "FF01/NTdHEDI5MTA8AEsA/0/0123456789/req/buzer", string: "1")
        mqtt.publish(message)
    }
    
    
    @IBAction func openPrivateOfficeButtonTapped(_ sender: Any) {
        
        // Добавить проверку на то, есть ли аккаунт, если нет, показывать только ячейку "Забыть устройство"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let privateOfficeVC = storyboard.instantiateViewController(identifier: "PrivateOfficeTableViewController") as? PrivateOfficeTableViewController else { return }
        navigationController?.pushViewController(privateOfficeVC, animated: true)
     }
    
    // MARK: - Private Methods
    private func setupMQTT() {
        
        let clientId = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        
        let host: String = "test.mosquitto.org"
        let port: UInt16 = 1883
        
        mqtt = CocoaMQTT(clientID: clientId, host: host, port: port)
        mqtt.keepAlive = 60
        mqtt.connect()
    }
    
    private func connectAck() {
        mqtt.didConnectAck = { [weak self] _, _ in
//            print("Connected at DeviceControlViewController")
            
            guard let self = self else { return }
            
//            print("DeviceUID \(self.deviceUID)")
            self.globalTopic = "FF01/\(self.deviceUID)/"
            let top = self.globalTopic + "#"
            self.mqtt.subscribe(top)
            
//            print(top)
        }
    }
    
    private func receiveMessage() {
        mqtt.didReceiveMessage = { [weak self] mqtt, message, id in
            
            guard let self = self else { return }
//                        print("Topic \(message.topic)")
//                        print("Message \(message.string)")
            
            let topic = message.topic
            guard let msgString = message.string else { return }
            
            
            // TODO: Отрефакторить
            
            if topic == "\(self.globalTopic)data/outputs/led01" {
                
                DispatchQueue.main.async {
                    if msgString == "0" {
                        self.ledOneSwitch.isOn = false
                    } else {
                        self.ledOneSwitch.isOn = true
                    }
                }
            } else if topic == "\(self.globalTopic)data/outputs/led02" {
                DispatchQueue.main.async {
                    if msgString == "0" {
                        self.ledTwoSwitch.isOn = false
                    } else {
                        self.ledTwoSwitch.isOn = true
                    }
                }
                
            } else if topic == "\(self.globalTopic)data/outputs/led03" {
                DispatchQueue.main.async {
                    if msgString == "0" {
                        self.ledThreeSwitch.isOn = false
                    } else {
                        self.ledThreeSwitch.isOn = true
                    }
                }
            } else if topic == "\(self.globalTopic)data/outputs/led04" {
                DispatchQueue.main.async {
                    if msgString == "0" {
                        self.ledFourSwitch.isOn = false
                    } else {
                        self.ledFourSwitch.isOn = true
                    }
                }
            }
        }
    
    }
    
    
    //    private func setupInterface(led01: Bool) {
    //        ledOneSwitch.isOn = led01
    //    }
    
    private func publishSwitchMessage(led: String, sender: UISwitch) {
        var stringMessage = ""
        
        if sender.isOn {
            stringMessage = "1"
        } else {
            stringMessage = "0"
        }
        
        // TODO: Менять урвоень доступа (owner, user...)
        print("ACCESS LEVEL \(accessLevel)")
        print("DEV UID \(deviceUID)")
        let message = CocoaMQTTMessage(topic: "FF01/\(deviceUID)/\(accessLevel)/0123456789/req/\(led)", string: stringMessage)
        
        mqtt.publish(message)
    }
    
    
    // MARK: - TableView Data Source
  
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        
        var height2: CGFloat = 0
        var height3: CGFloat = 0
        var height4: CGFloat = 0
        var height5: CGFloat = 0
        
        var access: String = ""
        
        ref.observe(.value) { (snapshot) in
            
            
            for item in snapshot.children {
                //Получаем данные
                let userData = User(snapshot: item as! DataSnapshot)
                
                if userData.accessLevel == "4" {
                    height2 = 0
                    height3 = 0
                    height4 = 0
                    height5 = 0
                } else if userData.accessLevel == "2" {
                    height4 = 0
                } else if userData.accessLevel == "0" {
                    height2 = tableView.estimatedRowHeight
                    height3 = tableView.estimatedRowHeight
                    height4 = tableView.estimatedRowHeight
                    height5 = tableView.estimatedRowHeight
                }
                
//                access = userData.accessLevel
                
            }
            
    

        }
        
        print("Data source \(access)")
        

            if indexPath.row == 2 {
                return height2
            } else if indexPath.row == 3 {
                return height3
            } else if indexPath.row == 4 {
                return height4
            } else if indexPath.row == 5 {
                return height5
            }
        
        
//        tableView.reloadData()
        return tableView.estimatedRowHeight
    }
    */
}





