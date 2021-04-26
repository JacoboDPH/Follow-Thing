//
//  VCBotonMasFrecuente.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 22/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol VCMasFrecuenteDelegado {
    
    func actualizaDesdeFrecuentes()
    func frecuenteSeleccionado(unFT:UnFollowThing!)
    
}

class VCBotonMasFrecuente: UIViewController, UITableViewDelegate,UITableViewDataSource, NSFetchedResultsControllerDelegate {
   
//   MARK:- IBOULETS
    @IBOutlet var etiquetaTituloMasFrecuente: UILabel!
    @IBOutlet var tablaFrecuentes: UITableView!
    
//MARK:- VARIABLES
    
    public var medidaAnchoPopover:CGFloat!
    
    public var iniciaDesdeVCPrincipal:Bool = false
    
    
    var unFTBDRecibido:[UnFollowThing] = []
    var followThingRecibido:FollowThing!
    var delegate:VCMasFrecuenteDelegado?
    var anotacionesFrecuentes:[String] = []
    var unFollowThingTop:[UnFollowThing] = []
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        etiquetaTituloMasFrecuente.backgroundColor = grisPopOrdenar
        etiquetaTituloMasFrecuente.textColor = .white
        etiquetaTituloMasFrecuente.font = fuentePopover
        etiquetaTituloMasFrecuente.alpha = 0.9
        etiquetaTituloMasFrecuente.frame = CGRect(x: 0, y: 0, width: Int(medidaAnchoPopover), height: alturaEtiquetaPopover)
        tablaFrecuentes.dataSource = self
        tablaFrecuentes.delegate = self
        
//        tablaFrecuentes.isScrollEnabled = false
        
        tablaFrecuentes.frame = CGRect(x: 0, y: CGFloat(alturaEtiquetaPopover), width: view.frame.size.width, height: view.frame.size.height)
        
        view.backgroundColor = blancoTransparente
        view.addBlurEffectFondo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        if iniciaDesdeVCPrincipal == true {
            
            recargarUnFT()
            
            if existeAnotacion()  {
                determinaFrecuentes()
            }
            else {
                tablaFrecuentes.separatorStyle = .none
            }
            etiquetaTituloMasFrecuente.text = followThingRecibido?.titulo
            
            etiquetaTituloMasFrecuente.textColor = .white
            etiquetaTituloMasFrecuente.backgroundColor = colores[Int(followThingRecibido!.color)]
            
            if Int(followThingRecibido!.color) == 8 {
                
                etiquetaTituloMasFrecuente.backgroundColor = colorFondoTituloContenedores
                etiquetaTituloMasFrecuente.textColor = .black
                etiquetaTituloMasFrecuente.borders(for: [.bottom], width: 0.5, color: .black)
            }
            
        }
            
        else {
            if existeAnotacion() {
                determinaFrecuentes()
            }
            etiquetaTituloMasFrecuente.backgroundColor = grisPopOrdenar
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func existeAnotacion()->Bool {
        
        var existe:Bool = false
        
        if unFTBDRecibido.count > 0 {
            
            for busqueda in 1...unFTBDRecibido.count {
                
               if unFTBDRecibido[busqueda-1].anotaciones != nil {
                    existe = true
                }
            }
        }
        
        return existe
        
    }
//    MARK:- CONFIGURACION
    func configuraDesdeVCPrincipal(){
        
        etiquetaTituloMasFrecuente.backgroundColor = .white
        
         
    }
//    MARK:- FUNCIONES DE CLASE
        
    func determinaFrecuentes(){
        
        var diccionario = [String:Int]()

        for busqueda in 1...unFTBDRecibido.count {
            
            if unFTBDRecibido[busqueda-1].foto == nil {
                
                if diccionario.keys.contains(unFTBDRecibido[busqueda-1].anotaciones!)  {
                    
                    diccionario[unFTBDRecibido[busqueda-1].anotaciones!]! += 1

                }
                else
                {
                    diccionario[unFTBDRecibido[busqueda-1].anotaciones!] = 1

                }
            }
        }
       
        for (clave,valor) in (Array(diccionario).sorted {$0.1 > $1.1}) {
            print("\(clave):\(valor)")
           
//            if anotacionesFrecuentes.count <= 3 {
                anotacionesFrecuentes.append(clave)
//            }
        }
       
        for busqueda in 1...anotacionesFrecuentes.count {
       
            for busquedaAnotacion in 1...unFTBDRecibido.count {
                
                if unFTBDRecibido[busquedaAnotacion-1].anotaciones == anotacionesFrecuentes[busqueda-1] {
                    
                    unFollowThingTop.append(unFTBDRecibido[busquedaAnotacion-1])
                    break
                }
            }
        }
       
        
    }
//    MARK:- TABLA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if anotacionesFrecuentes.count > 0 {
            return anotacionesFrecuentes.count
        }
        else
        {
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return CGFloat(alturaCeldaPopover)
    }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellFrecuentes", for: indexPath) as! TableViewCellFrecuentes
        
        cell.etiquetaTituloFrecuente.text = anotacionesFrecuentes[indexPath.row]
        cell.etiquetaTituloFrecuente.text = unFollowThingTop[indexPath.row].anotaciones!
        cell.etiquetaTituloFrecuente.textColor = coloresAnotacion[Int(unFollowThingTop[indexPath.row].colorAnotacion)]
        cell.backgroundColor = .clear
        return cell
       }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true, completion: nil)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if iniciaDesdeVCPrincipal {
        guardaAnotacionDesdeVCPrincipal(unFTGuardar: unFollowThingTop[indexPath.row])
            self.delegate?.actualizaDesdeFrecuentes()
            
        }
        else {
            
            self.delegate?.frecuenteSeleccionado(unFT: unFollowThingTop[indexPath.row])
        }
        
        
    }
//    MARK:- COREDATA
    func conexion()->NSManagedObjectContext{
          
          let delegate = UIApplication.shared.delegate as! AppDelegate
          return delegate.persistentContainer.viewContext
      }
    func recargarUnFT() {
     
       let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
       
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingRecibido.id_FollowThing! as CVarArg)
       
       do {
           let resultado = try conexion().fetch(fetch)
          followThingRecibido = resultado.first!
        unFTBDRecibido = (followThingRecibido.unFollowThingSet?.sortedArray(using: [NSSortDescriptor(key: "fechaCreacionUnFT", ascending: false)])) as! [UnFollowThing]
           
           print("exito*")
       } catch let error as NSError {
           print("error",error)
       }
       

    }
    func guardaAnotacionDesdeVCPrincipal(unFTGuardar:UnFollowThing){
    
        let contexto = conexion()
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingRecibido!.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThingRecibido = resultado.first
            followThingRecibido!.fechaUltimaEntrada = Date()
            
        } catch let error as NSError {
            print("error",error)
        }
        
        let entidadUnFollowThing = NSEntityDescription.insertNewObject(forEntityName: "UnFollowThing", into: contexto) as! UnFollowThing
        
        entidadUnFollowThing.anotaciones = unFTGuardar.anotaciones
        entidadUnFollowThing.colorAnotacion = unFTGuardar.colorAnotacion
        entidadUnFollowThing.fechaCreacionUnFT = Date()
        
        followThingRecibido!.fechaUltimaEntrada = Date()
        followThingRecibido!.mutableSetValue(forKey: "unFollowThingSet").add(entidadUnFollowThing)
        
        do {
            try contexto.save()
            
        } catch let error as NSError {
            print("no guardo anotación :", error)
        }
        
    }
}
