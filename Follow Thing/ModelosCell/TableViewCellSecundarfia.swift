//
//  TableViewCellSecundarfia.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 09/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class TableViewCellSecundarfia: UITableViewCell {

//    MARK:-IBOULTES
    
    @IBOutlet var etiqDiaGuardado: UILabel!
    @IBOutlet var etiqHoraGuardada: UILabel!    
    @IBOutlet var etiqContenidoCelda: UILabel!
    
    @IBOutlet var contendorExpansible: UIView!
    
    @IBOutlet weak var monitorActividad: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        etiqContenidoCelda.font = fuenteTextoAnotacionesCell
        etiqDiaGuardado.font = fuenteDiaCell
        etiqHoraGuardada.font = fuenteDiaHoraCell
        
        etiqDiaGuardado.textColor = colorTextDiaCell
        etiqHoraGuardada.textColor = colorTextDiaHoraCell
        
        etiqDiaGuardado.backgroundColor = .clear
        etiqHoraGuardada.backgroundColor = .clear
        etiqContenidoCelda.backgroundColor = .clear
        selectionStyle = .none
        
      
        
          
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        if #available(iOS 10, *) {
            UIView.animate(withDuration: 0.3) { self.contentView.layoutIfNeeded() }
        }
    }
}
protocol CellSecundariaImageTap {
    func tableCell(clickFotoCell tableCell: UITableViewCell)
    
}

class TableViewCellSecundariaFotos: UITableViewCell {
    
    //    MARK:-IBOULTES
    @IBOutlet var etiqDiaGuardado: UILabel!
    @IBOutlet var etiqHoraGuardada: UILabel!
    @IBOutlet var etiqContenidoCelda: UILabel!
    @IBOutlet var iconoFoto: UIImageView!
    
    @IBOutlet var boton3CellFotos: UIButton!
    @IBOutlet var boton2CellFotos: UIButton!
    @IBOutlet var boton1CellFotos: UIButton!
    
   
    //    MARK:- VARIABLES
    var delegado : CellSecundariaImageTap?
    var tapGestureFoto = UITapGestureRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       
                
        iconoFoto.backgroundColor = .gray
        iconoFoto.borders(for: [.all], width: 0.8, color: .systemGray2)
        iconoFoto.sombraLargaVista()
        
         etiqContenidoCelda.font = fuenteTextoAnotacionesCell
               etiqDiaGuardado.font = fuenteDiaCell
               etiqHoraGuardada.font = fuenteDiaHoraCell
               
               etiqDiaGuardado.textColor = colorTextDiaCell
               etiqHoraGuardada.textColor = colorTextDiaHoraCell
       
    }
    override func layoutSubviews() {
        UIView.performWithoutAnimation {
            super.layoutSubviews()
        }
    }
    private func initialize() {
        tapGestureFoto.addTarget(self, action: #selector(TableViewCellSecundariaFotos.imageTapped(gestureRecgonizer:)))
        
        self.addGestureRecognizer(tapGestureFoto)
    }
    @objc func imageTapped(gestureRecgonizer: UITapGestureRecognizer) {
        delegado?.tableCell(clickFotoCell: self)
       
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func boton2(_ sender: Any) {
        accionVisualPulsarBoton(unBoton: boton2CellFotos)
    }
    @IBAction func boton1(_ sender: Any) {
          
        accionVisualPulsarBoton(unBoton: boton1CellFotos)
        
    }
    @IBAction func boton3(_ sender: Any) {
        accionVisualPulsarBoton(unBoton: boton3CellFotos)
    }
    func accionVisualPulsarBoton(unBoton:UIButton){
        
        unBoton.superRebotar()
        let generator = UIImpactFeedbackGenerator(style: .medium)
              generator.impactOccurred()
    }
}
