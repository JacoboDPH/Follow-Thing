//
//  VCRegistroFT.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 17/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol protocoloDelegadoRegistroFT {
    func actualizaTablaDatos()
    func actualizaTablaDatosPorId(id:UUID)
}

class VCRegistroFT: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    
//    MARK:- IBOULETS
    
    @IBOutlet var collectionViewColores: UICollectionView!
   
    @IBOutlet var scrollViewInicial: UIScrollView!
    @IBOutlet var vistaColorIcono: UIView!
    @IBOutlet var vistaTitulo: UIView!
    @IBOutlet var vistaColores: UIView!
   
    @IBOutlet var textFieldTitulo: UITextField!
    @IBOutlet var etiquetaTItulo: UILabel!
    @IBOutlet var etiquetaColores: UILabel!
    @IBOutlet var etiquetaIcono: UILabel!
    @IBOutlet var botonGuardar: UIButton!
    
//    MARK:- VARIABLES
    
    public var delegateVCPrincipal:protocoloDelegadoRegistroFT? = nil
   
    var seleccionColor:Int = 8
    var editando:Bool = false
    public var followThingRecibidoEditar:FollowThing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        if editando == true {
            
           editando(editando: editando)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if editando == false {
          
            botonGuardar.isHidden = true
           
        }
        self.hideKeyboardWhenTappedAround()        
   
       configuraBotonGuardar()
    }
    override func viewDidAppear(_ animated: Bool) {

        configuracionVistasScrollView()
        configuracionScrollView()
        configuracionPageControl()
        configuraVistaTitulo()
        configuraVistaColores()
        configuraVistaIconos()
        
        textFieldTitulo.returnKeyType = .done
        
    }
    //    MARK:- SCROLLVIEW
    
    func configuracionScrollView(){
        
        scrollViewInicial.delegate = self
        scrollViewInicial.isScrollEnabled = true
        scrollViewInicial.isPagingEnabled = true
        
//        scrollViewInicial.contentSize = CGSize(width: self.scrollViewInicial.frame.width, height: self.scrollViewInicial.frame.height*2)
        
        scrollViewInicial.alpha = 0
        scrollViewInicial.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  
            self.scrollViewInicial.iluminar()
                   
               }
       
    }
    func cambioPaginaScrollView(page : Int){
        
        if page == 0 { textFieldTitulo.becomeFirstResponder()}
        
        let scrollPoint = CGPoint(x :0 , y: vistaColores.frame.origin.y)
        scrollViewInicial.setContentOffset(scrollPoint, animated: true)
       

    }
    func configuracionVistasScrollView() {
        
        
    }
    func configuraVistaColores() {
        
        let colorAleatorio = Int.random(in: 0..<8)
        
        if editando == false { vistaColorIcono.cambiarColor(color: coloresCategoria[Int(colorAleatorio)])
            seleccionColor = colorAleatorio
        }
        else {
            seleccionColor = Int(followThingRecibidoEditar.color)
        }
     
        etiquetaColores.frame = CGRect(x: 20, y: 0, width: vistaColores.frame.size.width-40, height: 40)
        collectionViewColores.frame = CGRect(x: 20, y: etiquetaColores.frame.size.height+10, width: scrollViewInicial.frame.width-40, height: scrollViewInicial.frame.size.height-etiquetaColores.frame.size.height-20)
    }
//    MARK : VISTA ICONOS
    func configuraVistaIconos() {
        
       
    }
    //    MARK:- VISTA TITULO
    func configuraVistaTitulo() {
        
        textFieldTitulo.delegate = self
        
        textFieldTitulo.frame = CGRect(x: 2, y: 2, width: scrollViewInicial.frame.size.width-4, height: textFieldTitulo.frame.size.height)
        
        textFieldTitulo.font = fuenteTextField
        textFieldTitulo.backgroundColor = colorTextfieldFondo
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: {
                           
                self.textFieldTitulo.alpha = 1.0
                           
            }, completion: { _ in
                
                self.textFieldTitulo.becomeFirstResponder()
            })
            
        }
    }
//    MARK:- BOTON GUARDAR
    func configuraBotonGuardar(){
                    
        botonGuardar.redondear()
        botonGuardar.titleLabel?.font =  fuenteBotonGuardar
        if editando == false {botonGuardar.backgroundColor = UIColor.init(red: 163/255, green: 165/255, blue: 165/255, alpha: 1.0)
            botonGuardar.setTitle("Crear", for: .normal)
        }
    }
    @IBAction func accionBotonGuardar(_ sender: Any) {
    
        let contexto = conexion()
        
//        let conmutador = ConmutadorFireBaseCoreData.init()
        
        if editando == false {
            
            let uuid = UUID()
            let entidadFollowThing = NSEntityDescription.insertNewObject(forEntityName: "FollowThing", into: contexto) as! FollowThing
            
            entidadFollowThing.titulo = textFieldTitulo.text
            entidadFollowThing.fechaCreacion = Date()
            entidadFollowThing.fechaUltimoUso = Date()
            entidadFollowThing.color = Int16(seleccionColor)
            entidadFollowThing.grupos = 0
            entidadFollowThing.id_FollowThing = uuid
            
            do {
//                *** Guarda en local
                try contexto.save()
//                *** Guarda en firenase
//                conmutador.actualizaFollowThingEnFireBase(followThing: entidadFollowThing)
                
                print("Guardado con éxito")
                var categoriaSeleccionada = UserDefaults.standard.object(forKey:"categoriaSeleccionada") as? [Int]
                categoriaSeleccionada![seleccionColor] = 1
                UserDefaults.standard.set(categoriaSeleccionada, forKey: "categoriaSeleccionada")
                self.delegateVCPrincipal?.actualizaTablaDatosPorId(id: uuid)
                performSegueToReturnBack()
                
            } catch let error as NSError {
                print("Error al guardar: ",error)
            }
        }
        else
        {
            let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
            
            fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingRecibidoEditar.id_FollowThing! as CVarArg)
            
            do {
                let resultado = try conexion().fetch(fetch)
                followThingRecibidoEditar = resultado.first
                followThingRecibidoEditar.titulo = textFieldTitulo.text
                followThingRecibidoEditar.color = Int16(seleccionColor)
                followThingRecibidoEditar.fechaUltimaModificacion = Date()
               
//                *** Guarda en local
                try contexto.save()
//                 *** Guarda en Firebase
//                conmutador.actualizaFollowThingEnFireBase(followThing: followThingRecibidoEditar)
                
                
                self.delegateVCPrincipal?.actualizaTablaDatos()
                
                performSegueToReturnBack()
                
            } catch let error as NSError {
                print("error",error)
            }
        }
        
       
        
    }
