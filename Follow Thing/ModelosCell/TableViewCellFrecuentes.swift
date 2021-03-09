//
//  TableViewCellFrecuentes.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 22/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class TableViewCellFrecuentes: UITableViewCell {

    @IBOutlet var etiquetaTituloFrecuente: UILabel!
    
    @IBOutlet var puntoView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
          
        puntoView.backgroundColor = .black
        puntoView.redondoCompleto()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
    }

}
