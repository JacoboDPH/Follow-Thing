//
//  VCResultadoCamara.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 25/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol VCResultadoCamProtocolo {
    func cierraPopover()
    func botonGuardarPulsado()
}
class VCResultadoCamara: UIViewController {
    
    @IBOutlet var imagenResultado: UIImageView!
    @IBOutlet var contenedorBoton: UIView!
    @IBOutlet var botonGuardar: UIButton!
    
    @IBOutlet var etiquetaDiasTitulo: UILabel!
    //    MARK:- VARIABLES
    
    var delegado:VCResultadoCamProtocolo?
    var enteroColor:Int?
    public var image:UIImage?
    public var unFollowThingRecibidoCam:[UnFollowThing] = []
    public var followThingDesdeCam:FollowThing!
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagenResultado.image = image
        
        view.addBlurEffectFondoOscuro()
        
        configuraEtiqueta()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuraElementosVista()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.delegado?.cierraPopover()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    //    MARK:- ACCIONES
    
    @IBAction func accionBotonGuardar(_ sender: Any) {
        guardarFoto()
        delegado?.botonGuardarPulsado()
    }
    
    //MARK:- CONFIGURACION VISTAS
    
    func configuraElementosVista(){
        
        contenedorBoton.redondearVista()
        contenedorBoton.backgroundColor = grisPopOrdenar
        contenedorBoton.frame = CGRect(x: 20, y: view.bounds.height - 120, width: UIScreen.main.bounds.width-40, height: 64)
    
        
        botonGuardar.frame = CGRect(x: 0, y: 0, width: contenedorBoton.frame.size.width, height: contenedorBoton.frame.size.height)
        
        botonGuardar.titleLabel?.font =  fuenteBotonGuardar
        
        botonGuardar.setTitle("Guardar foto", for: .normal)
    }
    func  configuraEtiqueta(){
      
        etiquetaDiasTitulo.textColor = .white
        etiquetaDiasTitulo.font = fuenteVisorTitulo
        
        let dias = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeCam.fechaCreacion!, end: Date())
       
        etiquetaDiasTitulo.text = Fechas.creaStringDias(numeroDia: dias, numeroDiaInvertido: 0, forzarDia: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                   
            self.etiquetaDiasTitulo.iluminar()
               }
    }
//    MARK:- METODOS DE CLASE
    
    //    MARK:- COREDATA
    func conexion()->NSManagedObjectContext{
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    func guardarFoto(){
        
        let contexto = conexion()
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingDesdeCam!.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThingDesdeCam = resultado.first
            followThingDesdeCam.fechaUltimaEntrada = Date()
            
        } catch let error as NSError {
            print("error",error)
        }
        
        let entidadUnFollowThing = NSEntityDescription.insertNewObject(forEntityName: "UnFollowThing", into: contexto) as! UnFollowThing
        
        let imageData = imagenResultado.image!.jpegData(compressionQuality: 0.25)! as Data
        
        entidadUnFollowThing.fechaCreacionUnFT = Date()
        entidadUnFollowThing.foto = imageData as Data
        
        followThingDesdeCam.fechaUltimaEntrada = Date()
        
        followThingDesdeCam.mutableSetValue(forKey: "unFollowThingSet").add(entidadUnFollowThing)
        
        do {
            try contexto.save()
            
        } catch let error as NSError {
            print("no guardo foto :", error)
        }
        performSegueToReturnBack()
        navigationController?.popToViewController(ofClass: VCSecundaria.self)
    }
}

