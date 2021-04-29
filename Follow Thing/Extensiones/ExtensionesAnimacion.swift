//
//  ExtensionesAnimacion.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 22/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import Foundation
import UIKit

struct Icono {
    var nombreImagen:String
}

let numeroAureo = 1.61803399

// MARK:- TAMAÑO DE PANTALLA

let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height

// MARK:- MEDIDAS

let alturaEtiquetaPopover = 44
let alturaCeldaPopover = 50



//let Iconos:[Icono] = Icono(nombreImagen: "1")

let verdeBtnAlarma:UIColor =  UIColor(red: 3/255, green: 192/255, blue: 60/255, alpha: 1)
let rojoBtnAlarma:UIColor = UIColor(red: 204/255, green: 0/255, blue: 0/255, alpha: 1)

let azulBotonEditar:UIColor =  UIColor(red: 113/255, green: 133/255, blue: 150/255, alpha: 1)

let rojoBotonEditar:UIColor = UIColor(red: 237/255, green: 28/255, blue: 35/255, alpha: 1)

let grisPopOrdenar:UIColor = UIColor(red: 59/255, green: 68/255, blue: 75/255, alpha: 0.95)

let botonActivo:UIColor = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1)

let colorTextfieldFondo:UIColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.5)

let colorTextDiaCell:UIColor = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1)

let colorTextDiaHoraCell:UIColor = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1)

let colorFondoContenedores:UIColor =  UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)

let colorFondoTituloContenedores:UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)

let colorTituloCabecera:UIColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
let blancoTransparente:UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)

var coloresCategoria:[UIColor] = [
    
    UIColor(red: 199/255, green: 206/255, blue: 234/255, alpha: 1),
    UIColor(red: 255/255, green: 65/255, blue: 65/255, alpha: 1),
    UIColor(red: 141/255, green: 136/255, blue: 95/255, alpha: 1),
    UIColor(red: 251/255, green: 175/255, blue: 218/255, alpha: 1),
    UIColor(red: 68/255, green: 211/255, blue: 98/255, alpha: 1),
    UIColor(red: 167/255, green: 58/255, blue: 122/255, alpha: 1),
    UIColor(red: 68/255, green: 113/255, blue: 142/255, alpha: 1),
    UIColor(red: 255/255, green: 201/255, blue: 14/255, alpha: 1),
    UIColor.clear]

var coloresAnotacion:[UIColor] = [

    UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1),
    UIColor(red: 229/255, green: 22/255, blue: 22/255, alpha: 1),
    UIColor(red: 229/255, green: 67/255, blue: 22/255, alpha: 1),
    UIColor(red: 240/255, green: 86/255, blue: 9/255, alpha: 1),
    UIColor(red: 240/255, green: 144/255, blue: 9/255, alpha: 1),
    
    UIColor(red: 240/255, green: 203/255, blue: 9/255, alpha: 1),
    UIColor(red: 150/255, green: 219/255, blue: 5/255, alpha: 1),
    UIColor(red: 5/255, green: 219/255, blue: 140/255, alpha: 1),
    UIColor(red: 7/255, green: 202/255, blue: 192/255, alpha: 1),
    UIColor(red: 7/255, green: 49/255, blue: 202/255, alpha: 1),
    
    UIColor(red: 126/255, green: 7/255, blue: 202/255, alpha: 1),
    UIColor(red: 202/255, green: 7/255, blue: 183/255, alpha: 1)
    ,
    UIColor(red: 202/255, green: 7/255, blue: 122/255, alpha: 1),
    UIColor(red: 223/255, green: 47/255, blue: 95/255, alpha: 1),
    UIColor(red: 205/255, green: 0/255, blue: 8/255, alpha: 1)]

//let attrString(string:String) = NSAttributedString(
//    string: <#String#>, attributes: [
//        NSAttributedString.Key.strokeColor: UIColor.black,
////          NSAttributedStringKey.foregroundColor: UIColor.white,
//        NSAttributedString.Key.strokeWidth: 1.0,
//        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)
//      ]
//  )

