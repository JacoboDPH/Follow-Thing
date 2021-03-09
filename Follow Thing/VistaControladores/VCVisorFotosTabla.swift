//
//  VCVisorFotosTabla.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 30/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit

protocol delegadoVisorFotosTabla {
    func configuraFotoDesdeTabla(unaFoto:UIImage,unaFecha:Date)
    func zoomDesdeVisorTabla(recognizer: UITapGestureRecognizer)
    func pinchCell(sender:UIPinchGestureRecognizer)
}

class VCVisorFotosTabla: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
//    MARK:- IBOULETS
    
    @IBOutlet var tablaVisor: UITableView!
    
//    MARK:- VARIABLES
    
    var unFollowThingRecibidoSec:[UnFollowThing] = []
    var matrizFotos:[UnFollowThing] = []
    var followThingDBRecibido:FollowThing!
    public var fechaCreacionUnFTRecibido:Date?
    public var desdeVisorFotos = false
    var delegado:delegadoVisorFotosTabla?
    
    var desdeHace:Bool = false
  
      private var indexPathSeleccionado:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tablaVisor.delegate = self
        tablaVisor.dataSource = self
        
        self.title = followThingDBRecibido.titulo
        
        navigationBlur()
        
        configuraCabecera()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preparaMatrizFotos()
    
     
    }
    func configuraCabecera(){
        desdeHace = UserDefaults.standard.bool(forKey: "tapDia")
    }
//    MARK:- CONFIGURACION
    func configuraDesdeVisor(){
        
        if desdeVisorFotos {
            
            let index = matrizFotos.firstIndex(where: {$0.fechaCreacionUnFT! == fechaCreacionUnFTRecibido})
            
            if index != nil {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                    
                    self.tablaVisor.scrollToRow(at: IndexPath(row: index!, section: 0), at: .top, animated: false)
                    
                })
            }
        }
    }
    
    func navigationBlur(){
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "rectangle.grid.3x2.fill"), style: .plain, target: self, action: #selector(addTapped))
    }
    @objc func addTapped(){
        
    }
    
//    MARK:- FUNCIONES DE CLASE
    @objc func tapEdit(recognizer: UITapGestureRecognizer) {
       
        let FT = matrizFotos[indexPathSeleccionado!.row]
        
        self.delegado?.configuraFotoDesdeTabla(unaFoto: UIImage(data: FT.foto! as Data)!, unaFecha: FT.fechaCreacionUnFT!)
        
        self.delegado?.zoomDesdeVisorTabla(recognizer: recognizer)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func preparaMatrizFotos() {
        if unFollowThingRecibidoSec.count > 0 {
            
            for busquedaFoto in 1...unFollowThingRecibidoSec.count {
                
                if unFollowThingRecibidoSec[busquedaFoto-1].foto != nil {
                    
                    matrizFotos.append(unFollowThingRecibidoSec[busquedaFoto-1])
                }
            }
            configuraDesdeVisor()
        }
    }
//    MARK:- FUNCIONES DE TABLA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matrizFotos.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tablaVisor.frame.height
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellVisorFotos", for: indexPath) as! TableViewCellVisorFotos
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
        recognizer.numberOfTapsRequired = 2
        
        cell.fotoVisor.isUserInteractionEnabled = true
        cell.fotoVisor.addGestureRecognizer(recognizer)
      
        let indexDB = matrizFotos[indexPath.row]

        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDBRecibido.fechaCreacion!, end: indexDB.fechaCreacionUnFT!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDBRecibido.fechaCreacion!, end: Date()) - dia
        
        cell.fotoVisor.image = UIImage(data: indexDB.foto! as Data)
//        cell.etiquetaDia.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, desdeHace: desdeHace)
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        indexPathSeleccionado = indexPath
        
        
//        let FT = matrizFotos[indexPath.row]
//
//        self.delegado?.configuraFotoDesdeTabla(unaFoto: UIImage(data: FT.foto! as Data)!, unaFecha: FT.fechaCreacionUnFT!)
//
//        self.dismiss(animated: true, completion: nil)
        
    }
}
