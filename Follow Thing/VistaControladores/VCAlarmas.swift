//
//  VCAlarmas.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 30/10/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol ProtocoloVCAlarmas {
    func vuelveDeVCAlarma()
}

class VCAlarmas: UIViewController, UITableViewDelegate, UITableViewDataSource, ProtocoloVCEstadisticaColorAlarma {
    func muestraSeleccionadosDesdeEstadistica(unFollowThingEnvio: UnFollowThing) {
        
    }
    
   
//    MARK: - PROTOCOLO DE CLASE : VCAlarmaEstadisticaColor
    func actualizaDatos(nuevoElemento: Bool) {
        
    }
    
    func vuelveDeVCEstColAlar() {
        
        recargaDatos()
        tablaAlarmas.reloadData()
    }
    
   
    
//  MARK:- IBOULETS
    @IBOutlet var tablaAlarmas: UITableView!
    
//    MARK:- VARIABLES
    var followThings:[FollowThing] = []
    var followThing:FollowThing!
    var unFollowThing:[UnFollowThing] = []
    var todasAlarmas:[AlarmasUnFT] = []
    
    var seccionExceidas:[AlarmasUnFT] = []
    var seccionEnCurso:[AlarmasUnFT] = []
    
    var datos:[[AlarmasUnFT]] = [[],[]]
    
    var titulosCabecera = ["Excedidas", "Próximas"]
    
    var delegado:ProtocoloVCAlarmas? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addBlurEffectFondo()
         view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        tablaAlarmas.backgroundColor = .clear
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recargaDatos()
    }
    
    //    MARK:-CONFIGURADORES INICIALES
    func recargaDatos(){
        
        todasAlarmas.removeAll()
        
        let funcionesAlarmaDB = AlarmaDB.init()
        
        todasAlarmas = funcionesAlarmaDB.leerAlarmaDB(followThing: followThing, unFollowThing: unFollowThing)
        todasAlarmas = funcionesAlarmaDB.compruebaFechaExcedida(alarmas: todasAlarmas, followThing: followThing, unFollowThing: unFollowThing)
        todasAlarmas = funcionesAlarmaDB.compruebaAlarmaIncluida(unFT: unFollowThing, alarmaFT: todasAlarmas, followThing: followThing)
        
        if datos[0].count > 0 {
            datos[0].removeAll()
        }
        if datos[1].count > 0 {
            datos[1].removeAll()
        }
        if todasAlarmas.count == 0 {
            delegado?.vuelveDeVCAlarma()
            performSegueToReturnBack()
        } else {
            separaAlarmasCompletadas()
        }
       
    }
    func separaAlarmasCompletadas(){
        
        var numeroExcedidas:Int = 0
        var numeroEnCurso:Int = 0
        
        if seccionExceidas.count > 0 || seccionEnCurso.count > 0 {
            
            seccionExceidas.removeAll()
            seccionEnCurso.removeAll()
        }
        if datos[0].count > 0 {
            datos[0].removeAll()
        }
        if datos[1].count > 0 {
            datos[1].removeAll()
        }
        
        for alarmas in 1...todasAlarmas.count {
            
            if todasAlarmas[alarmas-1].completado == true {
                
                seccionExceidas.append(todasAlarmas[alarmas-1])
                numeroExcedidas += 1
                datos[0].append(todasAlarmas[alarmas-1])
            }
            else {
                seccionEnCurso.append(todasAlarmas[alarmas-1])
                numeroEnCurso += 1
             
                datos[1].append(todasAlarmas[alarmas-1])
            }
        }
        
        if datos[0].count == 0 {
            datos[0].append(contentsOf: seccionEnCurso)
            datos[1].removeAll()
            
        }
        
    }
    //    MARK:- METODOS DE CLASE
    func fechaAlarmaString(fecha:Date)->String {
        var fechaString:String = ""
        var diaString:String = ""
        
        let hora = NSCalendar.current.component(.hour, from: fecha)
        let minuto = NSCalendar.current.component(.minute, from: fecha)
        let ceroIzquierda:String = String(format: "%02d", minuto)
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: Date(), end: fecha)
        
        if dia == -1 {
            diaString = "Ayer"
        }
        
        if dia == 0 {
           diaString = "Hoy"
        }
        if dia > 0 {
            diaString = "En \(dia) días"
        }
        if dia < 0 {
            diaString = "Hace \(dia) días"
        }
        
        fechaString = "\(diaString) - \(hora):"+ceroIzquierda
        
        return fechaString
    }
    
    //    MARK:- ACCIONES
    @IBAction func btnCancelar(_ sender: Any) {
        
        delegado?.vuelveDeVCAlarma()
        performSegueToReturnBack()
    }
    //    MARK:- GESTOS
    @IBAction func deslizarAbajo(_ sender: Any) {
       
        delegado?.vuelveDeVCAlarma()
        performSegueToReturnBack()
    }
