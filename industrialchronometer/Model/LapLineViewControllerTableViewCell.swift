//
//  LapLineViewControllerTableViewCell.swift
//  industrialchronometer
//
//  Created by ulas özalp on 3.11.2024.
//

import UIKit
protocol SupportedFeaturesForLapLine {
    
   func onAddLapNotes ( index : Int) // note eklemek için fonksiyon
}

class LapLineViewControllerTableViewCell: UITableViewCell {
    var cellDelegate: SupportedFeaturesForLapLine?
    var index: IndexPath = []
    
    @IBOutlet weak var lapCycle: UILabel!
    
    @IBOutlet weak var lapValue: UILabel!
    @IBOutlet weak var lapLabel: UILabel!
    
    @IBOutlet weak var AddNote: UIButton!
    
    @IBAction func AddNote(_ sender: UIButton) {
        
        cellDelegate?.onAddLapNotes(index: index.row)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func kkkk(_ sender: UIButton) {
        print("ulas")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
