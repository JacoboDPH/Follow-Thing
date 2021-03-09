//
//  Fuentes.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 24/09/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import Foundation
import UIKit

//MARK: - FUENTES DE LA APP

let fuentePopover = UIFont(name: "HelveticaNeue-CondensedBold", size: 28)
let fuenteTituloContendores = UIFont(name: "HelveticaNeue-CondensedBlack", size: 24)
let fuentePopoverGrande = UIFont(name: "HelveticaNeue-CondensedBlack", size: 76)
let fuentePopoverGrandeSubtitulo = UIFont(name: "HelveticaNeue-CondensedBlack", size: 56)
let fuenteTablaAnotaciones = UIFont(name: "HelveticaNeue-Light", size: 22)
let fuenteBotonGuardar = UIFont(name: "HelveticaNeue-CondensedBlack", size: 26)
let fuenteCellSecundario = UIFont(name: "HelveticaNeue-Light", size: 20)
let fuenteCellVisorFotoDia = UIFont(name: "HelveticaNeue-ExtraLight", size: 38)
let fuenteVisorTitulo = UIFont(name: "HelveticaNeue-CondensedBlack", size: 42)
let fuenteVistorSubtitulo =  UIFont(name: "HelveticaNeue-CondensedBlack", size: 32)
let fuenteTextView = UIFont(name: "HelveticaNeue-Light", size: 26)
let fuenteContendorInformativoGrande = UIFont(name: "HelveticaNeue-Light", size: 42)
let fuenteCeldaInteriorCollection = UIFont(name: "HelveticaNeue-Light", size: 20)
let fuenteTextField = UIFont(name: "HelveticaNeue-Light", size: 18)
//MARK:- FUENTES CELL SECUNDARIO
let fuenteTextoAnotacionesCell = UIFont(name: "HelveticaNeue-Heavy", size: 22)
let fuenteTextoAnotacionesCellNegrita = UIFont(name: "HelveticaNeue-Black", size: 24)
let fuenteDiaCell =  UIFont(name: "HelveticaNeue-Light", size: 16)
let fuenteDiaHoraCell =   UIFont(name: "HelveticaNeue-Light", size: 10)

let fuenteTextoAnotacionesCellTitulo = UIFont(name: "HelveticaNeue-ThinBlack", size: 40)
extension NSMutableAttributedString  {
    
    func strikeThrough(thickness: Int, subString: String)  {
        if let range = self.string.range(of: subString) {
            self.strikeThrough(thickness: thickness, onRange: NSRange(range, in: self.string))
        }
    }
    func strikeThrough(thickness: Int, onRange: NSRange)  {
        
        self.addAttributes([NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.thick.rawValue],
                           range: onRange)
    }
    func applyStroke(color: UIColor, thickness: Int, subString: String) {
        if let range = self.string.range(of: subString) {
            self.applyStroke(color: color, thickness: thickness, onRange: NSRange(range, in: self.string))
        }
    }
    func applyStroke(color: UIColor, thickness: Int, onRange: NSRange) {
        self.addAttributes([NSAttributedString.Key.strokeColor : color],
                           range: onRange)
        self.addAttributes([NSAttributedString.Key.strokeWidth : thickness],
                           range: onRange)
    }
}
//case .ultraLight: return "UltraLight"
//          case .thin: return "Thin"
//          case .light: return "Light"
//          case .regular: return nil
//          case .medium: return "Medium"
//          case .semibold: return "Semibold"
//          case .bold: return "Bold"
//          case .heavy: return "Heavy"
//          case .black: return "Black"
