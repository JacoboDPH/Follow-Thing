//
//  VCPrincipal.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 30/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

import Firebase

class VCPrincipal: UIViewController, NSFetchedResultsControllerDelegate,UITableViewDataSource, protocoloDelegadoRegistroFT, UITableViewDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, VCOrdenarPorDelegado, VCMasFrecuenteDelegado, UNUserNotificationCenterDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
  
    
    
    func frecuenteSeleccionado(unFT: UnFollowThing!) {
        
    }
//    MARK:- IBOULETS
    @IBOutlet var tablaPrincipal: UITableView!
    @IBOutlet var botonOrdenar: UIBarButtonItem!
    @IBOutlet weak var barraBuscador: UISearchBar!
    @IBOutlet weak var colleccionColores: UICollectionView!
    @IBOutlet var contenedorColeccionColores: UIView!
    
    @IBOutlet weak var contVistaColorAbajo: NSLayoutConstraint!
    @IBOutlet weak var contVistaColorArriba: NSLayoutConstraint!
    @IBOutlet weak var contVistaColorDcha: NSLayoutConstraint!
    @IBOutlet weak var contVistaColorIzq: NSLayoutConstraint!
    
    @IBOutlet weak var contenedorIndiceLateral: UIView!
    @IBOutlet weak var etiqTituloIndice: UILabel!
    
    @IBOutlet weak var indiceBoton01: UIView!
    @IBOutlet weak var indiceBoton02: UIView!
    @IBOutlet weak var indiceBoton03: UIView!
    @IBOutlet weak var indiceBoton04: UIView!
    @IBOutlet weak var indiceBoton05: UIView!
    @IBOutlet weak var indiceBoton06: UIView!
    @IBOutlet weak var indiceBoton07: UIView!
    @IBOutlet weak var indiceBoton08: UIView!
    @IBOutlet weak var indiceBoton09: UIView!
    
    
//    MARK: - VARIABLES
    var followThing:[FollowThing] = []
    var followThingFiltrado:[FollowThing] = []
    var fetchResultController : NSFetchedResultsController<FollowThing>!
    var animacionRecargaTabla:Bool = true
    var unFollowThingRetorno:[UnFollowThing] = []
    var categoriaMasUsada:[Int] = []
    var indiceEditando = IndexPath()
    var indiceAnotacionFrecuenteDesdeVCPrincipal = IndexPath()
    var alarmaTodasUnFT:[AlarmasUnFT] = []
    
    var incluyeFrecuenteDesdeVCPrincipal:Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        UNUserNotificationCenter.current().delegate = self
        
        self.tablaPrincipal.rowHeight = UITableView.automaticDimension;
        self.tablaPrincipal.estimatedRowHeight = UITableView.automaticDimension;
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.batteryLevelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        
        self.tablaPrincipal.addGestureRecognizer(longPressRecognizer)
        
        configColeccionColores()
        configuradorIndiceLateral()
        muestraIndiceVisible()
        
        recargaDatos(conAnimacion: true)
        
        DispatchQueue.main.async {
            let offset = CGPoint.init(x: 0, y: self.barraBuscador.frame.height )
            self.tablaPrincipal.setContentOffset(offset, animated: false)
            self.tablaPrincipal.reloadData()
        }
        let conmutador = ConmutadorFireBaseCoreData.init()
        

        
//        DispatchQueue.background(completion:  {
//          conmutador.recuperaDatosFireBase()
//        })
       
//        DispatchQueue.background(delay: 0.1, background: {
//            // do something in background
//            conmutador.actualizador()
//        }, completion: {
//            // when background job finishes, wait 3 seconds and do something in main thread
//            DispatchQueue.background(delay: 0.1, background: {
//                // do something in background
//                conmutador.actualizadorUnFT()
//            }, completion: {
//                // when background job finishes, wait 3 seconds and do something in main thread
//                print("--- HA FINALIZADO LA SINCRONIZACION DE DATOS EN FIREBASE")
//            })
//        })
        DispatchQueue.main.async {

//            conmutador.subeFTaFirebase()
//            conmutador.subeFotosAFirebase()
//            conmutador.subeUnFTaFirebase()

        
//          conmutador.descargaTodoFTdeFirebase()
            
           }
