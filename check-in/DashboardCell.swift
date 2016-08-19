//
//  DashboardCell.swift
//  check-in
//
//  Created by Matt Garnett on 8/16/16.
//  Copyright © 2016 Matt Garnett. All rights reserved.
//

import UIKit

class DashboardCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
