//  ContactCell.swift
//  ChatterBox
//  Created by Deepak on 24/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit

class ContactCell: UITableViewCell
{
    //MARK:- Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    //MARK:- AwakeFromNib
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    //MARK:- SetSelected
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