//        DispatchQueue.background(background: {
//
//            
//            
//        }, completion:{
//
//            // when background job finished, do something in main thread
//            print("--- HA FINALIZADO LA SINCRONIZACION DE DATOS EN FIREBASE")
//        })
      
        
     
    }
   
    var followThingTemporal:[FollowThing] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
         
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        
        view.layoutIfNeeded()
        
        let ordenGuardado =  UserDefaults.standard.integer(forKey: "ordenGuardado")
        if ordenGuardado == 2 {
            tablaPrincipal.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(estableceAlarmas), name: UIApplication.willResignActiveNotification, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            self.estableceAlarmas()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
           
            Alarmas.compruebaSiExisteAlarma()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
       
    }
    @objc private func batteryLevelChanged(notification: NSNotification){
        print("bateria baja")
    }
//    MARK: - FUNCIONES TITULO NAVEGADOR
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }

    private func initNavigationItemTitleView() {
    
        let titleView = UILabel()
        titleView.text = "Follow Thing"
        titleView.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
       
      
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(VCPrincipal.tituloEsPulsado))
        titleView.isUserInteractionEnabled = true
        
        titleView.addGestureRecognizer(recognizer)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(VCPrincipal.tituloEsLongPress))
        
                 
        titleView.addGestureRecognizer(longPress)
                                               
    }
    
  
    
    var coleccionColoresAbierto:Bool = false
    
    @objc private func tituloEsPulsado(_ sender: UIButton) {
    tablaPrincipal.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        
        if coleccionColoresAbierto {
            
            coleccionColoresAbierto = false
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            self.expandirContenedor(contenedor: self.contenedorColeccionColores, abrir: false, tamaño: 0)
            self.tablaPrincipal.ampliaReduce(tamaño: 1.0)

        }
        else {
            
            coleccionColoresAbierto = true
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            self.expandirContenedor(contenedor: self.contenedorColeccionColores, abrir: true, tamaño: 160)
            
            self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
            self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
            
        }
        
        DispatchQueue.main.async {
            self.tablaPrincipal.reloadData()
        }
        
    }
    
    @objc private func tituloEsLongPress(_ sender: UIButton) {
        
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//
//        self.expandirContenedor(contenedor: self.contenedorColeccionColores, abrir: true, tamaño: 160)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
   
//    MARK:- IBACTION
    
    @IBAction func popoverOrden(_ sender: Any) {

        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popVC = storyboard.instantiateViewController(identifier: "VCOrdenarPor") as! VCOrdenarPor
        
        popVC.delegado = self
        
        popVC.modalPresentationStyle = .popover
        
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.barButtonItem = self.botonOrdenar

        popVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width/1.5, height: (UIScreen.main.bounds.size.width/1.5) / CGFloat(numeroAureo))
       
        self.present(popVC, animated: true)
    
        popVC.popoverPresentationController?.backgroundColor = grisPopOrdenar
        
        popVC.popoverPresentationController!.delegate = self
        
        view.blur()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
      
        
    }
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
         
        view.unblur()
      }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
