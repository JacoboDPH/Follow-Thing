//
//  CollectionViewCellColores.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 22/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class CollectionViewCellColores: UICollectionViewCell {
    
    @IBOutlet var etiquetaColoresCell: UILabel!
    @IBOutlet var vistaCeldaColores: UIView!
    
    override var isHighlighted: Bool {
          didSet {
            superRebotar()
          }
      }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        vistaCeldaColores.redondoCompleto()
        
    
       
    }
}