//    MARK:- GESTOS DE CELDA
    @IBAction func tapContenedorEtiquetas(_ sender:AnyObject) {
        
        let row = sender.view.tag % 1000
        let section = sender.view.tag / 1000
        let titulo = datos[section][row].tituloAlarma!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VCAlarEstColor = storyboard.instantiateViewController(identifier: "VCAlarmaEstadisticaColor") as! VCAlarmaEstadisticaColor
        
        VCAlarEstColor.delegado = self
        VCAlarEstColor.unFollowThing = unFollowThing
        VCAlarEstColor.followThing = followThing
        VCAlarEstColor.titulo = titulo
        
        VCAlarEstColor.modalPresentationStyle = .formSheet
        
        self.present(VCAlarEstColor, animated: true, completion: nil)
    }
    @IBAction func tapBtn01(_ sender:AnyObject) {
        
        let row = sender.view.tag % 1000
        let section = sender.view.tag / 1000
      
        let titulo = datos[section][row].tituloAlarma!
        
        Alarmas.borrarAlarmaDB(tituloAlarma: titulo, alarmaFT: todasAlarmas)
        
        recargaDatos()
        
        tablaAlarmas.reloadData()
        
    }
   
    //    MARK:- TABLA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return datos[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if datos[0].count > 0 && datos[1].count > 0 {
            return datos.count
        }
        
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = datos[indexPath.section][indexPath.row]
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCellAlarmas", for: indexPath) as! TableViewCellAlarmas
        
        let alarmasIndex = datos[indexPath.section][indexPath.row]
        
        
        cell.etiquetaTituloAlarma.text = alarmasIndex.tituloAlarma!
        cell.etiquetaSubtitulo.text = fechaAlarmaString(fecha: alarmasIndex.fechaAlarma!)
        
        let tapBtn01 = UITapGestureRecognizer(target: self, action: #selector(VCAlarmas.tapBtn01(_:)))
       
        
        let tapContenedorEtiquetas = UITapGestureRecognizer(target: self, action: #selector(VCAlarmas.tapContenedorEtiquetas(_:)))
        
        
        
        cell.btn01CellAlarma.tag = (indexPath.section * 1000) + indexPath.row
         
       
        
        
        cell.contenedorEtiquetas.tag = (indexPath.section * 1000) + indexPath.row
        
        cell.btn01CellAlarma.addGestureRecognizer(tapBtn01)
        
        cell.contenedorEtiquetas.addGestureRecognizer(tapContenedorEtiquetas)

        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if datos[0].count > 0 && datos[1].count > 0 {
            if section < datos.count {
                return titulosCabecera[section]
            }
        }
        if seccionExceidas.count > 0 && seccionEnCurso.count == 0 {
            return titulosCabecera[0]
        }
        if seccionEnCurso.count > 0 && seccionExceidas.count == 0 {
            return titulosCabecera [1]
        }
       
        
          return nil
    }
//    MARK:- COREDATA
    func conexion()->NSManagedObjectContext{
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    func recargaDatosAlarmas(){
        
    }
    
}
