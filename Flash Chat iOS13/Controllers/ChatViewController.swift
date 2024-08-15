//
//  ChatViewController.swift
//  Flash Chat iOS13
//


import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    //Initialising the Database
    let db = Firestore.firestore()
    
    //Initialising Message array
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        
        //Hides the back button
        navigationItem.hidesBackButton = true
        
        //Setting the Delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        //Registering the custom Message Cell
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        //Loading the Messages
        loadMessages()
    }
    
    func loadMessages(){
        //Taping into Firebase for the Database
        //Ordering it by the Timestemp too
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            
            //Reseting the message array for Real Time Updation
            self.messages = []
            
            //Error Handling
            if let e = error{
                print("There was an issue retrieving data from Firebase \(e)")
            } else {
                //Creating a Snapshot
                if let snapshotDocuments = querySnapshot?.documents{
                    //Lopping over the retrieved array
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        //Optional Binding and Typecasting because the retrieved array element is of type Any
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            //Initialising a Message set
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            //Appending it to the Message array
                            self.messages.append(newMessage)
                            
                            //DispatchQueue for UI Updation in a Closure
                            DispatchQueue.main.async {
                                //Reloading the Message cells for updation
                                self.tableView.reloadData()
                                
                                //For Auto Scrolled to the bottom
                                //Creating an index for Scroll
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                //Actual scrolling
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        //Both the messageTextField and currentUser.email are optional that's why I have performed Optional Binding
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            //K.FStore are constant used, addDocuments has data in Dictionaries
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                //Error handling
                if let e = error{
                    print("There was an issue saving data to firestore, \(e)")
                } else{
                    print("Sucessfully saved data.")
                    
                    //Setting the messageTextField empty after sending the message
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        //Logout Function
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //Send the user to the root controller
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            //Error handling
            print("Error signing out: %@", signOutError)
        }
    }
    
}

extension ChatViewController: UITableViewDataSource{
    //Retrieving the Number of Messages
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //Loading the TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Storing the currentMessage
        let message = messages[indexPath.row]
        
        //Initialising the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        //This is a message from the Sender
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.white)
        } 
        //This is a message from another Sender
        else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.offWhite)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        return cell
    }
    
}

extension ChatViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
