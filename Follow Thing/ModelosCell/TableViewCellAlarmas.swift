//
//  TableViewCellAlarmas.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 31/10/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class TableViewCellAlarmas: UITableViewCell {

//    MARK:- IBOULETS
    @IBOutlet var btn01CellAlarma: UIButton!
   
    @IBOutlet var etiquetaTituloAlarma: UILabel!
    @IBOutlet var etiquetaSubtitulo: UILabel!    
    @IBOutlet var contenedorEtiquetas: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        etiquetaTituloAlarma.font = fuentePopover
        etiquetaSubtitulo.font = fuenteCeldaInteriorCollection
        
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
