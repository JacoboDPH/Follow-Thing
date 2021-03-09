//
//  UnFollowDB.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 18/11/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import CoreData
import UIKit

class UnFollowDB {
    
    func guardarNuevoUnFT(anotacion:String, color:Int16, followThingDB:FollowThing)->Bool {
        
        var exitoGuardado:Bool = false
        
        let contexto = conexion()
        
        followThingDB.fechaUltimaEntrada = Date()
        
        let entidadUnFollowThing = NSEntityDescription.insertNewObject(forEntityName: "UnFollowThing", into: contexto) as! UnFollowThing
        
        entidadUnFollowThing.anotaciones = anotacion
        entidadUnFollowThing.colorAnotacion = color
        entidadUnFollowThing.fechaCreacionUnFT = Date()
        
        
        followThingDB.mutableSetValue(forKey: "unFollowThingSet").add(entidadUnFollowThing)
        
        do {
            try contexto.save()
            exitoGuardado = true
        } catch let error as NSError {
            print("No guardó nueva anotacion:",error)
        }
        
        return exitoGuardado
    }
    func conexion()->NSManagedObjectContext{
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
}
