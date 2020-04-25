//  GroupCell.swift
//  ChatterBox
//  Created by Deepak on 25/02/20.
//  Copyright © 2020 Deepak. All rights reserved.

import UIKit

class GroupCell: UITableViewCell
{
    //MARK:- Outlets
    @IBOutlet weak var groupPic: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var admin: UILabel!
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
