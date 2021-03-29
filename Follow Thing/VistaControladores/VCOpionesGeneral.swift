//
//  VCOpionesGeneral.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 5/3/21.
//  Copyright © 2021 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

enum ProviderTipo: String {
    case basic
}

class VCOpionesGeneral: UIViewController, UIPopoverPresentationControllerDelegate {

    //MARK:-IBOULETS
 
    @IBOutlet weak var btnEntrarRegistarse: UIButton!
    

    //    MARK:-VARIABLES
    var existeUsuario:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

       comprobarLogin()
    }
    

//  MARK:-  FIREBASE
    
    @IBAction func btnEntrarRegistrarse(_ sender: Any) {
        if !existeUsuario {
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let VCLogin = storyboard.instantiateViewController(identifier: "VCLogin") as! VCLogin
//
//            VCLogin.modalPresentationStyle = .popover
//
//            let popVCLogin = VCLogin.popoverPresentationController
//            popVCLogin?.delegate = self
//
//
//            VCLogin.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width/1.5, height: (UIScreen.main.bounds.size.width/1.5) / CGFloat(numeroAureo))
//
//
//            self.present(VCLogin, animated: true)
            
//            VCLogin.popoverPresentationController!.delegate = self
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vcLogin = storyboard.instantiateViewController(identifier: "VCLogin") as! VCLogin
            
            vcLogin.modalPresentationStyle = .popover
            
            self.present(vcLogin, animated: true)
            
        }
        else {
            try! Auth.auth().signOut()
            btnEntrarRegistarse.setTitle("Entrar/Registrarse", for: .normal)
            existeUsuario = false
        }
    }
    func comprobarLogin() {
    
        let correo = Auth.auth().currentUser?.email
        if correo != nil {
            print("El correo electronico del usuario es \(correo!)")
            existeUsuario = true
            self.btnEntrarRegistarse.setTitle("Salir de \(correo)", for: .normal)
        }
       
    }
    
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
         
        
      }
 
    @IBAction func switchGuardarCopiaFireBase(_ sender: Any) {
        
        if ((sender as AnyObject).isOn == true) {
                //Yes
            
            let conmutador = ConmutadorFireBaseCoreData.init()
            conmutador.guardarCompletoDeLocalAFireBase()
            
                 } else {
                   //No
                 }
    }
}
