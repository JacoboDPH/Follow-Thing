//
//  VCLogin.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 5/3/21.
//  Copyright © 2021 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import FirebaseAuth

class VCLogin: UIViewController {

//    MARK:- IBOULET
    
    @IBOutlet weak var contenedor: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var conntraseña: UITextField!
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var btnEntrarReg: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.isHidden = true

    }
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .clear
        self.view.frame = CGRect(x: 0, y: 15, width: 300, height: 200);
    }
    @IBAction func entrar(_ sender: Any) {
        if control.selectedSegmentIndex == 0 {
            iniciarSesion(correo: email.text!, contraseña: conntraseña.text!)
        } else {
            registrar(correo: email.text!, contraseña: conntraseña.text!)
        }
    }
    func iniciarSesion(correo:String,contraseña:String){
    
        self.activity.isHidden = false
        self.btnEntrarReg.isHidden = true
        self.activity.startAnimating()
        
        Auth.auth().signIn(withEmail: correo, password: contraseña) { (user, error) in
            if user != nil {
                 
                self.performSegueToReturnBack()
              
            } else {
                if (error?.localizedDescription) != nil {
                    print("ERROR INICIO SESION FIREBASE")
                } else {
                    print("error en codigo")
                    
                }
            }
        }
    }
    func registrar(correo:String,contraseña:String){
        Auth.auth().createUser(withEmail: correo, password: contraseña) { (user, error) in
            if user != nil {
                self.performSegueToReturnBack()
            } else {
                if (error?.localizedDescription) != nil {
                    print("ERROR REGISTRO FIREBASE")
                } else {
                    print("error en codigo")
                }
            }
        }
    }
    @IBAction func volverOpciones(_ sender: Any) {
        self.performSegueToReturnBack()
    }
}
