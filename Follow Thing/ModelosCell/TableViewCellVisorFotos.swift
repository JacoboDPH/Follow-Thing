//
//  TableViewCellVisorFotos.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 30/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

class TableViewCellVisorFotos: UITableViewCell {

//    MARK:- IBOULETS
    
    @IBOutlet var fotoVisor: UIImageView!
    @IBOutlet var etiquetaDia: UILabel!
    @IBOutlet var contenedor: UIView!
    
    @objc func pinch(sender:UIPinchGestureRecognizer) {

        if sender.state == .changed {
            let currentScale = self.fotoVisor.frame.size.width / self.fotoVisor.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
            }
            if newScale > 9 {
                newScale = 9
            }
            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            self.fotoVisor.transform = transform
            sender.scale = 1
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                self.fotoVisor.transform = CGAffineTransform.identity
            })
        }
        
    }

//    func pan(sender: UIPanGestureRecognizer) {
//        if self.isZooming && sender.state == .began {
//            self.originalImageCenter = sender.view?.center
//        } else if self.isZooming && sender.state == .changed {
//            let translation = sender.translation(in: self)
//            if let view = sender.view {
//                view.center = CGPoint(x:view.center.x + translation.x,
//                                      y:view.center.y + translation.y)
//            }
//            sender.setTranslation(CGPoint.zero, in: self.postImage.superview)
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        etiquetaDia.font = fuenteCellVisorFotoDia
        etiquetaDia.textColor = .black
        etiquetaDia.alpha = 0.8
        
        fotoVisor.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        
        etiquetaDia.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width-40, height: 60)
        
        
        contenedor.addBlurEffectFondo()
        contenedor.backgroundColor =  .clear
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
            fotoVisor.addGestureRecognizer(pinch)
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
//        pan.delegate = self
//        self.fotoVisor.addGestureRecognizer(pan)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
