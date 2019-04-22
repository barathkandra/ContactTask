//
//  AddContactViewController.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class AddContactViewController: CommonViewController {
    
    private lazy var detailsViewModel: ContactDetailsViewModel = {
        return ContactDetailsViewModel()
    }()
    
    @IBOutlet weak var contactDetailsTableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var activeTextField: UITextField!
    private var editingIndex: Int?

    var contactId = 0

    
    var contactDetailsDict: ContactDetails?
    private var placeholders = ["First Name", "Last Name", "Mobile", "Email"]
    
    private var contactDetails: [String] = []

    var isNew = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.tableViewSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.handlingTableViewScrolling()
        self.setStatusBarBackgroundColor(color: UIColor.init(red: 220.0/255.0, green: 246.0/255.0, blue: 240.0/255.0, alpha: 1.0))
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillAppear(animated)
        self.setStatusBarBackgroundColor(color: .white)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    // MARK:- Custom Methods
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        statusBar.backgroundColor = color
    }
    
    func handlingTableViewScrolling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    internal func tableViewSetup() {
        self.contactDetailsTableView.tableFooterView = UIView()
        self.contactDetailsTableView.rowHeight = UITableView.automaticDimension
        self.contactDetailsTableView.estimatedRowHeight = 100.0
    }
    
    private func setupView() {
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.layer.borderWidth = 3
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
        self.cameraButton.layer.cornerRadius = self.cameraButton.frame.height/2
        
        contactDetails.append(contactDetailsDict?.firstName ?? "")
        contactDetails.append(contactDetailsDict?.lastName ?? "")
        contactDetails.append(contactDetailsDict?.phoneNumber ?? "")
        contactDetails.append(contactDetailsDict?.email ?? "")
        
        if let profile = contactDetailsDict?.profilePic {
            self.profileImageView.downloadImage(url: profile, downloadComplete: nil)
        }

    }

    func base64( profile: UIImage) -> String? {
        let imageData = profile.pngData()
        return imageData?.base64EncodedString()
    }
    
    // MARK:- UIButtton Action Methods
    
    @IBAction func camera(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        for (index, value) in self.contactDetails.enumerated() {
            if value.isEmpty {
                let errorMessage = "Please Enter " + self.placeholders[index]
                Toast.shared().showToast(withDuration: 3, afterDelay: 0, withMessage: errorMessage, toastType: .error, hideToastAfterCompletion: true)
                self.activateEditing(at: index)
                return
            }
        }
        
        self.contactDetailsDict = ContactDetails(id: self.contactId, firstName: contactDetails[0], lastName: contactDetails[1], email: contactDetails[3], phoneNumber: contactDetails[2], profilePic: "", favorite: false, createdAt: "", updatedAt: "")
        
        if let profileImg = self.profileImageView.image {
            contactDetailsDict?.profilePic = self.base64(profile: profileImg)
        }
        
        self.detailsViewModel.contactDetails = contactDetailsDict
        
        let favourite = isNew ? false : (contactDetailsDict?.favorite ?? false)
        
        self.startLoading()
        self.detailsViewModel.callingAddOrUpdateDetailsService(contactId, favourite, isNew: isNew) { (error) in
            
            DispatchQueue.main.async {
                self.stopLoading()
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        
    }
    
    func activateEditing(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if let createContactCell = self.contactDetailsTableView.cellForRow(at: indexPath) as? ContactsDetailsCell {
            
            createContactCell.displayTextField.becomeFirstResponder()
        }
    }

}

extension AddContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placeholders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let createContactCell = tableView.dequeueReusableCell(withIdentifier: "contactDetails", for: indexPath) as? ContactsDetailsCell {
            createContactCell.contactDetailsProtocol = self
            createContactCell.assignDetails(placeholder: self.placeholders[indexPath.row], detail: self.contactDetails[indexPath.row], index: indexPath.row)
            return createContactCell
        }
        return UITableViewCell()
    }
    
}

extension AddContactViewController: ContactDetailsProtocol {
    
    func editingStarted(at index: Int) {
        
        let indexPath = IndexPath(row: index, section: 0)
        if let createContactCell = self.contactDetailsTableView.cellForRow(at: indexPath) as? ContactsDetailsCell {
            self.activeTextField = createContactCell.displayTextField
        }
        self.editingIndex = index
    }
    
    func editingFinishing(_ detail: String) {
        if let index = self.editingIndex {
            self.contactDetails[index] = detail
        }
        self.activeTextField = nil
        self.editingIndex = nil
    }
}

extension AddContactViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
    }
    
}
extension AddContactViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo : NSDictionary = notification.userInfo! as NSDictionary
        let rect : CGRect = userInfo.object(forKey: UIResponder.keyboardFrameBeginUserInfoKey) as! CGRect
        let edgeInsets : UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: rect.height+50, right: 0)
        self.contactDetailsTableView.contentInset = edgeInsets;
        self.contactDetailsTableView.scrollIndicatorInsets = edgeInsets;
        if (!rect.contains(self.activeTextField.frame.origin) ) {
            self.contactDetailsTableView.scrollRectToVisible(self.activeTextField.frame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        contactDetailsTableView.contentInset = contentInsets
        contactDetailsTableView.scrollIndicatorInsets = contentInsets;
        contactDetailsTableView.setContentOffset(CGPoint.zero, animated: true)
    }
}


