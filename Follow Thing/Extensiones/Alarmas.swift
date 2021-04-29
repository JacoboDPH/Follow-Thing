//
//  Alarmas.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 27/10/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var followThing:[FollowThing] = []

public class Alarmas {
    
    public static func estableceTodasDe(DBRaiz:[FollowThing]) {
        
        
    }
    
    public static func lanzaNotificacionLocal(titulo:String,subTitulo:String,cuerpo:String, fecha:DateComponents)->UNNotificationRequest{

      
        let lanzador = UNCalendarNotificationTrigger(dateMatching: fecha, repeats: false)
        
//        let lanzador = UNTimeIntervalNotificationTrigger(timeInterval: 8.0, repeats: false)
        
        let action = UNNotificationAction(identifier: "action", title: "Ir", options: [])
        
        let categoria  = UNNotificationCategory(identifier: "categorias", actions: [action], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([categoria])
        
       
        
        let contenido = UNMutableNotificationContent()
        contenido.title = titulo
        contenido.subtitle = subTitulo
        contenido.body = cuerpo
        contenido.sound = UNNotificationSound.default
        contenido.categoryIdentifier = "categorias"
        
        let solicitud = UNNotificationRequest(identifier: "\(titulo):\(subTitulo)", content: contenido, trigger: lanzador)
        
        return solicitud
        
    }
    public static func compruebaSiExisteAlarma(){
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("Alarmas reales:",request)
            }
        })
    }
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
        
    }
    
    public static func borraTodasAlarmas(){
        
        let centro = UNUserNotificationCenter.current()
        
        centro.removeAllDeliveredNotifications()
        centro.removeAllPendingNotificationRequests()
    }
    public static func obtenFechaComponenteAlarma(fecha:Date)->DateComponents {

        var calendario = Calendar.current
        calendario.timeZone = TimeZone.current
        
        let componentes = calendario.dateComponents([.hour, .minute, .month, .day, .year], from: fecha)
        
        return componentes
        
    }
    public static func leerAlarmaDB(followThing:FollowThing, unFollowThing:[UnFollowThing])->[AlarmasUnFT] {
        
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
    public static func compruebaCompletado(alarmas:[AlarmasUnFT])->Bool{
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
           
            var conexion:NSManagedObjectContext
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            conexion = delegate.persistentContainer.viewContext
            
            do {
                try conexion.save()
            } catch let error as NSError {
                print("Error al guardar:",error)
            }
        }
        return existe
    }
    public static func borrarAlarmaDB(tituloAlarma:String,alarmaFT:[AlarmasUnFT]) {
        
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
    public static func compruebaAlarmaIncluida(unFT:[UnFollowThing],alarmaFT:[AlarmasUnFT])->Bool {
        var existe:Bool = false
        
       
        if unFT.count > 0 {
            
            for busqueda in 1...unFT.count {
                
                let titulo = unFT[busqueda-1].anotaciones
                let fechaAnotacion = unFT[busqueda-1].fechaCreacionUnFT
                
                if alarmaFT.count > 0 {
                    
                    for busquedaAlarma in 1...alarmaFT.count {
                        
                        if titulo == alarmaFT[busquedaAlarma-1].tituloAlarma {
                            
                            let fechaAlarma = alarmaFT[busquedaAlarma-1].fechaAlarma
                            
                            if fechaAnotacion! > fechaAlarma! {
                                
                                existe = true
                                
//                                print("YA SE PUEDE BORRAR ESTA ALARMA:",alarmaFT[busquedaAlarma-1].tituloAlarma)
                                
                            }
                        }
                    }
                }
            }
        }
        return existe
    }
  
    public static func existeAlarma(alarmas:[AlarmasUnFT])->Bool{
        
        var existe:Bool = false
        
        if alarmas.count > 0 {
            existe = true
        }
        return existe
    }
    public static func establecerAlarmas(DBRaiz:[FollowThing]) {
        
        
    }
    func conexion()->NSManagedObjectContext{
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
}
