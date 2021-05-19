//
//  VCSecundaria.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 31/07/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol ProtocoloVCSecundario {
    func estableceAlarmaVCAnterior()
}

class VCSecundaria: UIViewController,UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate,VCMasFrecuenteDelegado, UIViewControllerTransitioningDelegate, CellSecundariaImageTap, ProtocoloDelegadoVisorUnico, ProtocoloDelegadoCollectionViewFotos, ProtocoloVCEstadisticaColorAlarma, UNUserNotificationCenterDelegate, ProtocoloVCAlarmas{
   
    //    MARK:- IBOUTLET
    
    @IBOutlet var scrollSecundaria: UIScrollView!
    @IBOutlet var contolPagina: UIPageControl!
    @IBOutlet var vistaUnoScroll: UIView!
    @IBOutlet var tablaSecundaria: UITableView!
 
    @IBOutlet var textFieldVistaUno: UITextField!
    @IBOutlet var etiquetaDiaVistaUno: UILabel!
    @IBOutlet weak var etiqueScroll02: UILabel!
    @IBOutlet weak var btnCancelarCancel: UIButton!
    
    @IBOutlet weak var btnCancelarScroll: UIButton!
    

    @IBOutlet var etiquetaInfoVCSec: UILabel!
    @IBOutlet var contendorInformativo: UIView!
    @IBOutlet var btn01ContendorInfo: UIButton!
    @IBOutlet var btn02ContenedorInfo: UIButton!
    @IBOutlet var etiquetaTituloContInfo: UILabel!
    
    @IBOutlet var contenedorAlarmasInfo: UIView!
    @IBOutlet var iconoAlarmaIzq: UIImageView!
    
    
    @IBOutlet var contendorOpciones: UIView!
    @IBOutlet var btn01Opciones: UIButton!
    @IBOutlet var btn02Opciones: UIButton!
    @IBOutlet var btn03Opciones: UIButton!
    
    
    @IBOutlet var contenedorEntradaTexto: UIView!
    @IBOutlet var btn03EntradaTexto: UIButton!
    @IBOutlet var btn02EntradaTexto: UIButton!
    @IBOutlet var botonFrecuentes: UIButton!
    
    
    
    //   MARK:- CONSTRAIN
    @IBOutlet var contOpcionesEntradaTexto: NSLayoutConstraint!
    
    
    
    //    MARK:- VARIABLES
    
    public var followThingDB:FollowThing!
    private var fetchResultController:NSFetchedResultsController<UnFollowThing>!
    var unFollowThingActual:[UnFollowThing] = []
    var followThingActual:FollowThing?
    var unFTAgrupadas:[UnFollowThing] = []
    var unFTRespaldo:[UnFollowThing] = []
    var todasAlarmas:[AlarmasUnFT] = []
    var unFollowThingObjetivo:UnFollowThing!
    
    var insertarNuevoElemento:Bool = false
    var editandoAnotacion:Bool = false
    var estadoEtiquetaInfo:Bool = false
    var estadoEtiquetaExpansible:Bool = false
    var desdeHace:Bool = false
    var estadoContendorAlarma = false
    var textoPreditivo:Bool = false
    
    var delegado:ProtocoloVCSecundario? = nil
    
    var anotacionesEditar:String = ""
    var indiceEditarSeleccionado:Int = 0
    var indiceEditando = IndexPath()
    
    var unFTNuevaAnotacion:UnFollowThing!
    var anotacionesFrecuentes:[String] = []
    var unFollowThingTop:[UnFollowThing] = []
    
    
    
    lazy var refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        let sincronizacion = UserDefaults.standard.bool(forKey: "sincronizacion")
      
        refreshControl.addTarget(self, action: #selector(VCSecundaria.sincronizar), for: .valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
        
}()
    
    //    MARK:- CONSTANTES
    
    let alturaEtiquetaTitulo = 50
    let alturaEtiquetaTiempo = 30
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        
        self.tablaSecundaria.delegate = self
        self.tablaSecundaria.dataSource = self
        
        self.tablaSecundaria.addSubview(self.refreshControl)
        
      
        self.tablaSecundaria.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: contendorOpciones.frame.size.height + contenedorEntradaTexto.frame.size.height, right: 0)
        
        configuraVistasScroll()
        configuraVistaUnoScroll()
        configuraContendorInformativo()
        configuraCabecera()
        configuraContendorAlarmaInfo()
        configuraContenedorOpciones()
        configuraContenedorEntradaTexto()
        
        self.hideKeyboardWhenTappedAround()
        
        textFieldVistaUno.returnKeyType = .default
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            self.compruebaSiExisteNotificacionIncluida()
        }
        estadoBotonesEntradaTexto(modo: 0)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(recibeNotificacionDeActualizacion), name: Notification.Name("actualizaTablaUnFollowThing"), object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        configuraScroll()
        recuperaDatos()
        tablaSecundaria.reloadData()
        ajustaSeparadorTabla()
        
        compruebaAlarmas()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoDesaparece), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tecladoAparece), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(estableceAlarmas), name: UIApplication.willResignActiveNotification, object: nil)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32),NSAttributedString.Key.foregroundColor: UIColor.black]
        
      
        if followThingDB.color != 8 {
        
        let colorCategoria = coloresCategoria[Int(followThingDB.color)]
        self.navigationController?.navigationBar.barTintColor = colorCategoria
               self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationItem.title = followThingDB?.titulo
    
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32),NSAttributedString.Key.foregroundColor: UIColor.white]
        
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         
        NotificationCenter.default.removeObserver(self)
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    //    MARK:- FUNCIONES DE CONFIGURACION
    func configuraScroll(){
        
        scrollSecundaria.delegate = self
        scrollSecundaria.isScrollEnabled = true
        scrollSecundaria.isPagingEnabled = true
        scrollSecundaria.isDirectionalLockEnabled = true
        scrollSecundaria.showsHorizontalScrollIndicator = false
        scrollSecundaria.showsVerticalScrollIndicator = false
        
        propiedades(contened: scrollSecundaria, alphaTop:0.30, puntos: [.bottom])
    }
    func configuraCabecera(){
           
        self.navigationItem.backBarButtonItem?.title = ""
        self.title = followThingDB.titulo!
        
        desdeHace = UserDefaults.standard.bool(forKey: "tapDia")
        
        if !desdeHace {
         
            etiquetaDiaVistaUno.text = Fechas.creaStringDias(numeroDia: Fechas.calculaDiasEntreDosFechas(start: followThingDB.fechaCreacion!, end: Date()), numeroDiaInvertido: 0, forzarDia: true)
        }
        else {
            etiquetaDiaVistaUno.text = Fechas.fechaCompletaDesde(date: followThingDB.fechaCreacion!)
        }
            
              
        etiquetaDiaVistaUno.layoutIfNeeded()
               
    }
    func configuraContendorInformativo() {
        
        contendorInformativo.heightConstraint?.constant = 0
        contendorInformativo.layoutIfNeeded()
        
        contendorInformativo.backgroundColor = .white
        
       
        btn02ContenedorInfo.backgroundColor = .clear
        btn02ContenedorInfo.borders(for: [.all], width: 0.5, color: .lightGray)
         
        btn01ContendorInfo.setTitleColor(.white, for: .normal)
        btn02ContenedorInfo.setTitleColor(.black, for: .normal)
        
        
        btn02ContenedorInfo.setTitle("Aplicar seleccionado", for: .normal)
        btn01ContendorInfo.setTitle("Aplicar a todos", for: .normal)
        
        
        btn02ContenedorInfo.redondear()
        btn01ContendorInfo.redondear()
        
        etiquetaInfoVCSec.backgroundColor = .clear
        
        etiquetaInfoVCSec.textAlignment = .left
        etiquetaInfoVCSec.textColor = .black
        etiquetaInfoVCSec.sombraLargaVista()
        
        etiquetaTituloContInfo.textAlignment = .left
        etiquetaTituloContInfo.textColor = .lightGray
        etiquetaTituloContInfo.text = "Editar"
        
        
        contendorInformativo.borders(for: [.bottom], width: 0.5, color: .gray)
        
        contendorInformativo.alpha = 0
    }
    func configuraContendorAlarmaInfo(){
                
        contenedorAlarmasInfo.heightConstraint?.constant = 0
        contenedorAlarmasInfo.layoutIfNeeded()
        
        contenedorAlarmasInfo.backgroundColor = colorFondoTituloContenedores
        iconoAlarmaIzq.backgroundColor = .clear
        contenedorAlarmasInfo.borders(for: [.bottom], width: 0.5, color: .gray)
        
        contenedorAlarmasInfo.alpha = 0
        
    }
    func configuraVistasScroll(){
        
        scrollSecundaria.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contolPagina.isHidden = true
        btnCancelarScroll.isHidden = true
        vistaUnoScroll.backgroundColor = .clear
       
    }
    func configuraContenedorOpciones(){
        
        propiedades(contened: contendorOpciones, alphaTop: 0.0, puntos: .top)
    }
    func configuraVistaUnoScroll(){

        
    }
    func configuraContenedorEntradaTexto(){
        
        textFieldVistaUno.backgroundColor = colorTextfieldFondo
        
        propiedades(contened: contenedorEntradaTexto, alphaTop: 0.30, puntos: [.top])
        btn02EntradaTexto.backgroundColor = .clear
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressFrecuente(gesture:)))
        botonFrecuentes.addGestureRecognizer(longPress)
        
        botonFrecuentes.redondear()
        
        textoPreditivo = UserDefaults.standard.bool(forKey: "textoPreditivo")
        
        botonFrecuentes.tintColor = .gray
        if textoPreditivo {
            
            if followThingDB.color != 8 {
                botonFrecuentes.backgroundColor = coloresCategoria[Int(followThingDB.color)]
                botonFrecuentes.tintColor = .white
            }
            else {
            botonFrecuentes.backgroundColor = azulBotonEditar
            botonFrecuentes.tintColor = .white
            }
        }
        
    }
    
    func propiedades(contened:UIView,alphaTop:Float,puntos:UIRectEdge){
     
        contened.addBlurEffectFondo()
        contened.backgroundColor = UIColor.white.withAlphaComponent(0.90)
        contened.borders(for: [puntos], width: 0.5, color: UIColor.darkGray.withAlphaComponent(CGFloat(alphaTop)))
        
    }
