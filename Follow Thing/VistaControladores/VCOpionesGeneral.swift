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

class VCOpionesGeneral: UIViewController, UIPopoverPresentationControllerDelegate, VCLoginDelegado {
    func actualizaAutenticacion() {
        comprobarLogin()
        btnEntrarRegistarse.superRebotar()
    }
    
    //MARK:-IBOULETS
 
    @IBOutlet weak var swichtSincronizar: UISwitch!
    @IBOutlet weak var btnEntrarRegistarse: UIButton!
    @IBOutlet weak var etiqFirebase: UILabel!
    
    @IBOutlet weak var switchTexto: UISwitch!
    @IBOutlet weak var switchDias: UISwitch!
   
    @IBOutlet weak var switchCategoria: UISwitch!
    @IBOutlet weak var switchIndice: UISwitch!
    

    
    //    MARK:-VARIABLES
    var existeUsuario:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        comprobarLogin()
        compruebaSeguimiento()
        compruebaPantallaPrincipal()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
//  MARK:-  FIREBASE
    
    @IBAction func btnEntrarRegistrarse(_ sender: Any) {
        if !existeUsuario {
       
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vcLogin = storyboard.instantiateViewController(identifier: "VCLogin") as! VCLogin
            
            vcLogin.modalPresentationStyle = .popover
            vcLogin.delegado = self
            
            self.present(vcLogin, animated: true)
            
        }
        else {
            try! Auth.auth().signOut()
            btnEntrarRegistarse.setTitle("Entrar/Registrarse", for: .normal)
            existeUsuario = false
            swichtSincronizar.isOn = false
            UserDefaults.standard.set(false, forKey: "sincronizacion")
        }
    }
    func comprobarLogin() {
    
        let correo = Auth.auth().currentUser?.email
        if correo != nil {
            print("El correo electronico del usuario es \(correo!)")
            existeUsuario = true
            self.btnEntrarRegistarse.setTitle("Salir de \(correo!)", for: .normal)
            
            let sincro = UserDefaults.standard.bool(forKey: "sincronizacion")
            swichtSincronizar.isOn = sincro
            
            buscaUltimaActualizacion()
        }
        else {
          
            swichtSincronizar.isOn = false
            UserDefaults.standard.set(false, forKey: "sincronizacion")
            
        }
       
    }
    @IBAction func switchGuardarCopiaFireBase(_ sender: Any) {
        
        if ((sender as AnyObject).isOn == true) {
            //Yes
            let correo = Auth.auth().currentUser?.email
            if correo != nil {
                UserDefaults.standard.set(true, forKey: "sincronizacion")
            }
            else {
                swichtSincronizar.isOn = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
                    
                    btnEntrarRegistarse.superRebotar()
                    
                    
                }
            }
            
            
        } else {
            //No
            UserDefaults.standard.set(false, forKey: "sincronizacion")
        }
    }
    func buscaUltimaActualizacion(){
        
        let conmutador = ConmutadorFireBaseCoreData.init()
        
        let ftBackup = conmutador.cargaEntidadPrincipalPorFechaSincronizacion()
        
        if ftBackup!.count > 0 {
            for busca in 1...ftBackup!.count {
                
                print(ftBackup![busca-1].fechaUltimaSincronizacion,ftBackup![busca-1].titulo)
                
            }
        }
    }
//    MARK:- SEGUIMIENTO
    func compruebaSeguimiento(){
        
        let dia = UserDefaults.standard.bool(forKey: "tapDia")
        switchDias.isOn = dia
        
       let textoPreditivo = UserDefaults.standard.bool(forKey: "textoPreditivo")
        switchTexto.isOn = textoPreditivo
        
//        let fotoPatron = UserDefaults.standard.bool(forKey: "fotoPatron")
        
    }
    func compruebaPantallaPrincipal(){
        
        let mostrarCategoria = UserDefaults.standard.bool(forKey: "mostrar_Categoria_inicio")
        
        switchCategoria.isOn = mostrarCategoria
        
        let mostrarIndice = UserDefaults.standard.bool(forKey: "mostrar_Indice_Inicio")
        switchIndice.isOn = mostrarIndice
    }
    
    @IBAction func accionSwichtTexto(_ sender: Any) {
        if ((sender as AnyObject).isOn == true) {
            //Yes
            UserDefaults.standard.set(true, forKey: "textoPreditivo")
        }
        else {
            UserDefaults.standard.set(false, forKey: "textoPreditivo")
        }
    }
    
    @IBAction func accionSwitchDias(_ sender: Any) {
        if ((sender as AnyObject).isOn == true) {
            //Yes
            UserDefaults.standard.set(true, forKey: "tapDia")
        }
        else {
            UserDefaults.standard.set(false, forKey: "tapDia")
        }
    }
    
    @IBAction func accionSwitchFoto(_ sender: Any) {
        if ((sender as AnyObject).isOn == true) {
            //Yes
            UserDefaults.standard.set(true, forKey: "fotoPatron")
        }
        else {
            
            UserDefaults.standard.set(false, forKey: "fotoPatron")
            
        }
    }
//    MARK:- PANTALLA PRINCIPAL
    @IBAction func switchCategoria(_ sender: Any) {
        if ((sender as AnyObject).isOn == true) {
            //Yes
            UserDefaults.standard.set(true, forKey: "mostrar_Categoria_inicio")
            if switchIndice.isOn == true {
                switchIndice.isOn = false
                UserDefaults.standard.set(false, forKey: "mostrar_Indice_Inicio")
            }
        }
        else {
            
            UserDefaults.standard.set(false, forKey: "mostrar_Categoria_inicio")
            
        }
    }
    @IBAction func switchIndice(_ sender: Any) {
        if ((sender as AnyObject).isOn == true) {
            //Yes
            UserDefaults.standard.set(true, forKey: "mostrar_Indice_Inicio")
            if switchCategoria.isOn == true {
                switchCategoria.isOn = false
                UserDefaults.standard.set(false, forKey: "mostrar_Categoria_inicio")
                
            }
        }
        else {
            
            UserDefaults.standard.set(false, forKey: "mostrar_Indice_Inicio")
            
        }
    }
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
         
      }
}
