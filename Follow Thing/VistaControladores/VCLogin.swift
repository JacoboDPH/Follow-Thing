//
//  VCLogin.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 5/3/21.
//  Copyright © 2021 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol VCLoginDelegado {
    func actualizaAutenticacion()
}

class VCLogin: UIViewController, UITextFieldDelegate {

//    MARK:- IBOULET
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var contenedor: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var conntraseña: UITextField!
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var btnEntrarReg: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var constrainAlineadoY: NSLayoutConstraint!
    
//    MARK:- VARIABLES
        
    var delegado:VCLoginDelegado?
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.isHidden = true
        
        propiedades(contened: view, alphaTop: 0.5, puntos: [.all])
        contenedor.sombraLargaVista()
        contenedor.borders(for: [.all], width: 0.5, color: .darkGray)
        
        emailTextfield.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
             
            emailTextfield.becomeFirstResponder()
           
                   
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoAparece), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        

        
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
                 
                self.delegado?.actualizaAutenticacion()
                self.performSegueToReturnBack()
                
              
            } else {
                if (error?.localizedDescription) != nil {
                    print("ERROR INICIO SESION FIREBASE:",error?.localizedDescription)
                    self.erroresDeAutenticacion(error: error?.localizedDescription)
                
                } else {
                    print("error en codigo")
                    
                }
            }
        }
    }
    func registrar(correo:String,contraseña:String){
        Auth.auth().createUser(withEmail: correo, password: contraseña) { (user, error) in
            if user != nil {
               
                self.delegado?.actualizaAutenticacion()
                self.performSegueToReturnBack()
            } else {
                if (error?.localizedDescription) != nil {
                    print("ERROR REGISTRO FIREBASE",error?.localizedDescription)
                    self.erroresDeAutenticacion(error: error?.localizedDescription)
                } else {
                    print("error en codigo")
                }
            }
        }
    }
    @IBAction func volverOpciones(_ sender: Any) {
        self.performSegueToReturnBack()
    }
    func erroresDeAutenticacion(error:String?) {
        if error == "The password is invalid or the user does not have a password." {
            mostrarAlerta(mensaje: "La contraseña de usuario es incorrecta")
        }
        if error == "There is no user record corresponding to this identifier. The user may have been deleted." {
            mostrarAlerta(mensaje: "Este usuario no existe, deberás registrarte primero")
        }
        if error == "The email address is already in use by another account." {
            mostrarAlerta(mensaje: "El correo de usuario ya está registrado, pasa a iniciar sesión")
        }
        if error == "The password must be 6 characters long or more." {
            mostrarAlerta(mensaje: "La contraseña debe tener al menos 6 caracteres")
        }
        self.activity.stopAnimating()
        self.activity.isHidden = true
        self.btnEntrarReg.isHidden = false
      
    }
    func mostrarAlerta(mensaje:String){
        let alert = UIAlertController(title: "Ha habido un error", message: mensaje, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
  
    @objc func tecladoAparece(notification: Notification) {
              
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardHeight = keyboardSize?.height
        if keyboardHeight != nil {
        self.constrainAlineadoY.constant = -keyboardHeight!/2
        }
        
        UIView.animate(withDuration: 0.5){
            
            self.view.layoutIfNeeded()
            
        }
        
    }
//    MARK:- METODOS UTILES
//        **** Método repetido en clase VCSecundaria, [refactorizar]
    func propiedades(contened:UIView,alphaTop:Float,puntos:UIRectEdge){
     
        contened.addBlurEffectFondoOscuro()
        contened.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        contened.borders(for: [puntos], width: 0.5, color: UIColor.darkGray.withAlphaComponent(CGFloat(alphaTop)))
        
    }
}