//    MARK:- COLLECTION VIEW COLORES
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellColores", for: indexPath) as! CollectionViewCellColores
        
        cell.vistaCeldaColores.layer.borderWidth = 2.0
        cell.vistaCeldaColores.layer.borderColor = UIColor.gray.cgColor
        
        
        vistaColorIcono.cambiarColor(color: coloresCategoria[indexPath.row])
        seleccionColor = indexPath.row
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coloresCategoria.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellColores", for: indexPath) as! CollectionViewCellColores
        
        if collectionView == collectionViewColores {
            
            cell.vistaCeldaColores.backgroundColor = coloresCategoria[indexPath.row]
            
            if indexPath.row == 8 {
                cell.vistaCeldaColores.layer.borderWidth = 2.0
                cell.vistaCeldaColores.layer.borderColor = UIColor.gray.cgColor
                cell.etiquetaColoresCell.text = "Sin color"
            }
            else {
                cell.vistaCeldaColores.layer.borderWidth = 0.5
                cell.vistaCeldaColores.layer.borderColor = UIColor.lightGray.cgColor
                cell.etiquetaColoresCell.text = ""
            }
            return cell
        }
        return cell
    }
//    MARK:- TEXTFIELD
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
      
        etiquetaTItulo.text = updatedText
      
        if updatedText == "" {
            etiquetaTItulo.text = "Añade un título"
            botonGuardar.isHidden = true
            
        } else {botonGuardar.isHidden = false}
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        pasoVistaColores()
        textField.resignFirstResponder();
        return true;
    }
    @objc override func dismissKeyboard() {
    
        view.endEditing(true)

    }
//    MARK:- FUNCIONES DE CLASE
    func editando(editando:Bool){
        
        if editando {
            
            textFieldTitulo.text = followThingRecibidoEditar.titulo!
            etiquetaTItulo.text = followThingRecibidoEditar.titulo!
            vistaColorIcono.backgroundColor = coloresCategoria[Int(followThingRecibidoEditar.color)]
            pasoVistaColores()
            botonGuardar.setTitle("Modificar ", for: .normal)
            botonGuardar.backgroundColor = azulBotonEditar

        }
        
        
    }
//    MARK:- FUNCIONES DE PASO A COLORES
    @IBAction func accionTapIconoColor(_ sender: Any) {
    
        pasoVistaColores()
        cambioPaginaScrollView(page: 1)
        dismissKeyboard()
        
    }
    @IBAction func accionTapTitulo(_ sender: Any) {
        
        cambioPaginaScrollView(page: 0)
        textFieldTitulo.superRebotar()
       
        
    }
    func pasoVistaColores(){
        
        if (textFieldTitulo.text != "")  {
            
            botonGuardar.isHidden = false
          
            
            if editando == false {
            cambioPaginaScrollView(page: 1)
            }
        }
    }
    func iniciaAnimacionColores(){
        
        
    }
    //    MARK:- PAGE CONTROL
    
    func configuracionPageControl() {
        
        if editando == false {
      
    }
   
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let pageNumber = round(scrollView.contentOffset.y / scrollViewInicial.frame.size.height)
       
        
        if Int(pageNumber) == 0 { textFieldTitulo.becomeFirstResponder()} else {
             textFieldTitulo.resignFirstResponder()
        }
       
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         textFieldTitulo.resignFirstResponder()
    }
    
    //    MARK: - FUNCIONES COREDATA
       
       func conexion () -> NSManagedObjectContext {
           
           let delegate = UIApplication.shared.delegate as! AppDelegate
           return delegate.persistentContainer.viewContext
           
       }

    
}
extension UIScrollView {

    func scrollTo(horizontalPage: Int? = 0, verticalPage: Int? = 0, animated: Bool? = true) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(horizontalPage ?? 0)
        frame.origin.y = frame.size.width * CGFloat(verticalPage ?? 0)
        self.scrollRectToVisible(frame, animated: animated ?? true)
    }
    func scrollToPage(index: UInt8, animated: Bool, after delay: TimeInterval) {
           let offset: CGPoint = CGPoint(x: 0 , y:  CGFloat(index) * frame.size.width)
           DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
               self.setContentOffset(offset, animated: animated)
           })
       }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    
    }
    @objc func dismissKeyboard() {
      
        view.endEditing(true)
    }
}
extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
          
        } else {
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}
