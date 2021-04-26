//
//  AlarmaDB.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 02/11/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//


import CoreData
import UIKit

class AlarmaDB {
    
    


func compruebaFechaExcedida(alarmas:[AlarmasUnFT],followThing:FollowThing,unFollowThing:[UnFollowThing])->[AlarmasUnFT] {
    
    var alarmasUnFTCompletada:[AlarmasUnFT] = []
    
    var existe:Bool = false
    
    if alarmas.count > 0 {
        
        for alarma in 1...alarmas.count {
            
            if alarmas[alarma-1].fechaAlarma! < Date() {
                alarmas[alarma-1].completado = true
                existe = true
            }
        }
    }
    
    if existe {
       
       actualizaDatosDB()
    }
    
    alarmasUnFTCompletada = leerAlarmaDB(followThing: followThing, unFollowThing: unFollowThing)
    
    
    return alarmasUnFTCompletada
}
    public func recuperarAlarmas(followThing:FollowThing)->[AlarmasUnFT]{
        
        var todasAlarmas:[AlarmasUnFT] = []
        
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThing.id_FollowThing! as CVarArg)
        
        var conexion:NSManagedObjectContext
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        conexion = delegate.persistentContainer.viewContext
        
        do {
            let resultado = try conexion.fetch(fetch)
            let followThingDB = resultado.first
            todasAlarmas = (followThingDB?.alarmaUnFTSet?.sortedArray(using: [NSSortDescriptor(key: "fechaAlarma", ascending: true)])) as! [AlarmasUnFT]
        } catch let error as NSError {
            print("Error al recuperar DB de Alarma:",error)
        }
        
        return todasAlarmas
        
    }
public func leerAlarmaDB(followThing:FollowThing, unFollowThing:[UnFollowThing])->[AlarmasUnFT] {
    
    var todasAlarmas:[AlarmasUnFT] = []
    
    let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
    fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThing.id_FollowThing! as CVarArg)
    
    var conexion:NSManagedObjectContext
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    conexion = delegate.persistentContainer.viewContext
    
    do {
        let resultado = try conexion.fetch(fetch)
        let followThingDB = resultado.first
        todasAlarmas = (followThingDB?.alarmaUnFTSet?.sortedArray(using: [NSSortDescriptor(key: "fechaAlarma", ascending: true)])) as! [AlarmasUnFT]
    } catch let error as NSError {
        print("Error al recuperar DB de Alarma:",error)
    }
    
    return todasAlarmas
}
public func compruebaAlarmaIncluida(unFT:[UnFollowThing],alarmaFT:[AlarmasUnFT],followThing:FollowThing)->[AlarmasUnFT] {
    var existe:Bool = false
    
    var alarmasUnFTCompletada:[AlarmasUnFT] = []
   
    if unFT.count > 0 {
        
        for busqueda in 1...unFT.count {
            
            let titulo = unFT[busqueda-1].anotaciones
            let fechaAnotacion = unFT[busqueda-1].fechaCreacionUnFT
            
            if alarmaFT.count > 0 {
                
                for busquedaAlarma in 1...alarmaFT.count {
                    
                    if titulo == alarmaFT[busquedaAlarma-1].tituloAlarma {
                        
                        let fechaAlarma = alarmaFT[busquedaAlarma-1].fechaAlarma
                        
                        if fechaAnotacion != nil && fechaAlarma != nil {
                            
                            if fechaAnotacion! > fechaAlarma! {
                                existe = true
                                
                                print("YA SE PUEDE BORRAR ESTA ALARMA:",alarmaFT[busquedaAlarma-1].tituloAlarma!)
                                
                                borrarAlarmaDB(tituloAlarma: alarmaFT[busquedaAlarma-1].tituloAlarma!, alarmaFT: alarmaFT)
                            }
                        }
                    }
                }
            }
        }
    }
    
   alarmasUnFTCompletada = leerAlarmaDB(followThing: followThing, unFollowThing: unFT)
    
    return alarmasUnFTCompletada
}
public func borrarAlarmaDB(tituloAlarma:String,alarmaFT:[AlarmasUnFT]) {
    
    var conexion:NSManagedObjectContext
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    conexion = delegate.persistentContainer.viewContext
    
    if alarmaFT.count > 0 {
        
        for busqueda in 1...alarmaFT.count {
            
            if alarmaFT[busqueda-1].tituloAlarma == tituloAlarma {
                
                conexion.delete(alarmaFT[busqueda-1])
            }
            
        }
    }
    
    do {
        try conexion.save()
    } catch let error as NSError {
        print("Error al borrar alarma : \(error.localizedDescription)")
    }
}
func actualizaDatosDB() {
    do {
        try conexion().save()
        print("Guardado con éxito")
        
        
    } catch let error as NSError {
        print("Error al guardar: ",error)
    }
}
func conexion () -> NSManagedObjectContext {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    return delegate.persistentContainer.viewContext
    
}
}
