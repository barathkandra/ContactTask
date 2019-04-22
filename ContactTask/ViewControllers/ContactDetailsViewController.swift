//
//  ContactDetailsViewController.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit
import MessageUI


class ContactDetailsViewController: CommonViewController, MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    private lazy var detailsViewModel: ContactDetailsViewModel = {
        return ContactDetailsViewModel()
    }()
    
    var contactId = 0
    var contactDetails = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.addingRightBarButton()
        self.tableViewSetup()

        favButton.setImage(UIImage(named: "starImage"), for: .selected)
        favButton.setImage(UIImage(named: "unStarImage"), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    func addingRightBarButton() {
        
        let editButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction))
        self.navigationItem.setRightBarButton(editButton, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callContactsDetailsService()
    }
    private func setupView() {
        self.profilePic.layer.cornerRadius = self.profilePic.frame.height/2
        self.profilePic.layer.borderColor = UIColor.white.cgColor
        self.profilePic.layer.borderWidth = 2.0
    }
    
    internal func tableViewSetup() {
        self.detailsTableView.tableFooterView = UIView()
        self.detailsTableView.rowHeight = UITableView.automaticDimension
        self.detailsTableView.estimatedRowHeight = 150.0
        self.detailsTableView.delegate = self
        self.detailsTableView.dataSource = self

    }
    
    
    // MARK:- Calling Get Contacts List Service Method
    
    func callContactsDetailsService() {
        self.startLoading()
        detailsViewModel.getContactDetailsFromService(contactId) { (error) in
            DispatchQueue.main.async {
                self.stopLoading()
                if error == nil {
                    
                    if let details = self.detailsViewModel.contactDetails {
                        self.favButton.isSelected = details.favorite ?? false
                        let firstName = details.firstName ?? ""
                        let lastName = details.lastName ?? ""
                        self.nameLabel.text = firstName + " " + lastName
                        if let profilePic = details.profilePic {
                            self.profilePic.downloadImage(url: BASE_URL + profilePic, downloadComplete: nil)
                        }
                        self.detailsTableView.reloadData()

                    }
                    return
                }
            }
        }
    }
    
    // MARK:- Calling Update Favorite Method
    
    func updateFavorite(_ fav: Bool) {
        self.startLoading()
        detailsViewModel.callingAddOrUpdateDetailsService(contactId, fav) { (error) in
            DispatchQueue.main.async {
                self.stopLoading()
                if error == nil {
                    
                    if let details = self.detailsViewModel.contactDetails {
                        self.favButton.isSelected = details.favorite ?? false
                    }
                    return
                }
            }
        }
    }
      
    // MARK:- UIButtton Action Methods
    
    @objc func editButtonAction(_ sender: UIBarButtonItem) {
        if let editButton = Utilities.navigatedView(bundle: "Main", identifier: "addContact") as? AddContactViewController {
            editButton.contactDetailsDict = self.detailsViewModel.contactDetails
            editButton.isNew = false
            editButton.contactId = contactId
            let editController = UINavigationController.init(rootViewController: editButton)
            self.navigationController?.present(editController, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendMessageButtonAction(_ sender: Any) {
        displayMessageInterface()
    }
    
    @IBAction func sendMailButtonAction(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        sendEmail()
    }
    
    @IBAction func makeCallButtonAction(_ sender: Any) {
        
        if let phoneNumber = self.detailsViewModel.contactDetails?.phoneNumber {
            phoneNumber.makeACall()
        }
        
    }

    @IBAction func favouriteButtonAction(_ sender: Any) {
        self.updateFavorite(!favButton.isSelected)
    }
    
    // MARK:- Message Compose Method
    
    func displayMessageInterface() {
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        if let phoneNumber = self.detailsViewModel.contactDetails?.phoneNumber {
            composeVC.recipients = [phoneNumber]
        }
        composeVC.body = ""
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
    
    // MARK:- Message Compose Delegate Method
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Sending Mail Method
    
    func sendEmail() {
        let mailVC = MFMailComposeViewController()
        if let sentId = self.detailsViewModel.contactDetails?.email {
            mailVC.setToRecipients([sentId])
        } else {
            mailVC.setToRecipients([])
        }
        mailVC.setSubject("Subject for email")
        mailVC.setMessageBody("Email message string", isHTML: false)
        mailVC.mailComposeDelegate = self
        present(mailVC, animated: true, completion: nil)
    }
    
    // MARK: - Email Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- UITableView Delegates and DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contactDetails", for: indexPath) as? ContactsDetailsCell {
            cell.displayTextField.isUserInteractionEnabled = false
            if indexPath.row == 0 {
                cell.titleLabel.text = "Mobile"
                cell.displayTextField.text = self.detailsViewModel.contactDetails?.phoneNumber ?? ""
            } else {
                cell.titleLabel.text = "email"
                 cell.displayTextField.text = self.detailsViewModel.contactDetails?.email ?? ""
            }
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()
    }
}
