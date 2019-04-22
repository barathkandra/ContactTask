//
//  ContactListViewController.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class ContactListViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {

    private lazy var listViewModel: ContactListViewModel = {
        return ContactListViewModel()
    }()
    
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callContactsListService()
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.init(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 1.0)
    }

    // MARK:- Custom Methods
    
    internal func tableViewSetup() {
        self.contactTableView.tableFooterView = UIView()
        self.contactTableView.rowHeight = UITableView.automaticDimension
        self.contactTableView.estimatedRowHeight = 200.0
        self.contactTableView.sectionIndexColor = UIColor.init(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1.0)
        self.contactTableView.sectionIndexBackgroundColor = UIColor.init(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
    }
    
    // MARK:- Calling Get Contacts List Service Method
    
    func callContactsListService() {
        
        if !Reachability.isConnectedToNetwork() {
            Toast.shared().showNoInternetToast()
            return
        }
        self.startLoading()
        listViewModel.callingGetContactService { (error) in
            DispatchQueue.main.async {
                self.stopLoading()
                if error == nil {
                    self.contactTableView.delegate = self
                    self.contactTableView.dataSource = self
                    self.contactTableView.reloadData()
                    return
                }
                
            }
        }
        
    }
    
    // MARK:- UIButton Action Methods
    
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        if let addContact = Utilities.navigatedView(bundle: "Main", identifier: "addContact") as? AddContactViewController {
            addContact.contactDetailsDict = nil
            addContact.isNew = true
            let addController = UINavigationController.init(rootViewController: addContact)
            self.navigationController?.present(addController, animated: true, completion: nil)
        }
    }
    
    // MARK:- UITableView Delegates and DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listViewModel.contactSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let contactKey = self.listViewModel.contactSectionTitles[section]
        if let contactValues = self.listViewModel.contactDictionary[contactKey] {
            return contactValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactListTableViewCell {
            
            let contactKey = self.listViewModel.contactSectionTitles[indexPath.section]
            if let contactValues = self.listViewModel.contactDictionary[contactKey] {
                cell.handlingContantResponse(contactValues[indexPath.row])
            }
            cell.selectionStyle = .none
            
            return cell
        }
        return UITableViewCell()

    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.listViewModel.contactSectionTitles
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String?{
        return self.listViewModel.contactSectionTitles[section].capitalized
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailsVC = Utilities.navigatedView(bundle: "Main", identifier: "ContactDetails") as? ContactDetailsViewController {
            let contactKey = self.listViewModel.contactSectionTitles[indexPath.section]
            if let contactValues = self.listViewModel.contactDictionary[contactKey] {
                detailsVC.contactId = contactValues[indexPath.row].id ?? 0
            }
            self.navigationController?.pushViewController(detailsVC, animated: true)

        }
    }
    
}