//    MARK:- CONFIGURADORES
    func configColeccionColores(){
      
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/9, height: UIScreen.main.bounds.width/9)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 10
        self.colleccionColores.collectionViewLayout = flowLayout
        
        colleccionColores.heightConstraint?.constant = UIScreen.main.bounds.width/9
        colleccionColores.layoutIfNeeded()
        
        contenedorColeccionColores.heightConstraint?.constant = 0
        contenedorColeccionColores.layoutIfNeeded()
       
        if  UserDefaults.standard.object(forKey:"categoriaSeleccionada") as? [Int] == nil {
            let categoriaSeleccionadaNuevo = [1,1,1,1,1,1,1,1,1]
            UserDefaults.standard.set(categoriaSeleccionadaNuevo, forKey: "categoriaSeleccionada")
        }
        
        contenedorColeccionColores.borders(for: [.bottom], width: 0.3, color: .gray)
        contenedorColeccionColores.layer.shadowColor = UIColor.black.cgColor
        contenedorColeccionColores.layer.shadowOffset = CGSize(width: 3, height: 3)
        contenedorColeccionColores.layer.shadowOpacity = 0.7
        contenedorColeccionColores.layer.shadowRadius = 10.0
    }
    func configuradorIndiceLateral(){

        for constraint in self.view.constraints {
            if constraint.identifier == "contrainContenedorLateral" {
               constraint.constant = -90
            }
        }
        
        self.contenedorIndiceLateral.frame.origin.x = -90
        self.mueveContenedorEjeX(contenedor: self.contenedorIndiceLateral, coordenadasX: -90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        
        contenedorIndiceLateral.addBlurEffectFondoUltraLight()
        contenedorIndiceLateral.backgroundColor = .clear
        contenedorIndiceLateral.borders(for: [.right], width: 0.5, color: .lightGray)
        
        etiqTituloIndice.text = "Categorías"
        etiqTituloIndice.font = fuenteDiaCell
        
        indiceBoton01.redondoCompleto()
        indiceBoton01.backgroundColor = colores[0]
        
        indiceBoton02.redondoCompleto()
        indiceBoton02.backgroundColor = colores[1]
        
        indiceBoton03.redondoCompleto()
        indiceBoton03.backgroundColor = colores[2]
        
        indiceBoton04.redondoCompleto()
        indiceBoton04.backgroundColor = colores[3]
        
        indiceBoton05.redondoCompleto()
        indiceBoton05.backgroundColor = colores[4]
        
        indiceBoton06.redondoCompleto()
        indiceBoton06.backgroundColor = colores[5]
        
        indiceBoton07.redondoCompleto()
        indiceBoton07.backgroundColor = colores[6]
        
        indiceBoton08.redondoCompleto()
        indiceBoton08.backgroundColor = colores[7]
        
        indiceBoton09.redondoCompleto()
        indiceBoton09.backgroundColor = .clear
        indiceBoton09.borders(for: [.all], width: 1, color: .black)
        
        let gestoIndiceBoton01 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton01 (_:)))
            self.indiceBoton01.addGestureRecognizer(gestoIndiceBoton01)
        
        let gestoIndiceBoton02 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton02 (_:)))
            self.indiceBoton02.addGestureRecognizer(gestoIndiceBoton02)
        
        let gestoIndiceBoton03 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton03 (_:)))
            self.indiceBoton03.addGestureRecognizer(gestoIndiceBoton03)
        
        let gestoIndiceBoton04 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton04 (_:)))
            self.indiceBoton04.addGestureRecognizer(gestoIndiceBoton04)
        
        let gestoIndiceBoton05 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton05 (_:)))
            self.indiceBoton05.addGestureRecognizer(gestoIndiceBoton05)
        
        let gestoIndiceBoton06 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton06 (_:)))
            self.indiceBoton06.addGestureRecognizer(gestoIndiceBoton06)
        
        let gestoIndiceBoton07 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton07 (_:)))
            self.indiceBoton07.addGestureRecognizer(gestoIndiceBoton07)
        
        let gestoIndiceBoton08 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton08 (_:)))
            self.indiceBoton08.addGestureRecognizer(gestoIndiceBoton08)
        
        let gestoIndiceBoton09 = UITapGestureRecognizer(target: self, action:  #selector (self.accionIndiceBoton09 (_:)))
            self.indiceBoton09.addGestureRecognizer(gestoIndiceBoton09)
    }
    
    func muestraIndiceVisible(){
      
        let categoriaSeleccionada = UserDefaults.standard.object(forKey:"categoriaSeleccionada") as? [Int]
        
        let botoneria:[UIView] = [indiceBoton01,indiceBoton02,indiceBoton03,indiceBoton04,indiceBoton05,indiceBoton06,indiceBoton07,indiceBoton08,indiceBoton09]
        
        for categoriasOcultas in 1...categoriaSeleccionada!.count {
            
            if categoriaSeleccionada?[categoriasOcultas-1] == 1 {
                
                botoneria[categoriasOcultas-1].isHidden = false
            }
            else
            {
                botoneria[categoriasOcultas-1].isHidden = true
            }
        }
    }
    //    MARK:- FUNCIONES ENTRE CONTROLADORES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        segue.destination.popoverPresentationController?.delegate = self
        
        if segue.identifier == "VCMainToAddFT" {
              
            let crearFT: VCRegistroFT = segue.destination as! VCRegistroFT
            crearFT.delegateVCPrincipal = self
            
        }
        
        if segue.identifier == "VCMainToSecond" {
            
            let celdaSeleccionada = tablaPrincipal.indexPathForSelectedRow?.row
          
            let objetoVCSecundario: VCSecundaria = segue.destination as! VCSecundaria
            objetoVCSecundario.followThingDB = followThing[celdaSeleccionada!]
            
        }
    }
   
    func actualizaDesdeFrecuentes() {
        incluyeFrecuenteDesdeVCPrincipal = true
              
              view.unblur()
              
              recargaDatos(conAnimacion: false)
              tablaPrincipal.reloadData()
    }
    func muestraSeleccionadorCategoria(){
        
        view.unblur()
        
        self.expandirContenedor(contenedor: self.contenedorColeccionColores, abrir: true, tamaño: 160)
        DispatchQueue.main.async {
            self.tablaPrincipal.reloadData()
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        
        return .none
    }

//    MARK:- FUNCIONES DE DATOS
    func recargaDatos(conAnimacion:Bool){
        
        let categoriaSeleccionadaMostrar = preparaCategoriaSeleccionada(array: (UserDefaults.standard.object(forKey:"categoriaSeleccionada") as? [Int])!)
        
        let compuestos = NSCompoundPredicate(type: .or, subpredicates: [categoriaSeleccionadaMostrar[0],categoriaSeleccionadaMostrar[1],categoriaSeleccionadaMostrar[2],categoriaSeleccionadaMostrar[3],categoriaSeleccionadaMostrar[4],categoriaSeleccionadaMostrar[5],categoriaSeleccionadaMostrar[6],categoriaSeleccionadaMostrar[7],categoriaSeleccionadaMostrar[8]])

        let ordenGuardado =  UserDefaults.standard.integer(forKey: "ordenGuardado")
        
        var ordenAscendente = false
        
        if ordenGuardado == 0 {ordenAscendente = true}
        
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
                       
        let ordenaPor = NSSortDescriptor(key: datosOrdenTabla[ordenGuardado], ascending: ordenAscendente)
     
        fetchRequest.sortDescriptors = [ordenaPor]
        fetchRequest.predicate = compuestos
        
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            followThing = fetchResultController.fetchedObjects!
          
        } catch let error as NSError {
        print("error al recuperar ",error)
        }
    }
    
    func actualizaTablaDatos() {
        
        view.unblur()
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            self.recargaDatos(conAnimacion: true)
            self.tablaPrincipal.reloadData()
        }
        colleccionColores.reloadData()
      
        let topRow = IndexPath(row: 0,
                               section: 0)
        self.tablaPrincipal.scrollToRow(at: topRow,
                                        at: .top,
                                        animated: true)
    }
    func actualizaTablaDatosPorId(id:UUID) {
        
        view.unblur()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            self.recargaDatos(conAnimacion: true)
            self.tablaPrincipal.reloadData()
        }
        colleccionColores.reloadData()
        
        if followThing.count > 0 {
            
            for busqueda in 1...followThing.count {
                
                if followThing[busqueda-1].id_FollowThing == id {
                    
                    let topRow = IndexPath(row: busqueda-1,
                                           section: 0)
                    self.tablaPrincipal.scrollToRow(at: topRow,
                                                    at: .top,
                                                    animated: true)
                    break
                }
            }
        }
    }
    func buscaCategoriaMasUsada(){
         categoriaMasUsada.removeAll()
        
        for busqueda in 0...8 {
            
            let str = "\(busqueda)"
            
            let numUsos = UserDefaults.standard.integer(forKey: str)
            
            categoriaMasUsada.append(numUsos)
        }
       
    }
