//
//  ContactsDetailsCell.swift
//  ContactTask
//
//  Created by Bharath on 20/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit


protocol ContactDetailsProtocol {
    func editingStarted(at index: Int)
    func editingFinishing(_ detail: String)
}

class ContactsDetailsCell: UITableViewCell {
    
    var contactDetailsProtocol: ContactDetailsProtocol?

    @IBOutlet weak var titleLabel : UILabel!
    
    @IBOutlet weak var displayTextField : UITextField! {
        didSet {
            self.displayTextField.delegate = self
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func assignDetails(placeholder: String, detail: String, index: Int) {
        self.displayTextField.tag = index
        self.titleLabel.text = placeholder
        self.displayTextField.placeholder = "Enter " + placeholder
        self.displayTextField.text = detail
    }
    

}

extension ContactsDetailsCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.contactDetailsProtocol?.editingStarted(at: textField.tag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.displayTextField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.contactDetailsProtocol?.editingFinishing(textField.text ?? "")
        return true
    }
    
}
