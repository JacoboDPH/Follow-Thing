//
//  TableViewCellVisorFoto.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 03/11/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

protocol ProtocoloCellVisorFotos {
    func estaEnZoom(valor:Bool)
}

class TableViewCellVisorFoto: UITableViewCell, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var fotoScrollTabla: UIImageView!
    
    //    MARK: - VARIABLES GLOBALES
    var estaEnZoom:Bool = false
    var originalPuntoCentro:CGPoint?
    var lastContentOffset: CGFloat = 0
    var delegado:ProtocoloCellVisorFotos? = nil
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
        self.scrollView.delegate = self
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGest.numberOfTapsRequired = 2
        self.fotoScrollTabla.addGestureRecognizer(doubleTapGest)
    }
//    MÉTODOS PROTOCOLOS
   
    //    MARK: - ZOOM PICH
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.fotoScrollTabla
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if scrollView.zoomScale > 1 {
            if let image = fotoScrollTabla.image {
                
                let ratioW = fotoScrollTabla.frame.width / image.size.width
                let ratioH = fotoScrollTabla.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let left = 0.5 * (newWidth * scrollView.zoomScale > fotoScrollTabla.frame.width ? (newWidth - fotoScrollTabla.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > fotoScrollTabla.frame.height ? (newHeight - fotoScrollTabla.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
               
                self.estaEnZoom = true
                self.delegado?.estaEnZoom(valor: !estaEnZoom)
            }
        }
        else
        {
            scrollView.contentInset = UIEdgeInsets.zero
           
            self.estaEnZoom = false
            self.delegado?.estaEnZoom(valor: !estaEnZoom)
        }
        
        fotoScrollTabla.translatesAutoresizingMaskIntoConstraints = true
    }
//    MARK:- ZOOM TAP
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
                
        let escala = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
        
        if escala != scrollView.zoomScale {
            
            let point = recognizer.location(in: fotoScrollTabla)
            let scrollSize = scrollView.frame.size
            let size = CGSize(width: scrollSize.width / scrollView.maximumZoomScale,
                              height: scrollSize.height / scrollView.maximumZoomScale)
            let origin = CGPoint(x: point.x - size.width / 2,
                                 y: point.y - size.height / 2)
            
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
          
            self.estaEnZoom = true
            self.delegado?.estaEnZoom(valor: !estaEnZoom)
            
            
        } else if scrollView.zoomScale == 2 {
            
           
            self.estaEnZoom = false
            self.delegado?.estaEnZoom(valor: !estaEnZoom)
            
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: fotoScrollTabla)), animated: true)
        }
    }
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        
        
        var zoomRect = CGRect.zero
        zoomRect.size.height = fotoScrollTabla.frame.size.height / scale
        zoomRect.size.width  = fotoScrollTabla.frame.size.width  / scale
        
        let newCenter = scrollView.convert(center, from: fotoScrollTabla)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