//    MARK:- FUNCIONES INDICE LATERAL
    
    @IBAction func swipeIndiceLateral(_ sender: Any) {
          
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:0)
        self.tablaPrincipal.ampliaReduce(tamaño: 0.8)
    }
    @objc func accionIndiceBoton01(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(0))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton02(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(1))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton03(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(2))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton04(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(3))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton05(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(4))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton06(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(5))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton07(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(6))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton08(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(7))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    @objc func accionIndiceBoton09(_ sender:UITapGestureRecognizer){
        self.posicionaTablaEnCategoria(colorCategoria: Int16(8))
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        }
    
    //    MARK:- COLECCION COLERES
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var categoriaSeleccionada = UserDefaults.standard.object(forKey:"categoriaSeleccionada") as? [Int]
        
        if categoriaSeleccionada?[indexPath.row] == 1 {
            categoriaSeleccionada?[indexPath.row] = 0
        } else
        {
            categoriaSeleccionada?[indexPath.row] = 1
        }
        
        UserDefaults.standard.set(categoriaSeleccionada, forKey: "categoriaSeleccionada")
        
        collectionView.reloadItems(at: [IndexPath.init(row: indexPath.row, section: 0)])
        
        DispatchQueue.main.async {
            self.recargaDatos(conAnimacion: true)
            self.tablaPrincipal.reloadData()
            self.posicionaTablaEnCategoria(colorCategoria: Int16(indexPath.row))
        }
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColeccionColores", for: indexPath) as! ColeccionColoresCell
        cell.contenedor.animadoVibracionMedio()
        
        muestraIndiceVisible()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellColeccionColores", for: indexPath) as! ColeccionColoresCell
        
        cell.contenedor.backgroundColor = .clear
        
        let categoriaSeleccionada = UserDefaults.standard.object(forKey:"categoriaSeleccionada") as? [Int]
        
      
        if categoriaSeleccionada?[indexPath.row] == 1 {
            
            cell.contenedor.backgroundColor = colores[indexPath.row]
        }
        else {
            cell.contenedor.backgroundColor = .clear
        }
        
        if indexPath.row == 8 {
            cell.contentView.layer.borderWidth = 2.0
            cell.contentView.layer.borderColor = UIColor.gray.cgColor
        }
        else {
            cell.contentView.layer.borderWidth = 2.5
            cell.contentView.layer.borderColor = colores[indexPath.row].cgColor
        }
        return cell
    }
    func posicionaTablaEnCategoria(colorCategoria:Int16){
        
        if followThing.count > 0 {
        
        for busqueda in 1...followThing.count {
            
            if colorCategoria == followThing[busqueda-1].color {
               
                let indexPath = IndexPath(row: busqueda-1, section: 0)
                tablaPrincipal.scrollToRow(at: indexPath, at: .top, animated: false)
                break
            }
        }
        }
    }
   
    func preparaCategoriaSeleccionada(array:[Int])->[NSPredicate] {
        
        var predicados:[NSPredicate] = []
        
        for seleccion in 1...array.count {
            
            if array[seleccion-1] == 1 {
               
                var predicado: NSPredicate = NSPredicate()
                let numeroColor:Int16 = Int16(seleccion-1)
                predicado = NSPredicate(format: "color == \(numeroColor)")
                predicados.append(predicado)
            }
            else {
                var predicado: NSPredicate = NSPredicate()
                predicado = NSPredicate(format: "color == \(99)")
                predicados.append(predicado)
            }
        }
        
        return predicados
    }
    @IBAction func accionGestoCerrarSeleccionadorColores(_ sender: Any) {
        self.expandirContenedor(contenedor: self.contenedorColeccionColores, abrir: false, tamaño: 0)
       
    }
    //    MARK:- BARRA BUSCADOR

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard !searchText.isEmpty else {
            recargaDatos(conAnimacion: false)
          
            DispatchQueue.main.async {
                self.tablaPrincipal.reloadData()
            }
            return
        }
        if !searchText.isEmpty {
         
            var predicate: NSPredicate = NSPredicate()
                   predicate = NSPredicate(format: "titulo CONTAINS[c] '\(searchText)'")
            
            let ordenGuardado =  UserDefaults.standard.integer(forKey: "ordenGuardado")
            
            var ordenAscendente = false
            
            if ordenGuardado == 0 {ordenAscendente = true}
            
            let contexto = conexion()
            let fetchRequest : NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
                           
            let ordenaPor = NSSortDescriptor(key: datosOrdenTabla[ordenGuardado], ascending: ordenAscendente)
         
            fetchRequest.sortDescriptors = [ordenaPor]
            fetchRequest.predicate = predicate
            
            fetchResultController.delegate = self
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
           
            
            do {
                try fetchResultController.performFetch()
                followThing = fetchResultController.fetchedObjects!
               
            } catch let error as NSError {
            print("error al recuperar ",error)
            }
            
            DispatchQueue.main.async {
                self.tablaPrincipal.reloadData()
            }
          
        }
        
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == barraBuscador {
        barraBuscador.text = ""
        recargaDatos(conAnimacion: false)
            tablaPrincipal.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    //    MARK:- FUNCIONES TABLE
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       
        if scrollView == tablaPrincipal {
            dismissKeyboard()
            self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
            self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
          
        }
    }
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {

      
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {

            let touchPoint = longPressGestureRecognizer.location(in: self.tablaPrincipal)
            if let indexPath = tablaPrincipal.indexPathForRow(at: touchPoint) {
            
                indiceEditando = indexPath

                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let popVC = storyboard.instantiateViewController(withIdentifier: "VCBotonMasFrecuente") as! VCBotonMasFrecuente
                
                let FTIndex = followThing[indexPath.row]
  
                
                let generator = UIImpactFeedbackGenerator(style: .medium)
                       generator.impactOccurred()
              
                popVC.delegate = self
              
                popVC.iniciaDesdeVCPrincipal = true
                popVC.followThingRecibido = FTIndex

                
                popVC.modalPresentationStyle = .popover
                
                let popOverVC = popVC.popoverPresentationController
                popOverVC?.delegate = self
                popOverVC?.sourceView = self.view
                popVC.medidaAnchoPopover = UIScreen.main.bounds.width-40
                
                popOverVC?.sourceRect = CGRect(x: 20, y: view.center.y - ((UIScreen.main.bounds.width-40) / 2) , width: 0, height: 0)
                
                popOverVC?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                
                popVC.preferredContentSize = CGSize(width:396.41832724, height: 245)
                
                self.present(popVC, animated: true)
                popVC.popoverPresentationController!.delegate = self
                
                view.blur()
            }
    }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followThing.count
    }
    func fechaUltimaAnotacionResultado(fecha:Date)->String {
        
        var resultado:String = ""
        let dia = Fechas.calculaDiasEntreDosFechas(start: fecha, end: Date())
       
        
        if dia == 0 {
              resultado = "Última vez hoy"
        }
        else if dia == 1 {
             resultado = "Última vez ayer"
        } else if dia > 1 {
            resultado = "Última vez "+Fechas.formatoFechaUltimoUso.string(from:fecha)
        }
       
        return resultado
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCellPrincipal
        let followThingIND = followThing[indexPath.row]
        
        let dias:Int = Fechas.calculaDiasEntreDosFechas(start: followThingIND.fechaCreacion! as Date, end: Date())
      
        var fechaUltimaAnotacion:String = ""
        
        if followThingIND.fechaUltimaEntrada != nil {
            fechaUltimaAnotacion = fechaUltimaAnotacionResultado(fecha: followThingIND.fechaUltimaEntrada!)
        }      
        
        cell.etiquetaTitulo.text = followThingIND.titulo
        cell.iconoColor.backgroundColor = colores[Int(followThingIND.color)]
        
        cell.etiquetaDia.text = Fechas.creaStringDias(numeroDia: dias, numeroDiaInvertido: 0, forzarDia: true)       
        cell.etiquetaUltimaVez.text = fechaUltimaAnotacion
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
             
        if animacionRecargaTabla  {
            let animation = Animator.AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.05)
            let animator = Animator(animation: animation)
            
            animator.animate(cell: cell, at: indexPath, in: tableView)
            
            if indexPath.row == 4 {
                animacionRecargaTabla = false
            }
        }
        
        if incluyeFrecuenteDesdeVCPrincipal {
            
            if indiceEditando.isEmpty == false {
                
                if indiceEditando.row == indexPath.row {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                        cell.superRebotar()
                    })
                    
                    incluyeFrecuenteDesdeVCPrincipal = false
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        followThing[indexPath.row].fechaUltimoUso = Date()
       
        actualizarDatos()
        
       
////        let str1 = "\(tareaSeleccionada.color)"
////
////        let ordenCategoria = UserDefaults.standard.integer(forKey: str1)
////
////        UserDefaults.standard.set(ordenCategoria+1,forKey: str1)
////
////        buscaCategoriaMasUsada()
        
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      
        self.mueveContenedorEjeX(contenedor:self.contenedorIndiceLateral,coordenadasX:-90)
        self.tablaPrincipal.ampliaReduce(tamaño: 1.0)
        
        let botonBorrar = UIContextualAction(style: .destructive, title: "Borrar") { (action, view, handler) in
            
            let contexto = self.conexion()
            
//            let pendienteBorrar = PendienteBorrarDB.init()
//            
//            pendienteBorrar.guardaPenditeneBorrar(idFollowThing: self.followThing[indexPath.row].id_FollowThing!, idFechaUnFT: self.followThing[indexPath.row].fechaCreacion!, borradoCompleto: true)
            
            
            let borrar = self.fetchResultController.object(at: indexPath)
            contexto.delete(borrar)
            
            do{
                try contexto.save()
            } catch {
                print("problemas al borrar")
            }
        }
        let botonEditar = UIContextualAction(style: .normal, title: "Editar") { (action, view, handler) in
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let VCRegistroFT = storyBoard.instantiateViewController(withIdentifier: "VCRegistroFT") as! VCRegistroFT
            VCRegistroFT.editando = true
            VCRegistroFT.followThingRecibidoEditar = self.followThing[indexPath.row]
            self.present(VCRegistroFT, animated:true, completion:nil)
            self.indiceEditando = indexPath
            
        }
        botonEditar.backgroundColor = azulBotonEditar
        botonBorrar.backgroundColor = rojoBotonEditar
        let configuration = UISwipeActionsConfiguration(actions: [botonBorrar,botonEditar])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
//    MARK:- ALARMA
    
    func lanzaNotificacion(titulo:String,subTitulo:String,cuerpo:String, fecha:DateComponents){
        
        let solicitud = Alarmas.lanzaNotificacionLocal(titulo: titulo, subTitulo: subTitulo, cuerpo: cuerpo, fecha: fecha)
        
        UNUserNotificationCenter.current().add(solicitud, withCompletionHandler: {(error) in
            if let error = error {
                print("error al lanzar notificacion: ",error)
            }
        })
        
        Alarmas.compruebaSiExisteAlarma()
        
        
    }    //    MARK: - COREDATA
    func conexion()->NSManagedObjectContext{
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    func actualizarDatos() {
        
        do {
            
            try conexion().save()
            
        } catch let error as NSError {
            print("No ha sido posible guardar \(error), \(error.userInfo)")
        }
        
    }
    func recuperaDatosUnFollowThing(index:IndexPath)  {
        
        var followThingIndex = followThing[index.row]
       
        
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingIndex.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThingIndex = resultado.first!
            unFollowThingRetorno = (followThing[index.row].unFollowThingSet?.sortedArray(using: [NSSortDescriptor(key: "fechaCreacionUnFT", ascending: false)])) as! [UnFollowThing]
            
            print("exito")
        } catch let error as NSError {
            print("error",error)
        }
        
        
        
    }
    func borrarUnaAnotacion(unaAnotacion:IndexPath) {
        
        conexion().delete(followThing[unaAnotacion.row])
        followThing.remove(at:unaAnotacion.row)
        
        do {
            try conexion().save()
            
            tablaPrincipal.deleteRows(at: [unaAnotacion], with: .fade)
            
        } catch let error as NSError {
            print("Error al borrar comentario : \(error.localizedDescription)")
        }
        
    }
   
    @objc func estableceAlarmas() {
        
        if followThing.count > 0 {
        
        DispatchQueue.background(delay: 0.3, completion:{
         
            Alarmas.borraTodasAlarmas()
            
            var titulo:String = ""
            
            let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
           
           
                
                    
            for busqueda in 1...self.followThing.count {
                
                
                fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),self.followThing[busqueda-1].id_FollowThing! as CVarArg)
                
                
                
                do {
                    let resultado = try self.conexion().fetch(fetch)
                    let followThingDB = resultado.first
                    self.alarmaTodasUnFT = (followThingDB?.alarmaUnFTSet?.sortedArray(using: [NSSortDescriptor(key: "tituloAlarma", ascending: false)])) as! [AlarmasUnFT]
                    
                    titulo = followThingDB!.titulo!
                    
                } catch let error as NSError {
                    print("error cargar DB",error)
                }
                
                if self.alarmaTodasUnFT.count > 0 {
                    
                    for alarma in 1...self.alarmaTodasUnFT.count {
                        
                        print("Alarma lanzada en principal: ",self.followThing[busqueda-1].titulo,self.alarmaTodasUnFT[alarma-1].fechaAlarma,self.alarmaTodasUnFT[alarma-1].tituloAlarma)
                        
                        self.lanzaNotificacion(titulo: titulo, subTitulo: self.alarmaTodasUnFT[alarma-1].tituloAlarma!, cuerpo: "Recuerda incluir esta anotación", fecha: Alarmas.obtenFechaComponenteAlarma(fecha: self.alarmaTodasUnFT[alarma-1].fechaAlarma!))
                    }
                    
                }
            }
        })
            
        }
        
    }
    // MARK:- FUNCIONES FETCHEDREQUEST
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tablaPrincipal.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tablaPrincipal.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tablaPrincipal.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tablaPrincipal.deleteRows(at: [indexPath!], with: .fade)
        case.update:
            self.tablaPrincipal.reloadRows(at: [indexPath!], with: .fade)
        default:
            self.tablaPrincipal.reloadData()
        }
        
        self.followThing = controller.fetchedObjects as! [FollowThing]
        
    }
    
}


