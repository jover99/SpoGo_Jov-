//
//  GameTableViewCell.swift
//  SpoGo
//
//  Created by Richard Jove on 12/2/19.
//  Copyright © 2019 Richard Jove. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gameCellIcon: UIImageView!
    @IBOutlet weak var gameCellLocation: UILabel!
    @IBOutlet weak var gameCellTemp: UILabel!
    @IBOutlet weak var gameCellTextView: UITextView!
    @IBOutlet weak var gameCellWeatherIcon: UIImageView!
    @IBOutlet weak var gameCellAverageSkill: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
