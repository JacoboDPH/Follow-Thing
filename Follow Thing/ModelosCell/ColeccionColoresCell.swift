//
//  ColeccionColoresCell.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 27/11/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class ColeccionColoresCell: UICollectionViewCell {
    
    @IBOutlet weak var contenedor: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.bounds.size.width = UIScreen.main.bounds.size.width/9
        contentView.bounds.size.height = UIScreen.main.bounds.size.width/9
        
        contentView.redondoCompleto()
          
    }
    override var isHighlighted: Bool {
          didSet {
            
            layoutIfNeeded()
          }
        
      }
   
}
