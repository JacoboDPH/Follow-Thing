//
//  CollectionViewCellFotos.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 13/09/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class CollectionViewCellFotos: UICollectionViewCell {
    
    @IBOutlet var foto: UIImageView!
    @IBOutlet var etiquetaDiaFoto: UILabel!
    @IBOutlet var etiquetaSeleccionFotos: UILabel!
    
    let altoFoto = UIScreen.main.bounds.size.width/3*CGFloat(numeroAureo)-5
    let anchoFoto = UIScreen.main.bounds.size.width/3-5
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configuraEtiquetaDiaFoto()
        configuraEtiquetaSeleccionFotos()
    }
    
//    MARK:- CONFIGURACIONES
    func configuraEtiquetaDiaFoto(){
       
        let altoEtiqueta01 = (altoFoto - anchoFoto)/CGFloat(numeroAureo)
        
        let altoEtiqueta = altoEtiqueta01/CGFloat(numeroAureo)
        
     
        etiquetaDiaFoto.frame = CGRect(x: 0, y: altoFoto-altoEtiqueta, width: anchoFoto, height: altoEtiqueta)
        etiquetaDiaFoto.font = fuenteCeldaInteriorCollection 
        etiquetaDiaFoto.textAlignment = .center
        etiquetaDiaFoto.textColor = .white
        
        etiquetaDiaFoto.backgroundColor = botonActivo.withAlphaComponent(0.5)
    }
    func configuraEtiquetaSeleccionFotos(){
        etiquetaSeleccionFotos.frame = CGRect(x: 0, y: 0, width: anchoFoto, height: altoFoto)
        etiquetaSeleccionFotos.font = fuentePopoverGrande
        etiquetaSeleccionFotos.textAlignment = .center
        etiquetaSeleccionFotos.textColor = .white
        etiquetaSeleccionFotos.backgroundColor =
            UIColor.black.withAlphaComponent(0.75)
        etiquetaSeleccionFotos.isHidden = true

    }
    
}
