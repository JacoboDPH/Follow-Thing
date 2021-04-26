//
//  TableViewCellPrincipal.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 30/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class TableViewCellPrincipal: UITableViewCell {

//    MARK:- IBOULETS
    
    @IBOutlet var etiquetaTitulo: UILabel!
    @IBOutlet var etiquetaDia: UILabel!
    @IBOutlet var etiquetaUltimaVez: UILabel!
    @IBOutlet var iconoColor: UIView!
    @IBOutlet weak var btnAlarma: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconoColor.redondoCompleto()
        selectionStyle = .none
        
    
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
//    cambiarColor(color: .gray)
           
//            superRebotar()
        }
         // Configure the view for the selected state
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
        
        // Swift 4.1 and below
      
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
}