//    MARK:- PROTOCOLOS DE CLASE
    func estableceAlarmaVCAnterior() {
        delegado?.estableceAlarmaVCAnterior()
    }
    func actualizaDatos(nuevoElemento: Bool) {
        insertarNuevoElemento = nuevoElemento
        
        if nuevoElemento == true {
            
            let topRow = IndexPath(row: 0,
                                   section: 0)
            tablaSecundaria.scrollToRow(at: topRow,
                                        at: .top,
                                        animated: true)}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            
            self.recuperaDatos()
            self.tablaSecundaria.reloadData()
            self.ajustaSeparadorTabla()
        }
    }
    func envioFotosTeatro(arrayFotos: [UnFollowThing]) {
        
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VCVisorFotoUnica = storyboard.instantiateViewController(identifier: "VCVisorFotos") as! VCVisorFotos
   
            VCVisorFotoUnica.unFollowThings = self.unFollowThingActual
            VCVisorFotoUnica.followThing = self.followThingDB
            VCVisorFotoUnica.unFollowThingTeatro = arrayFotos
            VCVisorFotoUnica.unFollowThingObjetivo = self.unFollowThingObjetivo
            
            VCVisorFotoUnica.modalTransitionStyle = .crossDissolve
            VCVisorFotoUnica.modalPresentationStyle = .overCurrentContext
            
            self.present(VCVisorFotoUnica, animated: true, completion: nil)
        }
    }
    func envioFotoCollection(unFollow: UnFollowThing!) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
        
            if unFollow.foto != nil {
                
                self.recuperaDatos()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let VCVisorFotos  = storyboard.instantiateViewController(identifier: "VCVisorFotos") as! VCVisorFotos
                
                VCVisorFotos.followThing = self.followThingDB
                VCVisorFotos.unFollowThings = self.unFollowThingActual
                VCVisorFotos.unFollowThingObjetivo = unFollow
                
                VCVisorFotos.modalTransitionStyle = .crossDissolve
                VCVisorFotos.modalPresentationStyle = .overCurrentContext
                
                self.present(VCVisorFotos, animated: true, completion: nil)
                
                
            }
        }
    }
    
    func vuelveDeVCAlarma() {
        
        view.unblur()
        
        btn01Opciones.layer.removeAllAnimations()
        compruebaAlarmas()
    }
    func vuelveDeVCEstColAlar() {
        
    
        btn01Opciones.layer.removeAllAnimations()
        compruebaAlarmas()
    }
    func muestraSeleccionadosDesdeEstadistica(unFollowThingEnvio:UnFollowThing) {
        
        self.expandirContenedor(contenedor: self.scrollSecundaria, abrir: true, tamaño: 74)
        
        creaMatrizDeAnotacion(unaAnotacion: unFollowThingEnvio.anotaciones!, fecha: unFollowThingEnvio.fechaCreacionUnFT!)
        
        
        let anotacionesTotalNumero = unFollowThingActual.count
        let primeraAnotacion = Fechas.fechaCompletaDesde(date: unFollowThingActual.last!.fechaCreacionUnFT!)
        
      
        etiqueScroll02.text = "La primera vez fue hace \(primeraAnotacion) y desde entonces, se ha repetido \(anotacionesTotalNumero) veces."
        
        etiqueScroll02.textColor = .gray
        
        etiqueScroll02.isHidden = false
        btnCancelarScroll.isHidden = false
        
        etiquetaDiaVistaUno.isHidden = true
          
    }
//    MARK:- PROTOCOLO VCFRECUENTE
    
    func frecuenteSeleccionado(unFT:UnFollowThing!) {
        
        unFTNuevaAnotacion = unFT
        
        textFieldVistaUno.text = unFT.anotaciones!
        textFieldVistaUno.textColor = coloresAnotacion[Int(unFT.colorAnotacion)]
        
        if textFieldVistaUno.text != "" {
            estadoBotonesEntradaTexto(modo: 1)
        }
        tablaSecundaria.unblur()
    }
  
    func actualizaDesdeFrecuentes() {
        tablaSecundaria.unblur()
        recuperaDatos()
        tablaSecundaria.reloadData()
        ajustaSeparadorTabla()
        
    }
    func compruebaAlarmas(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [self] in
            
            if recuperaAlarmas() {
                
                btn01Opciones.iluminar()
            
            let pulse = CASpringAnimation(keyPath: "transform.scale")
                pulse.duration = 2.9
                pulse.fromValue = 1.0
                pulse.toValue = 1.12
                pulse.autoreverses = true
                pulse.repeatCount = .infinity
                pulse.initialVelocity = 3.5
                pulse.damping = 0.8
                btn01Opciones.layer.add(pulse, forKey: nil)

            }
            else {
                btn01Opciones.desiluminar()
              
            }
        }
    }

    @IBAction func tapDia(_ sender: Any) {
        flip()
        etiquetaDiaVistaUno.animadoVibracionMedio()
        if !desdeHace {
            desdeHace = true
            
        } else {
            desdeHace = false
        }
        UserDefaults.standard.set(desdeHace, forKey: "tapDia")
        tablaSecundaria.reloadData()
        ajustaSeparadorTabla()
        configuraCabecera()
    }