public final class Animator {
    
    typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void
    private var hasAnimatedAllCells = false
    private let animation: Animation
    
    enum AnimationFactory {
        
        static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
            return { cell, indexPath, tableView in
                cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
                
                UIView.animate(
                    withDuration: duration,
                    delay: delayFactor * Double(indexPath.row),
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 0.1,
                    options: [.curveEaseInOut],
                    animations: {
                        cell.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
        }
        
        static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
            return { cell, indexPath, _ in
                cell.alpha = 0
                
                UIView.animate(
                    withDuration: duration,
                    delay: delayFactor * Double(indexPath.row),
                    animations: {
                        cell.alpha = 1
                })
            }
        }
    }
    
    init(animation: @escaping Animation) {
        self.animation = animation
    }
    
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }
        
        animation(cell, indexPath, tableView)
        
        //         hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
    }
   
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
 }
extension UIViewController {
func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
    if #available(iOS 13.0, *) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
        navBarAppearance.backgroundColor = backgoundColor

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

        navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.title = title

    } else {
        // Fallback on earlier versions
        navigationController?.navigationBar.barTintColor = backgoundColor
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = title
    }
}}
extension UIViewController {
    func presentOnRoot(`with` viewController : UIViewController){
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.popover
        self.present(navigationController, animated: false, completion: nil)
    }
}
