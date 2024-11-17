//
//  LapListCellTableViewCell.swift
//  industrialchronometer
//
//  Created by ulas özalp on 14.02.2022.
//

import UIKit

class LapListCellTableViewCell: UITableViewCell {
  
    
    /** About tableView components */
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var icon: UIImageView!
    
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
       //toggleSwitch.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        // Initialization code
    }
    
    @IBAction func toggleSwitched(_ sender: Any) {
     
       /*
        tıkladığından notification geönderiyor
        */
//            NotificationCenter.default.post(name: .pauseLapOff, object: nil)
//
       
      
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

}

