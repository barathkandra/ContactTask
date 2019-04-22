//
//  ContactListTableViewCell.swift
//  ContactTask
//
//  Created by Bharath on 18/04/19.
//  Copyright © 2019 Bharath. All rights reserved.
//

import UIKit

class ContactListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var favImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupView()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func setupView(){
        profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    
    func handlingContantResponse(_ contactList: ContactListElement) {
        
        let firstName = contactList.firstName ?? ""
        let lastName = contactList.lastName ?? ""
        
        fullNameLabel.text = firstName + " " + lastName
        
        if let favorite = contactList.favorite {
            favImageView.isHidden = !favorite 
        }
        if let profilePic = contactList.profilePic {
            self.profileImageView.downloadImage(url: BASE_URL + profilePic, downloadComplete: nil)
        }
    }

}
