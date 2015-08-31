//
//  MoviesCell.swift
//  Rotten Tomatos
//
//  Created by Nguyễn Vương Anh Vỹ on 8/28/15.
//  Copyright (c) 2015 Nguyễn Vương Anh Vỹ. All rights reserved.
//

import UIKit

class MoviesCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var postersView: UIImageView!
    @IBOutlet weak var mpaaLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
