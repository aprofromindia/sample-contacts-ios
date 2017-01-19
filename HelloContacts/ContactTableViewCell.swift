//
//  ContactTableViewCell.swift
//  HelloContacts
//
//  Created by Choudhury, Apratim (201) on 19/01/2017.
//  Copyright © 2017 Apro. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contactImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contactImage.image = nil
    }
}
