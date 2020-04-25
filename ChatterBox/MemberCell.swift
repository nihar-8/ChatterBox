//  MemberCell.swift
//  ChatterBox
//  Created by Deepak on 25/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit

class MemberCell: UITableViewCell
{
    //MARK:- Outlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var tick: UIImageView!
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