//    MARK:- CONTENDOR INFORMATIVO
    func estadoContendorInformativo(mostrar:Bool){
        
        expandirContenedor(contenedor: contendorInformativo, abrir: mostrar,tamaño:160)
        
//        let color1:UIColor =  UIColor(red:
//                                        128/255, green: 128/255, blue: 128/255, alpha: 1.0)
//        let color2:UIColor =  UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1.0)
        
        let color1Btn02 = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        let color2Btn02 = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
        
        btn02ContenedorInfo.grandienteVertical(color01: color1Btn02, color02: color2Btn02)
       
        btn01ContendorInfo.backgroundColor = UIColor(red:
                                                        128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        if mostrar {
            contendorInformativo.iluminar()
           
        } else {
            contendorInformativo.desiluminar()
           
        }
    }
//    MARK:- CONTENDOR ALARMA
    
    func estadoContenedorAlarma(mostrar:Bool){
        
        expandirContenedor(contenedor: contenedorAlarmasInfo, abrir: mostrar,tamaño: 100)
        
        if !mostrar {
            contenedorAlarmasInfo.desiluminar()
        }
        else {
            contenedorAlarmasInfo.iluminar()
        }
    }
//    MARK:- FUNCIONES COMUNES CONTENDORES INFORMATIVOS
   
    func crearImagenConTitulo (texto:String, texto02:String, imagen:UIImage) -> UIImage? {

           let image = imagen
           
           let viewToRender = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
           let imgView = UIImageView(frame: viewToRender.frame)
           imgView.image = image
           
           viewToRender.backgroundColor = .black
           
           imgView.contentMode = .scaleAspectFit
           
           viewToRender.addSubview(imgView)
       
           let alturaY = (viewToRender.frame.size.height/2) - (imgView.imageSizeAfterAspectFit.height/2) + 20
           
           let textImgView = UIImageView(frame: viewToRender.frame)
           
           textImgView.image = imageFrom(text: texto, size: viewToRender.frame.size, rect:  CGRect(x: 5, y: alturaY - etiquetaDiaVistaUno.frame.size.height - 20, width: etiquetaDiaVistaUno.frame.size.width, height: etiquetaDiaVistaUno.frame.size.height))
           viewToRender.addSubview(textImgView)
           
           let textImgView02 = UIImageView(frame: viewToRender.frame)
           textImgView02.image = imageFrom(text: texto02, size: viewToRender.frame.size, rect:  CGRect(x: 5, y: textImgView.frame.origin.y + textImgView.frame.size.height + 10, width: textImgView.frame.size.width, height: textImgView.frame.size.height))
           viewToRender.addSubview(textImgView02)
           
           UIGraphicsBeginImageContextWithOptions(viewToRender.frame.size, false, 0)
           viewToRender.layer.render(in: UIGraphicsGetCurrentContext()!)
           let finalImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           
           return finalImage
       }
       func imageFrom(text: String , size:CGSize, rect:CGRect) -> UIImage {

           let renderer = UIGraphicsImageRenderer(size: size)
           let img = renderer.image { ctx in
               let paragraphStyle = NSMutableParagraphStyle()
               paragraphStyle.alignment = .left

               let attrs = [NSAttributedString.Key.font: fuenteVisorTitulo, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyle]

               text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attrs as [NSAttributedString.Key : Any], context: nil)

           }
           return img
       }
//    MARK:- ACCIONES
    @objc func longPressFrecuente(gesture: UILongPressGestureRecognizer) {
      
        if gesture.state == UIGestureRecognizer.State.began {
        
            botonFrecuentes.animadoVibracionMedio()
            
            if textoPreditivo {
                
                textoPreditivo = false
                botonFrecuentes.backgroundColor = .clear
                botonFrecuentes.tintColor = .gray
                
            }
            else {
              
                    
                    if followThingDB.color != 8 {
                        botonFrecuentes.backgroundColor = coloresCategoria[Int(followThingDB.color)]
                        botonFrecuentes.tintColor = .white
                    }
                    else {
                    botonFrecuentes.backgroundColor = azulBotonEditar
                    botonFrecuentes.tintColor = .white
                    }
                
             
                textoPreditivo = true
            }
            UserDefaults.standard.setValue(textoPreditivo, forKey: "textoPreditivo")
        }
    }
    @IBAction func btnCancelarScroll(_ sender: Any) {
        
      cancelarScroll()
    }
    func cancelarScroll(){
        
        if btnCancelarScroll.isHidden == false {
            
            btnCancelarCancel.isHidden = true
            etiquetaDiaVistaUno.isHidden = false
            etiqueScroll02.isHidden = true
            btnCancelarScroll.isHidden = true
            
            recuperaDatos()
            DispatchQueue.main.async {
                self.tablaSecundaria.reloadData()
                self.ajustaSeparadorTabla()
            }
        }
    }
    @IBAction func btn02ContenedorInfo(_ sender: Any) {
        
        guardarUnaEdicion()
        restableceEntradaTexto()
    }
    @IBAction func btn01ContenedorInfo(_ sender: Any) {
        
        guardaEdicionMultiple()
        restableceEntradaTexto()
       
        
    }
    @IBAction func tapAlarmas(_ sender: Any) {
        
        view.blur()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcAlarmas = storyboard.instantiateViewController(withIdentifier: "VCAlarmas") as! VCAlarmas
        
        vcAlarmas.modalPresentationStyle = .custom
        vcAlarmas.transitioningDelegate = self
        
        vcAlarmas.delegado = self
        vcAlarmas.followThing = followThingDB
        vcAlarmas.unFollowThing = unFollowThingActual
        
        self.present(vcAlarmas, animated: true, completion: nil)
    }
    @IBAction func btn01Opcciones(_ sender: Any) {
    
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcAlarmas = storyboard.instantiateViewController(withIdentifier: "VCAlarmas") as! VCAlarmas
        
        vcAlarmas.modalPresentationStyle = .custom
        vcAlarmas.transitioningDelegate = self
        
        vcAlarmas.delegado = self
        vcAlarmas.followThing = followThingDB
        vcAlarmas.unFollowThing = unFollowThingActual
        
        self.present(vcAlarmas, animated: true, completion: nil)
    }
    
//    ORDENAR
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
             return SetSizePresentationController(presentedViewController: presented, presenting: presenting)
       
    }