public extension UIView {
    
//    MARK: FUNCIONES DE BLUR
    func blur() {
        //   Blur out the current view
        let blurView = UIVisualEffectView(frame: self.bounds)
        self.addSubview(blurView)
        
    }
    func blurOscuro() {
        //   Blur out the current view
        let blurView = UIVisualEffectView(frame: self.bounds)
        self.addSubview(blurView)
        UIView.animate(withDuration:0.25) {
            blurView.effect = UIBlurEffect(style: .dark)
        }
    }
    func unblur() {
        for childView in subviews {
            guard let effectView = childView as? UIVisualEffectView else { continue }
            UIView.animate(withDuration: 0.15, animations: {
                effectView.effect = nil
            }) {
                didFinish in
                effectView.removeFromSuperview()
            }
        }
    }
    func ampliaReduce(tamaño:CGFloat){
       
        if tamaño < 1 {
        
        UIView.animate(withDuration:0.25) {
            self.transform = CGAffineTransform(scaleX: tamaño, y: tamaño)
            self.frame.origin.x = 90
        }
        }
        else {
            UIView.animate(withDuration:0.25) {
                self.transform = CGAffineTransform(scaleX: tamaño, y: tamaño)
                self.frame.origin.x = 0
            }
        }

    }
    func removeBlurEffect() {
        
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
    
    func addBlurEffect(){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] 
        self.addSubview(blurEffectView)
    }
    func addBlurEffectUltraLight(){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    func grandienteVertical(color01:UIColor, color02:UIColor){
        
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [color01.cgColor,color02.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height+10)

        layer.insertSublayer(gradient, at: 0)
    }
    
    func addBlurEffectFondo()
    {
        
        let blufFX = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurFXView = UIVisualEffectView(effect: blufFX)
        blurFXView.frame = bounds
       
        blurFXView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        insertSubview(blurFXView, at: 0)
         
    }
    func addBlurEffectFondoUltraLight()
    {
        
        let blufFX = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurFXView = UIVisualEffectView(effect: blufFX)
        blurFXView.frame = bounds
       
        blurFXView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        insertSubview(blurFXView, at: 0)
         
    }
    func addBlurEffectFondoOscuro()
    {
        
        let blufFX = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurFXView = UIVisualEffectView(effect: blufFX)
        blurFXView.frame = bounds
       
        blurFXView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        insertSubview(blurFXView, at: 0)
         
    }
    
    
    func superRebotar(){
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
           
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = .identity
             
            })
            
        }
        
    }
//    MARK:- FUNCIONES ANIMACION ALPHA
    func iluminar(){
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
           
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
             
             
            })
            
        }
    }
    func iluminar05(){
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.5
           
        }) { (completion) in
            UIView.animate(withDuration: 0.2, animations: {
             
             
            })
            
        }
    }
    func desiluminar(){
           UIView.animate(withDuration: 0.2, animations: {
               self.alpha = 0.0
              
           }) { (completion) in
               UIView.animate(withDuration: 0.2, animations: {
                
                
               })
               
           }
       }
    func cambiarColor(color:UIColor) {
        
        UIView.animate(withDuration: 0.2, animations: {
                   self.backgroundColor = color
                  
               }) { (completion) in
                   UIView.animate(withDuration: 0.2, animations: {
                    
                  
                   })
                   
               }
    }
    func saltoHorizontalDerecha(){
        UIView.animate(withDuration: 0.20, animations: {
            self.transform = CGAffineTransform(translationX: 10, y: 0)
        }) { (completion) in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = .identity
            })
        }
        
    }
    func saltoHorizontalIzquierda(){
        UIView.animate(withDuration: 0.20, animations: {
            self.transform = CGAffineTransform(translationX: -40, y: 0)
        }) { (completion) in
            UIView.animate(withDuration: 0.40, animations: {
                self.transform = .identity
            })
        }
        
    }
    func brillo(){
        UIView.animate(withDuration: 0.20, animations: {
            self.alpha = 0.5
        }) { (completion) in
            UIView.animate(withDuration: 0.40, animations: {
                self.alpha = 1.0
            })
        }
    }
