//
//  VCOrdenarPor.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 16/07/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

protocol VCOrdenarPorDelegado {
    func actualizaTablaDatos()
    func muestraSeleccionadorCategoria()
}


class VCOrdenarPor: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
   
//    MARK:- IBOUTLET
    @IBOutlet var pickerOrdenar: UIPickerView!
    
    @IBOutlet var etiquetaTitulo: UILabel!
    //    MARK:- VARIABLES
    
    var delegado:VCOrdenarPorDelegado?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerOrdenar.dataSource = self
        self.pickerOrdenar.delegate = self
        
        let ordenGuardado =  UserDefaults.standard.integer(forKey: "ordenGuardado")
        pickerOrdenar.reloadAllComponents()
        pickerOrdenar.selectRow(ordenGuardado, inComponent: 0, animated: true)
        
        
        let altura = ( (UIScreen.main.bounds.size.width/1.5) / CGFloat(numeroAureo) ) / CGFloat(numeroAureo*2)
        
        etiquetaTitulo.heightAnchor.constraint(equalToConstant:altura).isActive = true
        etiquetaTitulo.heightConstraint?.constant = altura
        self.view.layoutIfNeeded()
        
        
        view.layoutIfNeeded()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuraVistas()
    }
//    MARK:- CONFIGURACION
    func configuraVistas(){
        
        self.etiquetaTitulo.backgroundColor = grisPopOrdenar
        self.etiquetaTitulo.font = fuentePopover
        self.etiquetaTitulo.frame = CGRect(x: 0, y: 13, width: Int(UIScreen.main.bounds.size.width)/2, height: alturaEtiquetaPopover)
        
        self.pickerOrdenar.frame = CGRect(x: 0, y:alturaEtiquetaPopover+13, width: Int(UIScreen.main.bounds.size.width)/2, height: 200-alturaEtiquetaPopover)
        
        self.pickerOrdenar.backgroundColor = .white
        
        view.backgroundColor = grisPopOrdenar
        
    }
    
// MARK:- PICKERVIEW
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        return NSAttributedString(string: datosPicker[row], attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datosPicker.count
       }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datosPicker[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row <= 2 {
        UserDefaults.standard.set(row,forKey: "ordenGuardado")       
    
        self.delegado?.actualizaTablaDatos()
        self.dismiss(animated: true, completion: nil)
        }
        if row == 3 {
            self.delegado?.muestraSeleccionadorCategoria()
            self.dismiss(animated: true, completion: nil)
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
       
        var pickerLabel: UILabel? = (view as? UILabel)
       
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = fuenteTablaAnotaciones
            pickerLabel?.textAlignment = .center
            pickerLabel?.textColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.gray : UIColor.gray
        }
        pickerLabel?.text = datosPicker[row]
        pickerLabel?.textColor = .black
       
        return pickerLabel!
    }
   
    

}