//    ORDENAR
    func guardaEdicionMultiple(){
       
        let anotacionBuscada = unFTAgrupadas[0].anotaciones!
        
        if recuperaAlarmas() {
            modificaAlarmaLocalizda(unaAnotacion: anotacionesEditar)
        }
        
        let fecha = Date()
        
        for busqueda in 1...unFTRespaldo.count {
            
            if unFTRespaldo[busqueda-1].anotaciones != nil {
                if unFTRespaldo[busqueda-1].anotaciones! == anotacionBuscada {
                    unFTRespaldo[busqueda-1].anotaciones = anotacionesEditar
                    unFTRespaldo[busqueda-1].fechaUltimaModificacion = fecha
                }
            }
        }
        if textFieldVistaUno.text != "" {
            actualizarDatos()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            
            self.volverUnFTOriginal()
          
        }
       
        
    }
    func volverUnFTOriginal(){
        recuperaDatos()
        
        tablaSecundaria.beginUpdates()
        let range = NSMakeRange(0, self.tablaSecundaria.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tablaSecundaria.reloadSections(sections as IndexSet, with: .automatic)
        tablaSecundaria.reloadData()
        tablaSecundaria.endUpdates()
        
        tablaSecundaria.reloadData()
    }
    //    MARK:- ANIMACIONES
    
    func flip() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
   

        UIView.transition(with: vistaUnoScroll, duration: 0.5, options: transitionOptions, animations: {
//            self.firstView.isHidden = true
        })
//
//        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
//            self.secondView.isHidden = false
//        })
    }
   
    //    MARK:- FUNCION ENTRE CONTROLADORES
   
    @objc func recibeNotificacionDeActualizacion(){
    
     recuperaDatos()
        tablaSecundaria.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        segue.destination.popoverPresentationController?.delegate = self
        
        if segue.identifier == "SecToCamara" {
            
            let VCCamara: VCCamara = segue.destination as! VCCamara
            VCCamara.unFTDB = unFollowThingActual
            VCCamara.followThingDesdeSec = followThingDB
        
        }
    }
    func actualizarDatosVisorUnico() {
        actualizarDatos()
        tablaSecundaria.reloadData()
        ajustaSeparadorTabla()
    }
    //    MARK:- POPOVER
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    @IBAction func accionPopoverFrecuentes(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
               generator.impactOccurred()
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popVC = storyboard.instantiateViewController(withIdentifier: "VCBotonMasFrecuente") as! VCBotonMasFrecuente
        
        popVC.delegate = self
        popVC.unFTBDRecibido = unFollowThingActual
        popVC.followThingRecibido = followThingDB
        
        popVC.modalPresentationStyle = .popover
        popVC.medidaAnchoPopover = UIScreen.main.bounds.width/1.5
        
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.contenedorEntradaTexto
        popOverVC?.sourceRect = CGRect(x: self.contenedorEntradaTexto.bounds.midX, y: self.contenedorEntradaTexto.bounds.minY - 8, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width:396.41832724, height: 245)
        popOverVC?.permittedArrowDirections = .down
        self.present(popVC, animated: true)
        popVC.popoverPresentationController!.delegate = self
        
                
        tablaSecundaria.blur()
    }
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        tablaSecundaria.unblur()
    }
    func accionVisualPulsarBoton(unBoton:UIButton){
        
        unBoton.superRebotar()
        let generator = UIImpactFeedbackGenerator(style: .medium)
              generator.impactOccurred()
    }
    //    MARK:- FUNCIONES TABLA
    func tableCell(clickFotoCell tableCell: UITableViewCell) {
        if let rowIndexPath = tablaSecundaria.indexPath(for: tableCell) {
            
            let cell = tablaSecundaria.dequeueReusableCell(withIdentifier: "CellSecundariaFotos", for: rowIndexPath) as! TableViewCellSecundariaFotos
            accionVisualPulsarBoton(unBoton: cell.boton1CellFotos)
        }
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
        return unFollowThingActual.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               
        let unFTIndex = unFollowThingActual[indexPath.row]
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDB.fechaCreacion!, end: unFTIndex.fechaCreacionUnFT!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDB.fechaCreacion!, end: Date()) - dia
        
        if (unFTIndex.foto != nil) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSecundariaFotos", for: indexPath) as! TableViewCellSecundariaFotos
            
          
            let clickGestoBoton3Fotos = UITapGestureRecognizer(target: self, action: #selector(VCSecundaria.clickBoton3CellFoto(_:)))
            
            cell.boton3CellFotos.tag = indexPath.row
            cell.boton3CellFotos.addGestureRecognizer(clickGestoBoton3Fotos)
            
            let clickGestoBoton2Fotos = UITapGestureRecognizer(target: self, action: #selector(VCSecundaria.clickBoton2CellFoto(_:)))
            
            cell.boton2CellFotos.tag = indexPath.row
            cell.boton2CellFotos.addGestureRecognizer(clickGestoBoton2Fotos)
            
            let clickGestoBoton1Fotos = UITapGestureRecognizer(target: self, action: #selector(VCSecundaria.clickBoton1CellFoto(_:)))
            
            cell.boton1CellFotos.tag = indexPath.row
            cell.boton1CellFotos.addGestureRecognizer(clickGestoBoton1Fotos)
            
            
            let clickGestoFoto = UITapGestureRecognizer(target: self, action: #selector(VCSecundaria.clickIconoFoto(_:)))
            
            cell.iconoFoto.isUserInteractionEnabled = true
            cell.iconoFoto.tag = indexPath.row
            cell.iconoFoto.addGestureRecognizer(clickGestoFoto)
            cell.delegado = self
            cell.iconoFoto.isHidden = false
            cell.iconoFoto.image = UIImage(data: unFTIndex.foto! as Data)
            
            let horaAnotacion:String = Fechas.dateFormatter.string(from: unFTIndex.fechaCreacionUnFT!)
           
            cell.etiqDiaGuardado.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false)
            cell.etiqHoraGuardada.text = horaAnotacion
          
            if editandoAnotacion {
                cell.etiqContenidoCelda.text = anotacionesEditar
            }
            else {
            cell.etiqContenidoCelda.text = unFTIndex.anotaciones
            }
            
            return cell
        }
            
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellSecundaria", for: indexPath) as! TableViewCellSecundarfia
            
            let horaAnotacion:String = Fechas.dateFormatter.string(from: unFTIndex.fechaCreacionUnFT!)
            
            cell.etiqDiaGuardado.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia:false)
            
            cell.etiqHoraGuardada.text = horaAnotacion
            cell.etiqContenidoCelda.text = unFTIndex.anotaciones

            if unFTIndex.anotaciones == nil || unFTIndex.anotaciones == "" {
                cell.monitorActividad.startAnimating()
                cell.monitorActividad.isHidden = false
            }
            else {
                cell.monitorActividad.stopAnimating()
                cell.monitorActividad.isHidden = true
            }
            
            cell.etiqContenidoCelda.textColor = coloresAnotacion[
                Int(unFTIndex.colorAnotacion)]
            
            var stringAnotacion:String = unFTIndex.anotaciones!
            
            cell.contentView.borders(for: [.all], width: 0.0, color: .clear)
            cell.contentView.backgroundColor = .white
          
            if editandoAnotacion {
                stringAnotacion = anotacionesEditar
               
            }
            if unFTIndex.colorAnotacion == 0 {
                cell.etiqContenidoCelda.font = fuenteTextoAnotacionesCell
                let attrString = NSAttributedString(
                    string: stringAnotacion,
                    attributes: [
                        NSAttributedString.Key.strokeColor: UIColor.black,
                        NSAttributedString.Key.foregroundColor: coloresAnotacion[
                            Int(unFTIndex.colorAnotacion)],
                        NSAttributedString.Key.strokeWidth: 0.0,
                    
                    ]
                )
                cell.etiqContenidoCelda.attributedText = attrString
                
            } else {
                cell.etiqContenidoCelda.font = fuenteTextoAnotacionesCellNegrita
             
                
                let attrString = NSAttributedString(
                    string: stringAnotacion,
                    attributes: [
                        NSAttributedString.Key.strokeColor: UIColor.darkGray,
                        NSAttributedString.Key.foregroundColor: coloresAnotacion[
                            Int(unFTIndex.colorAnotacion)],
                        NSAttributedString.Key.strokeWidth: -2.0,
                       
                    ]
                )
                cell.etiqContenidoCelda.attributedText = attrString
            }
            return cell
        }
    }
    func sombreTexto(texto:String,color:UIColor,fuente:UIFont)->NSAttributedString {
        
        let attrString = NSAttributedString(
            string: texto,
            attributes: [
                NSAttributedString.Key.strokeColor: color,
//                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeWidth: -2.0,
//                NSAttributedString.Key.font: fuente
            ]
        )
        return attrString
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if insertarNuevoElemento {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                
                let animation = Animator.AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.25)
                
                let animator = Animator(animation: animation)
                animator.animate(cell: cell, at: indexPath, in: tableView)
                
                
            }
            self.insertarNuevoElemento = false
        }