//  MARK:- FUNCIONES DE FORMA
    func redondoCompleto(){
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    func redondearVista(){
        layer.cornerRadius = bounds.height/4
        clipsToBounds = true
        
    }
//    MARK:- ANIMACION VIBRACION
    func animadoVibracionMedio(){
       
        let generator = UIImpactFeedbackGenerator(style: .medium)
                     generator.impactOccurred()
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (completion) in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = .identity
            })
        }
    }
//    MARK:- FUNCIONES DE SOMBREADO
    func sombreaVista(){
        
        layer.shadowOffset = CGSize(width:0, height: 2.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
    
        layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
    }
    func sombraLargaVista(){
        
        layer.shadowOffset = CGSize(width:0, height: 5.0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 10.0
    
        layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
    }
}
extension UIButton {
    
    //  MARK:- FUNCIONES DE FORMA
    func redondear(){
        layer.cornerRadius = bounds.height/6
        clipsToBounds = true
        
    }
    func circuloCompletoLayer(){
        layer.cornerRadius = bounds.height/2
              clipsToBounds = true
    }
    //  MARK:- ANIMACIONES
    
    func rebotar(){
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (completion) in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = .identity
            })
        }
    }
    func pulsarAnimadoVibracion(){
       
        let generator = UIImpactFeedbackGenerator(style: .medium)
                     generator.impactOccurred()
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { (completion) in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = .identity
            })
        }
    }
    //    MARK:- FUNCIONES DE SOMBREADO
        func sombreaBoton(){
            
            layer.shadowOffset = CGSize(width:0.5, height: 0.5)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 10.0
//            clipsToBounds = true
//            layer.borderWidth = 0.0
            layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
        }
}
extension UINavigationController {

    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
    
}
extension UIView {
    func borders(for edges:[UIRectEdge], width:CGFloat = 1, color: UIColor = .black) {

        if edges.contains(.all) {
            layer.borderWidth = width
            layer.borderColor = color.cgColor
        } else {
            let allSpecificBorders:[UIRectEdge] = [.top, .bottom, .left, .right]

            for edge in allSpecificBorders {
                if let v = viewWithTag(Int(edge.rawValue)) {
                    v.removeFromSuperview()
                }

                if edges.contains(edge) {
                    let v = UIView()
                    v.tag = Int(edge.rawValue)
                    v.backgroundColor = color
                    v.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(v)

                    var horizontalVisualFormat = "H:"
                    var verticalVisualFormat = "V:"

                    switch edge {
                    case UIRectEdge.bottom:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "[v(\(width))]-(0)-|"
                    case UIRectEdge.top:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v(\(width))]"
                    case UIRectEdge.left:
                        horizontalVisualFormat += "|-(0)-[v(\(width))]"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    case UIRectEdge.right:
                        horizontalVisualFormat += "[v(\(width))]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    default:
                        break
                    }

                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": v]))
                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": v]))
                }
            }
        }
    }
}
extension UILabel {
 
    
   
   

    func sombreaEtiqueta(){
        
        layer.shadowOffset = CGSize(width:0.5, height: 0.5)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10.0
//        clipsToBounds = true
//        layer.borderWidth = 5.0
        layer.shadowColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)
    }
}
extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
    }

}
extension UIView {

    func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {

        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
        shadowLayer.path = cgPath //2
        shadowLayer.fillColor = fillColor.cgColor //3
        shadowLayer.shadowColor = shadowColor.cgColor //4
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet //5
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        self.layer.addSublayer(shadowLayer)
    }
}