//        cell.contentView.borders(for: [.bottom], width: 0.2, color: .lightGray)
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSecundariaFotos", for: indexPath) as! TableViewCellSecundariaFotos
        
        if editandoAnotacion {
         
//
//            if indexPath == indiceEditando {
//
//                cell.contentView.borders(for: [.all], width: 0.5, color: .lightGray)
//                let color1Btn02 = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
//                let color2Btn02 = UIColor(red: 253/255, green: 253/255, blue: 253/255, alpha: 1.0)
//
//                cell.contentView.grandienteVertical(color01: color1Btn02, color02: color2Btn02)
//
//            }
//            else {
//                cell.contentView.backgroundColor = .white
//            }
        }
        
        cell.contentView.backgroundColor = .white
         
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let botonBorrar = UIContextualAction(style: .destructive, title: "Borrar") { [self] (action, view, handler) in
           
            
            if unFollowThingActual.count > 0 {
                if unFollowThingActual[indexPath.row].foto == nil {
                    let titulo = self.unFollowThingActual[indexPath.row].anotaciones!
                    
                    if self.recuperaAlarmas() {
                        if self.existenMasAlarmas(titulo: titulo) {
                            Alarmas.borrarAlarmaDB(tituloAlarma:titulo, alarmaFT: todasAlarmas)
                        }
                    }
                    self.borrarUnaAnotacion(unaAnotacion: indexPath)
                    self.estableceAlarmas()
                }
                else {
                    self.borrarUnaAnotacion(unaAnotacion: indexPath)
                }
                
            }
        }
     
        let botonEditar = UIContextualAction(style: .normal, title: "Editar") { (action, view, handler) in
            
            self.editarAnotacion(unaAnotacion: indexPath)
            self.indiceEditando = indexPath
            self.textFieldVistaUno.becomeFirstResponder()
         
        }
        
        botonEditar.backgroundColor = azulBotonEditar
        botonBorrar.backgroundColor = rojoBotonEditar
        
        if unFollowThingActual[indexPath.row].foto == nil {
            
            let configuration = UISwipeActionsConfiguration(actions: [botonBorrar,botonEditar])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
            
        }
        else {
            let configuration = UISwipeActionsConfiguration(actions: [botonBorrar])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSecundaria", for: indexPath) as! TableViewCellSecundarfia
   
        let index = unFollowThingActual[indexPath.row]
        
        if index.foto == nil  {
            
            if index.anotaciones == nil || index.anotaciones == "" {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VCAlarmaEstadisticaRepetir = storyboard.instantiateViewController(identifier: "VCAlarmaEstadisticaColor") as! VCAlarmaEstadisticaColor
            
            VCAlarmaEstadisticaRepetir.delegado = self
            VCAlarmaEstadisticaRepetir.unFollowThing = unFollowThingActual
            VCAlarmaEstadisticaRepetir.followThing = followThingDB
            VCAlarmaEstadisticaRepetir.titulo = index.anotaciones!
            
            VCAlarmaEstadisticaRepetir.modalPresentationStyle = .formSheet
            self.present(VCAlarmaEstadisticaRepetir, animated: true, completion: nil)
            
        }
    }
   
//   MARK:- FUNCION BOTONES EN CELL FOTOS
    @IBAction func clickBoton1CellFoto(_ sender:AnyObject) {
        
        let indexUnFT = unFollowThingActual[sender.view.tag]
        
        if indexUnFT.foto != nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VCCollection = storyboard.instantiateViewController(identifier: "VCCollectionViewFotos") as! VCCollectionViewFotos
            
            VCCollection.delegado = self
            VCCollection.iniciaDesdeVisorFotos = false
            VCCollection.unFollowThingRecibido = unFollowThingActual
            VCCollection.fechaCreacionUnFTRecibido = indexUnFT.fechaCreacionUnFT!
            VCCollection.followThingRecibido = followThingDB
            VCCollection.modoTeatro = false
            VCCollection.modalPresentationStyle = .formSheet
            self.present(VCCollection, animated: true, completion: nil)
            
            
        }
    }
    @IBAction func clickBoton2CellFoto(_ sender:AnyObject) {
        
        let indexUnFT = unFollowThingActual[sender.view.tag]
        
        unFollowThingObjetivo = unFollowThingActual[sender.view.tag]
        
        if indexUnFT.foto != nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let VCCollection = storyboard.instantiateViewController(identifier: "VCCollectionViewFotos") as! VCCollectionViewFotos
            
            VCCollection.delegado = self
            VCCollection.iniciaDesdeVisorFotos = false
            VCCollection.unFollowThingRecibido = unFollowThingActual
            VCCollection.followThingRecibido = followThingDB
            VCCollection.fechaCreacionUnFTRecibido = indexUnFT.fechaCreacionUnFT!
            
            VCCollection.modoTeatro = true
            VCCollection.modalPresentationStyle = .formSheet
            self.present(VCCollection, animated: true, completion: nil)
        }
    }
    @IBAction func clickBoton3CellFoto(_ sender:AnyObject) {
       
        let indexUnFT = unFollowThingActual[sender.view.tag]


        let compartir = UIActivityViewController(activityItems: [UIImage(data: indexUnFT.foto! as Data)!], applicationActivities: nil)
        
        compartir.popoverPresentationController?.sourceView = self.view
        self.present(compartir, animated: true, completion: nil)
        
        
    }
   
    @IBAction func clickIconoFoto(_ sender:AnyObject){
        print("ViewController tap() Clicked Item: \(sender.view.tag)")
        
        let indexUnFT = unFollowThingActual[sender.view.tag]
        
         if indexUnFT.foto != nil {
                       
                       recuperaDatos()
                       
                       let storyboard = UIStoryboard(name: "Main", bundle: nil)

            let VCVisorFotos  = storyboard.instantiateViewController(identifier: "VCVisorFotos") as! VCVisorFotos
            
            VCVisorFotos.followThing = followThingDB
            VCVisorFotos.unFollowThings = unFollowThingActual
            VCVisorFotos.unFollowThingObjetivo = indexUnFT
            
            VCVisorFotos.modalTransitionStyle = .crossDissolve
            VCVisorFotos.modalPresentationStyle = .overCurrentContext
            
            self.present(VCVisorFotos, animated: true, completion: nil)
            
            
            
                   }
        
    }
    
    
    // MARK:- FUNCIONES FETCHEDREQUEST
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tablaSecundaria.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tablaSecundaria.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tablaSecundaria.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tablaSecundaria.deleteRows(at: [indexPath!], with: .fade)
        case.update:
            self.tablaSecundaria.reloadRows(at: [indexPath!], with: .automatic)
        default:
            self.tablaSecundaria.reloadData()
        }
        
        self.unFollowThingActual = controller.fetchedObjects as! [UnFollowThing]
        ajustaSeparadorTabla()
    }
    
    //    MARK:- FUNCIONES SCROLLVIEW
    
    func cambioPaginaScrollView(page : Int){
        
        let scrollPoint = CGPoint(x :0 , y: Int(scrollSecundaria.frame.size.height)*page)
        scrollSecundaria.setContentOffset(scrollPoint, animated: true)
        contolPagina.currentPage = Int(page)
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollSecundaria.frame.size.width)
        contolPagina.currentPage = Int(pageNumber)
        
        textFieldVistaUno.resignFirstResponder()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if scrollView == tablaSecundaria {
            if !editandoAnotacion {
                if targetContentOffset.pointee.y < scrollView.contentOffset.y {
                  
                    expandirContenedor(contenedor: scrollSecundaria, abrir: true,tamaño: 74)
                  
                } else {
                    expandirContenedor(contenedor: scrollSecundaria, abrir: false,tamaño: 0)
                }
            }
        }
    }
   
    func guardarUnaEdicion(){
        
        unFTRespaldo[indiceEditando.row].anotaciones = anotacionesEditar
        unFTRespaldo[indiceEditando.row].fechaUltimaModificacion = Date()
        if textFieldVistaUno.text == anotacionesEditar {
        actualizarDatos()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                
                self.volverUnFTOriginal()
              
            }
        }
        
    }
    
    //    MARK:- FUNCIONES TEXTFIELD
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
//        if editandoAnotacion {
//            editandoAnotacion = false
//            estadoContendorInformativo(mostrar: false)
//            volverUnFTOriginal()
//            
//           dismissKeyboard()
//           
//        }
        estadoBotonesEntradaTexto(modo: 0)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        cancelarScroll()
        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
        
        if updatedText != "" {
            
            if !editandoAnotacion {
                
                estadoBotonesEntradaTexto(modo: 1)
                
            }
            else {
                //                AQUÍ DEBERÍA ABRIR BOTONES
                tablaSecundaria.reloadData()
            }
        }
        else {
            estadoBotonesEntradaTexto(modo: 0)
        }
        
        anotacionesEditar = updatedText
        if unFollowThingActual.count > 0 {
            determinaFrecuentes(unFTBDRecibido: unFollowThingActual
            )
        }
        
        if textoPreditivo && unFollowThingActual.count > 0 {
        
        return !autoCompleteText( in : textField, using: string, suggestionsArray: anotacionesFrecuentes)
        }
        
        return true
    }
   
    
    func determinaFrecuentes(unFTBDRecibido:[UnFollowThing]){
        
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
        if anotacionesFrecuentes.count > 0 {
        for busqueda in 1...anotacionesFrecuentes.count {
       
            for busquedaAnotacion in 1...unFTBDRecibido.count {
                
                if unFTBDRecibido[busquedaAnotacion-1].anotaciones == anotacionesFrecuentes[busqueda-1] {
                    
                    unFollowThingTop.append(unFTBDRecibido[busquedaAnotacion-1])
                    break
                }
            }
        }
       
        }
    }
    func autoCompleteText( in textField: UITextField, using string: String, suggestionsArray: [String]) -> Bool {
      
       
        if !string.isEmpty,
                let selectedTextRange = textField.selectedTextRange,
                selectedTextRange.end == textField.endOfDocument,
                let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: selectedTextRange.start),
                let text = textField.text( in : prefixRange) {
                let prefix = text + string
                let matches = suggestionsArray.filter {
                    $0.hasPrefix(prefix)
                }
                if (matches.count > 0) {
                    textField.text = matches[0]
                    if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.count) {
                        textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)
                        return true
                    }
                }
            }
            return false
        }

    func estadoBotonesEntradaTexto(modo:Int){
      
         
        switch modo {
        case 0:
//            NO HAY TEXTO
           
            self.btn03EntradaTexto.isHidden = true
            self.btn02EntradaTexto.isHidden = true
            self.botonFrecuentes.isHidden = false
           
//            UIView.animate(withDuration: 0.25, animations: {
//
//                self.view.updateConstraintsIfNeeded()
//            })
          
        case 1:
//            HAY TEXTO SIN TECLADO
            self.btn02EntradaTexto.isHidden = true
            self.botonFrecuentes.isHidden = true
            self.btn03EntradaTexto.isHidden = false
            
            btn03EntradaTexto.superRebotar()
            
//            UIView.animate(withDuration: 0.25, animations: {
//
//                self.view.updateConstraintsIfNeeded()
//
//            })
        case 2:
//             EDITAR
            self.botonFrecuentes.isHidden = true
            self.btn03EntradaTexto.isHidden = true
            self.btn02EntradaTexto.isHidden = false
            
//            UIView.animate(withDuration: 0.25, animations: {
//
//
//                self.view.updateConstraintsIfNeeded()
//
//            })
            
        default:
            break
        }
      
       
    }
    func restableceEntradaTexto(){
       
        estadoBotonesEntradaTexto(modo: 0)
        textFieldVistaUno.text = ""
        expandirContenedor(contenedor: contenedorAlarmasInfo, abrir: false,tamaño: 0)
        textFieldVistaUno.resignFirstResponder()
        recuperaDatos()
        editandoAnotacion = false
        tablaSecundaria.reloadData()
        estadoContendorInformativo(mostrar: false)
    }
    @IBAction func btn02EntradaTexto(_ sender: Any) {
          restableceEntradaTexto()
        
    }
    @IBAction func btn03EntradaTexto(_ sender: Any) {
  
        if textFieldVistaUno.text != "" {
            
            if editandoAnotacion {
                if unFTAgrupadas.count > 1 {
                    contendorInformativo.superRebotar()
                }
                if unFTAgrupadas.count == 1 {
                    guardaEdicionMultiple()
                }
            }
            else
            {
                
                let unFollowDB = UnFollowDB.init()
               
                var color:Int16 = 0
                if unFTNuevaAnotacion != nil {
                    color = unFTNuevaAnotacion.colorAnotacion
                }
                
                if unFollowDB.guardarNuevoUnFT(anotacion: textFieldVistaUno.text!, color: color, followThingDB: followThingDB) {
                    
                    recuperaDatos()
                    insertarNuevoElemento = true
                    
                    tablaSecundaria.reloadData()
                    restableceEntradaTexto()
                }
                

         
                if unFollowThingActual.count > 0 {  tablaSecundaria.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)}
                textFieldVistaUno.text = ""
                textFieldVistaUno.resignFirstResponder()
            }
        }
        else {
            if tablaSecundaria.isEditing {
                
                unFollowThingActual[indiceEditando.row].anotaciones = nil
                actualizarDatos()
                tablaSecundaria.reloadData()
                editandoAnotacion = false
                textFieldVistaUno.text = ""
                textFieldVistaUno.resignFirstResponder()
            }
        }
        if textFieldVistaUno.text == "" {
            estadoBotonesEntradaTexto(modo: 0)}
    }
    @objc override func dismissKeyboard() {
//                view.endEditing(true)
    }
    //    MARK:- FUNCIONES DE TECLADO
    @objc func tecladoAparece(notification: Notification) {
              
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardHeight = keyboardSize?.height
        
        self.contOpcionesEntradaTexto.constant = keyboardHeight! - self.contendorOpciones.frame.height
         
        UIView.animate(withDuration: 0.5){
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    @objc func tecladoDesaparece() {
        
       
       
        self.contOpcionesEntradaTexto.constant =  0 // or change according to your logic

        if textFieldVistaUno.text == "" {
            estadoBotonesEntradaTexto(modo: 0)
        }
        
              UIView.animate(withDuration: 0.5){

                 self.view.layoutIfNeeded()

              }
    }
    //    MARK:- SINCRONIZAR
   
    @objc private func sincronizar(){
        
        
        
        let conmutador01 = ConmutadorEntreRedYLocal.init()
        
         conmutador01.eliminaRepetidosUnFollowThing(unFT: unFollowThingActual)
    
      
        let sincronizacion = UserDefaults.standard.bool(forKey: "sincronizacion")
        
        if sincronizacion {
            let conmutador = ConmutadorEntreRedYLocal.init()
            
            let serialQueue = DispatchQueue(label: "com.queueFollowThing.serial")
            
            serialQueue.sync {
                print("Task 5")
                
                conmutador.descargaTodoUnFTdeFirebase(idFollowThing: self.followThingDB.id_FollowThing!.uuidString)
                
                print("5 is on main thread: \(Thread.isMainThread)")
            }
            
            serialQueue.sync { [self] in
                print("Task 6")
                
                conmutador.descargaFotosdeFirebase(idFollowThing: followThingDB.id_FollowThing!.uuidString)
                
                print("6 is on main thread: \(Thread.isMainThread)")
                
            }
            serialQueue.sync {
                
                print("Task 7 ")
                
                conmutador.lanzadorCargaUNFTFirebase()
                
                print("7 is on main thread: \(Thread.isMainThread)")
                
            }
            serialQueue.sync {
                
                print("Task 8 : Sube fotos a Firebase ")
                
                conmutador.lanzadorFotoFT()
                
                print("8 is on main thread: \(Thread.isMainThread)")
                
            }
//            serialQueue.sync {
//                print("Task 9 : Eliminación duplicados")
//
//               conmutador.eliminaRepetidosUnFollowThing(unFT: unFollowThingActual)
//
//                print("9 is on main thread: \(Thread.isMainThread)")
//            }
        }
        else {
            refreshControl.endRefreshing()
        }
    }
//    private func sincronizarSubida(){
//        let sincronizacion = UserDefaults.standard.bool(forKey: "sincronizacion")
//
//        if sincronizacion {
//            let conmutador = ConmutadorEntreRedYLocal.init()
//
//            let serialQueue = DispatchQueue(label: "com.queueFollowThing.serial")
//
//            serialQueue.sync {
//                print("Task 8")
//
//                conmutador.lanzadorCargaUNFTFirebase()
//
//                print("8 is on main thread: \(Thread.isMainThread)")
//            }
//        }
//    }
    //    MARK:- ALARMA
    func borrarAlarmasUnFT(){
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { [self] (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier.contains("\(followThingDB.titulo!)") {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    @objc func estableceAlarmas() {
        
        
        DispatchQueue.background(delay: 0.3, completion:{ [self] in
        
        borrarAlarmasUnFT()
        
        var titulo:String = followThingDB.titulo!
       
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
         
            fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingDB.id_FollowThing! as CVarArg)
                      
            do {
                let resultado = try conexion().fetch(fetch)
                let followThingDB = resultado.first
                todasAlarmas = (followThingDB?.alarmaUnFTSet?.sortedArray(using: [NSSortDescriptor(key: "tituloAlarma", ascending: false)])) as! [AlarmasUnFT]
                
                titulo = followThingDB!.titulo!
               
            } catch let error as NSError {
                print("error cargar DB",error)
            }
            
            if todasAlarmas.count > 0 {
                
                for alarma in 1...todasAlarmas.count {
                    
                    lanzaNotificacion(titulo: titulo, subTitulo: todasAlarmas[alarma-1].tituloAlarma!, cuerpo: "Recuerda incluir esta anotación", fecha: Alarmas.obtenFechaComponenteAlarma(fecha: todasAlarmas[alarma-1].fechaAlarma!))
            }
           
            }
        })
    }
    func lanzaNotificacion(titulo:String,subTitulo:String,cuerpo:String, fecha:DateComponents){
        
        
        let solicitud =  Alarmas.lanzaNotificacionLocal(titulo: titulo, subTitulo: subTitulo, cuerpo: cuerpo, fecha: fecha)
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.add(solicitud, withCompletionHandler: {(error) in
            if let error = error {
                print("error al lanzar notificacion: ",error)
            }
        })
        
    }
    func compruebaSiExisteNotificacionIncluida(){
        
       todasAlarmas = Alarmas.leerAlarmaDB(followThing: followThingDB, unFollowThing: unFollowThingActual)
        
//        if Alarmas.compruebaAlarmaIncluida(unFT: unFollowThingActual, alarmaFT: todasAlarmas) {
//            
//            
//            
//        }
    }
    //    MARK:- FUNCIONES COREDATA
    func borrarUnFollowThing(unFT:UnFollowThing){
        var conexion:NSManagedObjectContext
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        conexion = delegate.persistentContainer.viewContext
            conexion.delete(unFT)
       
        do {
            try conexion.save()
            
        } catch let error as NSError {
            print("Error al borrar comentario : \(error.localizedDescription)")
        }
       
    }
    func conexion()->NSManagedObjectContext{
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    func borrarUnaAnotacion(unaAnotacion:IndexPath) {
        
        conexion().delete(unFollowThingActual[unaAnotacion.row])
        unFollowThingActual.remove(at:unaAnotacion.row)
        
        do {
            try conexion().save()
            
            tablaSecundaria.deleteRows(at: [unaAnotacion], with: .fade)
            
        } catch let error as NSError {
            print("Error al borrar comentario : \(error.localizedDescription)")
        }
        
    }
    func modificaAlarmaLocalizda(unaAnotacion:String) {
        
        let busquedaAlarma = unFTAgrupadas[0].anotaciones!
        
        for busqueda in 1...todasAlarmas.count {
        
            if busquedaAlarma == todasAlarmas[busqueda-1].tituloAlarma! {
                
                todasAlarmas[busqueda-1].tituloAlarma = unaAnotacion
            }
        }
    }
   
    func borrarAlarma(tituloAlarma:String) {
        
        for alarma in 1...todasAlarmas.count {
            
            if todasAlarmas[alarma-1].tituloAlarma == tituloAlarma {
                
                 conexion().delete(todasAlarmas[alarma-1])

            }
        }
        do {
            try conexion().save()
        } catch let error as NSError {
            print("Error al borrar una alarma: ",error)
        }
    }
    func recuperaAlarmas()->Bool{
        
        var existe:Bool = false
        
        let funcionesAlarmaDB = AlarmaDB.init()
        
        todasAlarmas = funcionesAlarmaDB.leerAlarmaDB(followThing: followThingDB, unFollowThing: unFollowThingActual)
        todasAlarmas = funcionesAlarmaDB.compruebaFechaExcedida(alarmas: todasAlarmas, followThing: followThingDB, unFollowThing: unFollowThingActual)
        todasAlarmas = funcionesAlarmaDB.compruebaAlarmaIncluida(unFT: unFollowThingActual, alarmaFT: todasAlarmas, followThing: followThingDB)
        
        if todasAlarmas.count > 0 {
            existe = true
        }
        
        return existe
    }
    func editarAnotacion(unaAnotacion:IndexPath){
          
        self.tablaSecundaria.scrollToRow(at: IndexPath(row: unaAnotacion.row, section: 0), at: .top, animated: true)
        
        if unFollowThingActual[unaAnotacion.row].anotaciones != nil {
            
            self.textFieldVistaUno.text = self.unFollowThingActual[unaAnotacion.row].anotaciones!
            creaMatrizDeAnotacion(unaAnotacion: unFollowThingActual[unaAnotacion.row].anotaciones!,fecha: unFollowThingActual[unaAnotacion.row].fechaCreacionUnFT!)
            
        }
        else {
            textFieldVistaUno.text = ""
        }
        
        editandoAnotacion = true
        estadoBotonesEntradaTexto(modo: 2)
        estadoContendorInformativo(mostrar: true)
        expandirContenedor(contenedor: scrollSecundaria, abrir: false,tamaño: 0)
        
      
     
    }
    func existenMasAlarmas(titulo:String)->Bool {
        
        var existe:Bool = false
        
        if unFTAgrupadas.count > 0 {
            unFTAgrupadas.removeAll()
        }
        
        for busqueda in 1...unFollowThingActual.count {
            
            if unFollowThingActual[busqueda-1].anotaciones == titulo {
                existe = true
            }
            
        }
        return existe
    }
    func creaMatrizDeAnotacion(unaAnotacion:String,fecha:Date){
        
        unFTRespaldo = unFollowThingActual
        unFollowThingActual.removeAll()
        
        anotacionesEditar = unaAnotacion
        
        unFTAgrupadas.removeAll()
    
        if unFTRespaldo.count > 0 {
            for busqueda in 1...unFTRespaldo.count {
                if unFTRespaldo[busqueda-1].anotaciones == unaAnotacion {
                    unFTAgrupadas.append(unFTRespaldo[busqueda-1])
                    unFollowThingActual.append(unFTRespaldo[busqueda-1])
                   
                }
            }
        }
        
        for buscaEdicionSeleccionada in 1...unFollowThingActual.count {
            
            if unFollowThingActual[buscaEdicionSeleccionada-1].fechaCreacionUnFT == fecha {
                indiceEditarSeleccionado = buscaEdicionSeleccionada-1
               
            }
        }
        
        tablaSecundaria.beginUpdates()
        let range = NSMakeRange(0, self.tablaSecundaria.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tablaSecundaria.reloadSections(sections as IndexSet, with: .middle)
        tablaSecundaria.endUpdates()
        
       
        etiquetaInfoVCSec.text = textFieldVistaUno.text!
        
        tablaSecundaria.reloadData()
        
        tablaSecundaria.scrollToRow(at: IndexPath(row: indiceEditarSeleccionado, section: 0), at: .middle, animated: true)
        
        
    }
  

    func actualizarDatos() {
        
        do {
            try conexion().save()
        } catch let error as NSError {
            print("Error al guardar:",error)
        }
    }
    
    func guardaAnotacion(unaAnotacion:String){
        
            let contexto = conexion()
            let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
            
            fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingDB.id_FollowThing! as CVarArg)
            
            do {
                let resultado = try conexion().fetch(fetch)
                followThingDB = resultado.first
                followThingDB.fechaUltimaEntrada = Date()
                
            } catch let error as NSError {
                print("error",error)
            }
            
            let entidadUnFollowThing = NSEntityDescription.insertNewObject(forEntityName: "UnFollowThing", into: contexto) as! UnFollowThing
            
            entidadUnFollowThing.anotaciones = unaAnotacion
            entidadUnFollowThing.fechaCreacionUnFT = Date()
            
            followThingDB.fechaUltimaEntrada = Date()
            followThingDB.mutableSetValue(forKey: "unFollowThingSet").add(entidadUnFollowThing)
            
            do {
                try contexto.save()
                insertarNuevoElemento = true
            } catch let error as NSError {
                print("no guardo anotación :", error)
            }
            self.recuperaDatos()
            self.tablaSecundaria.reloadData()
        
    }
    func guardaAnotacionNueva(unFTNuevo:UnFollowThing){
        let contexto = conexion()
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingDB.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThingDB = resultado.first
            followThingDB.fechaUltimaEntrada = Date()
            
        } catch let error as NSError {
            print("error",error)
        }
        
        let entidadUnFollowThing = NSEntityDescription.insertNewObject(forEntityName: "UnFollowThing", into: contexto) as! UnFollowThing
        
        entidadUnFollowThing.anotaciones = unFTNuevo.anotaciones!
       entidadUnFollowThing.colorAnotacion = unFTNuevo.colorAnotacion 
        entidadUnFollowThing.fechaCreacionUnFT = Date()
        
        followThingDB.fechaUltimaEntrada = Date()
        followThingDB.mutableSetValue(forKey: "unFollowThingSet").add(entidadUnFollowThing)
        
        do {
            try contexto.save()
            insertarNuevoElemento = true
        } catch let error as NSError {
            print("no guardo anotación :", error)
        }
        self.recuperaDatos()
        self.tablaSecundaria.reloadData()
    }
    
    func recuperaDatos(){
        
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThingDB.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThingDB = resultado.first
            unFollowThingActual = (followThingDB?.unFollowThingSet?.sortedArray(using: [NSSortDescriptor(key: "fechaCreacionUnFT", ascending: false)])) as! [UnFollowThing]
          
        } catch let error as NSError {
            print("error",error)
        }
    }
    func recuperaDatos2() {
        
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<UnFollowThing> = UnFollowThing.fetchRequest()
        let ordenarPor = NSSortDescriptor(key: "fechaCreacionUnFT", ascending: false)
        
        fetchRequest.sortDescriptors = [ordenarPor]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            unFollowThingActual = fetchResultController.fetchedObjects!
            //            try unFollowThingActual = try contexto.fetch(fetchRequest)
            //            tablaSecundaria.reloadData()
        } catch let error as NSError {
            print ("Error al recuperar",error)
        }
        
    }
    func ajustaSeparadorTabla(){
        if unFollowThingActual.count > 0 {
            self.tablaSecundaria.separatorStyle = UITableViewCell.SeparatorStyle.singleLine}
        else {
            self.tablaSecundaria.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
    }
}



extension ViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension UIView {

var heightConstraint: NSLayoutConstraint? {
    get {
        return constraints.first(where: {
            $0.firstAttribute == .height && $0.relation == .equal
        })
    }
    set { setNeedsLayout() }
}

var widthConstraint: NSLayoutConstraint? {
    get {
        return constraints.first(where: {
            $0.firstAttribute == .width && $0.relation == .equal
        })
    }
    set { setNeedsLayout() }
}

}
extension UIViewController {
    func expandirContenedor(contenedor:UIView,abrir:Bool,tamaño:Float) {
        
        if abrir {
            contenedor.translatesAutoresizingMaskIntoConstraints = false
            
            contenedor.heightAnchor.constraint(equalToConstant: CGFloat(tamaño)).isActive = true
            contenedor.heightConstraint?.constant = CGFloat(tamaño)
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else {
            contenedor.translatesAutoresizingMaskIntoConstraints = false
            
            if contenedor.heightConstraint?.constant != 0 {
                
                contenedor.heightConstraint?.constant = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func expandirContenedorLateral(contenedor:UIView,tamaño:Float,abrir:Bool){
        
        if abrir {
        contenedor.translatesAutoresizingMaskIntoConstraints = false
        
        contenedor.widthAnchor.constraint(equalToConstant: CGFloat(tamaño)).isActive = true
        contenedor.widthConstraint?.constant = CGFloat(tamaño)
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
        }
        else
        {
            contenedor.translatesAutoresizingMaskIntoConstraints = false
            if contenedor.widthConstraint?.constant != 0 {
                
                
                contenedor.widthConstraint?.constant = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    func mueveContenedorEjeX(contenedor:UIView,coordenadasX:Float){
        
        
        UIView.animate(withDuration: 0.25, animations: {
            contenedor.frame.origin.x = CGFloat(coordenadasX)
          
        })
    }
}

class SetSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            return CGRect(x: 0, y: (containerView?.bounds.height ?? 0)/3, width: containerView?.bounds.width ?? 0, height: (containerView?.bounds.height ?? 0)/1.5)
        }
    }
}


