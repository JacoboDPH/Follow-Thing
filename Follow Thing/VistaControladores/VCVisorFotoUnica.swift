//
//  VCVisorFotoUnica.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 01/09/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol ProtocoloDelegadoVisorUnico {
    func actualizarDatosVisorUnico()
}

class VCVisorFotoUnica: UIViewController, UIScrollViewDelegate, delegadoVisorFotosTabla, UITextFieldDelegate, ProtocoloDelegadoCollectionViewFotos {
    func envioFotoCollection(unFollow: UnFollowThing!) {
        
        fotoUnica.image = UIImage(data: unFollow.foto! as Data)
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: unFollow.fechaCreacionUnFT!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: Date()) - dia
        
        etiquetaDiaSubtitulo.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false)
        
        fechaCreacionUnFTRecibido = unFollow.fechaCreacionUnFT
        
        if modoTeatro {
            modoTeatroApaga()
        }
    }
    func envioFotosTeatro(arrayFotos: [UnFollowThing]) {
        
        modoTeatro = true
        unFollowThingTeatro = arrayFotos
        configuraEtiquetaModoTeatro()
        configuraModoTeatro()
        
    }
    @IBAction func accionBotonTeatro(_ sender: Any) {
        
    
    
    }
    func pinchCell(sender: UIPinchGestureRecognizer) {
        
    }
    @IBOutlet var fotoUnica: UIImageView!
    @IBOutlet var fotoA: UIImageView!
    @IBOutlet var fotoB: UIImageView!
    @IBOutlet var contenedorFotoB: UIView!
    
    @IBOutlet var contenedorTextview: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var botonCierre: UIButton!
    @IBOutlet var botonCompartir: UIButton!
    @IBOutlet var botonAddAnotacion: UIButton!
    @IBOutlet var botonCollecionFotos: UIButton!
    @IBOutlet var botonTearto: UIButton!
    
    @IBOutlet var etiquetaDiaSubtitulo: UILabel!
    @IBOutlet var etiquetaDia: UILabel!
    @IBOutlet var etiquetaInteriorContenedorTerxtview: UILabel!
    
    @IBOutlet var textfiedlVisorUnico: UITextField!
    
    @IBOutlet var slider: UISlider!
    
    //    MARK:- VARIABLES
   
    public var unFTDB:[UnFollowThing] = []
    public var unFollowThingTeatro:[UnFollowThing] = []
    public var followThingDesdeSec:FollowThing!
    
    public var imageData:UIImage?
    public var fechaCreacionUnFTRecibido:Date?
    
    private var zoom:Bool = false
    private var editandoAnotacion = false
    public var modoTeatro = false
    public var modoTeatroDesdeSec = false
    
    public var delegado:ProtocoloDelegadoVisorUnico? = nil
  
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addBlurEffectFondoOscuro()
        
        fotoUnica.image = imageData
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.zoomScale = 1.0
        
        self.scrollView.flashScrollIndicators()
        
        setupGestureRecognizer()
        if !modoTeatro {configuracionEtiqueta()}
        configuraBotones()
        configuraTextField()
        configuraTextView()
        configReseteaModoTeatro()
        
        if modoTeatro {           
            configuraEtiquetaModoTeatro()
            configuraModoTeatro()
        }
    }
    func configReseteaModoTeatro(){
        slider.alpha = 0
        fotoA.alpha = 0
        contenedorFotoB.alpha = 0
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !modoTeatro {  compruebaSiExisteAnotacion()}
    }
    //    MARK:- ACCIONES DESDE STORYBOARD

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "visorToTabla" {
            
            let VCVisorFotosTabla = segue.destination as! VCVisorFotosTabla
            VCVisorFotosTabla.delegado = self
            VCVisorFotosTabla.unFollowThingRecibidoSec = unFTDB
            VCVisorFotosTabla.followThingDBRecibido = followThingDesdeSec
            VCVisorFotosTabla.desdeVisorFotos = true
            VCVisorFotosTabla.fechaCreacionUnFTRecibido = fechaCreacionUnFTRecibido
            VCVisorFotosTabla.modalPresentationStyle = .popover
            VCVisorFotosTabla.modalTransitionStyle = .crossDissolve
        }
        
        
        if segue.identifier == "visorToTeatro" {
          
            
            let VCTeatro = segue.destination as! VCCollectionViewFotos
            
            VCTeatro.delegado = self
            VCTeatro.iniciaDesdeVisorFotos = true
            VCTeatro.unFollowThingRecibido = unFTDB
            VCTeatro.followThingRecibido = followThingDesdeSec
            VCTeatro.modoTeatro = true
            
        }
        
        if segue.identifier == "visorToCollectionFotos" {
            
            let VCTeatro = segue.destination as! VCCollectionViewFotos
                       
                       VCTeatro.delegado = self
                       VCTeatro.iniciaDesdeVisorFotos = false
                       VCTeatro.unFollowThingRecibido = unFTDB
                       VCTeatro.followThingRecibido = followThingDesdeSec
                       VCTeatro.modoTeatro = false
        }
        
    }
    //    MARK:- CONFIGURACION
    func configuraModoTeatro() {
        
        scrollView.isHidden = true
        fotoA.iluminar()
        contenedorFotoB.iluminar()
        
        
        botonAddAnotacion.alpha = 0.5
        botonCompartir.alpha = 0.5
        
        botonCompartir.isUserInteractionEnabled = false
        botonAddAnotacion.isUserInteractionEnabled = false
    
        
        modoTeatro = true
        
        if unFollowThingTeatro.count == 2 {
           
            fotoA.image = UIImage(data: unFollowThingTeatro[0].foto! as Data)
            fotoB.image = UIImage(data: unFollowThingTeatro[1].foto! as Data)
            
        }
        
        slider.sombreaVista()
        
        slider.frame.origin.y = UIScreen.main.bounds.size.height/2
        slider.frame.origin.x = 0
        slider.frame.size.width = UIScreen.main.bounds.size.width
        
        var medidasFoto:CGRect
        let puntoAB =  (botonTearto.frame.origin.y) - (etiquetaDiaSubtitulo.frame.origin.y + etiquetaDiaSubtitulo.frame.size.height)
        medidasFoto = CGRect(x: 0, y: etiquetaDiaSubtitulo.frame.origin.y + etiquetaDiaSubtitulo.frame.size.height + 5, width: UIScreen.main.bounds.size.width, height: puntoAB - 20)
        
        
        
    
        fotoA.frame = medidasFoto
        fotoB.frame = CGRect(x: -UIScreen.main.bounds.size.width/2, y: 0, width: medidasFoto.size.width, height: medidasFoto.size.height)
        contenedorFotoB.frame =  medidasFoto
        
        contenedorFotoB.frame.origin.x = UIScreen.main.bounds.size.width/2
        contenedorFotoB.frame.size.width = UIScreen.main.bounds.size.width/2
              
        slider.minimumValue = 0;
        slider.maximumValue = Float(UIScreen.main.bounds.size.width)
        
        slider.value = slider.maximumValue/2
        
        slider.maximumTrackTintColor = .clear
        
        let circleImage = makeCircleWith(size: CGSize(width: 50, height: 50),
                                         backgroundColor: .white)
        slider.setThumbImage(circleImage, for: .normal)
        slider.setThumbImage(circleImage, for: .highlighted)
        
        botonTearto.backgroundColor = botonActivo
        
        botonTearto.redondear()
        
        etiquetaDiaSubtitulo.text = ""
        
        slider.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
           
            self.slider.iluminar()
            self.slider.superRebotar()
        }
        
        contenedorFotoB.borders(for: [.left], width: 1.0, color: .gray)
        
    }

    func configuraFotoDesdeTabla(unaFoto: UIImage, unaFecha: Date) {
       
        imageData = unaFoto
        fechaCreacionUnFTRecibido = unaFecha
        fotoUnica.image = imageData
        configuracionEtiqueta()

    }
    func configuraTextView(){
        
        let posicionY = textfiedlVisorUnico.frame.origin.y - (etiquetaDiaSubtitulo.frame.origin.y + etiquetaDiaSubtitulo.frame.size.height)
        
        contenedorTextview.isHidden = true
        contenedorTextview.alpha = 0
        contenedorTextview.frame = CGRect(x: 20, y:  ((UIScreen.main.bounds.width-40)/2)/2 - posicionY, width: UIScreen.main.bounds.width-40, height: (UIScreen.main.bounds.width-40)/2)
        
        contenedorTextview.backgroundColor = .clear
        contenedorTextview.clipsToBounds = true
        contenedorTextview.addBlurEffectFondo()
        
        contenedorTextview.layer.cornerRadius = 10
        
        etiquetaInteriorContenedorTerxtview.frame = CGRect(x: 0, y: 0, width: contenedorTextview.frame.size.width, height: contenedorTextview.frame.size.height)
        etiquetaInteriorContenedorTerxtview.textColor = .black
        etiquetaInteriorContenedorTerxtview.text = "No hay existe anotación para esta foto"
        
    }
    func configuraTextField(){
        
        textfiedlVisorUnico.delegate = self
        textfiedlVisorUnico.alpha = 0.0
        textfiedlVisorUnico.frame = CGRect(x: 50,
                                           y: UIScreen.main.bounds.size.height/2,
                                           width: UIScreen.main.bounds.size.width-60,
                                           height: botonCompartir.frame.size.height)
        textfiedlVisorUnico.placeholder = "Añade una anotación a la foto"
        textfiedlVisorUnico.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        textfiedlVisorUnico.returnKeyType = .done
    }
    func configuraIncioBlur(){
        
        fotoUnica.addBlurEffect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.fotoUnica.unblur()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: {
            self.etiquetaDia.desiluminar()
            self.etiquetaDiaSubtitulo.desiluminar()
        })
    }
    func configuraBotones(){
        
        let compartimento = UIScreen.main.bounds.size.width - 160 / 2
        
        botonAddAnotacion.frame = CGRect(x: 40, y: UIScreen.main.bounds.size.height - 100, width: 40, height: 40)
        botonCollecionFotos.frame = CGRect(x: compartimento/2 - 20, y: UIScreen.main.bounds.size.height - 100, width: 40, height: 40)
        botonTearto.frame = CGRect(x: compartimento/1.5+20, y: UIScreen.main.bounds.size.height - 100, width: 40, height: 40)
        botonCompartir.frame =  CGRect(x: UIScreen.main.bounds.width-80, y: UIScreen.main.bounds.size.height - 100, width: 40, height: 40)
      
        botonAddAnotacion.alpha = 1.0
        botonCompartir.alpha = 1.0
        
        botonCompartir.isUserInteractionEnabled = true
        botonAddAnotacion.isUserInteractionEnabled = true
        
        botonAddAnotacion.redondear()
    }
    func configuraEtiquetaModoTeatro(){
        
        etiquetaDia.text = followThingDesdeSec.titulo!
        
        etiquetaDiaSubtitulo.font = fuenteVistorSubtitulo
        etiquetaDia.font = fuenteVisorTitulo
        
        etiquetaDia.frame = CGRect(x: 20, y: 40, width: UIScreen.main.bounds.size.width-80, height: 42)
   
        var alturaSubtitulo:CGFloat = 0
        
        let altura1 = calculaAlturaAdecuada(indice: 0)
        let altura2 = calculaAlturaAdecuada(indice: 1)
       
        alturaSubtitulo = altura1
        
        if altura2 > altura1 {
            alturaSubtitulo = altura2
        }
        
        etiquetaDiaSubtitulo.frame = CGRect(x: 20, y: etiquetaDia.frame.origin.y + CGFloat(42), width: UIScreen.main.bounds.size.width, height: alturaSubtitulo)
        
        etiquetaDia.textColor = .white
        etiquetaDiaSubtitulo.textColor = .white
        
        etiquetaDia.adjustsFontSizeToFitWidth = true
        etiquetaDia.minimumScaleFactor = 0.5
        etiquetaDia.lineBreakMode = .byClipping
        
        etiquetaDia.numberOfLines = 0
        etiquetaDiaSubtitulo.numberOfLines = 2
        
    }
    func calculaAlturaAdecuada(indice:Int)->CGFloat {
        
        var altura:CGFloat = 0
        
        let fecha = unFollowThingTeatro[indice].fechaCreacionUnFT!
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: fecha)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: Date()) - dia
        
        altura = heightForView(text: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false), font: fuenteVistorSubtitulo!, width: UIScreen.main.bounds.size.width)
         
        return altura
        
    }
    func configuracionEtiqueta() {
        
      
        let index = unFTDB.firstIndex(where: {$0.fechaCreacionUnFT! == fechaCreacionUnFTRecibido})
       
        let fecha = unFTDB[index!].fechaCreacionUnFT
        
        let titulo = followThingDesdeSec.titulo!
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: fecha!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: Date()) - dia
        
        let altura = 42

        let alturaSubtitulo = heightForView(text: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false), font: fuenteVistorSubtitulo!, width: UIScreen.main.bounds.size.width)
        
        etiquetaDiaSubtitulo.font = fuenteVistorSubtitulo
        etiquetaDia.font = fuenteVisorTitulo
        
        etiquetaDia.frame = CGRect(x: 20, y: 40, width: UIScreen.main.bounds.size.width-80, height: 42)
        
        etiquetaDiaSubtitulo.frame = CGRect(x: 20, y: etiquetaDia.frame.origin.y + CGFloat(altura), width: UIScreen.main.bounds.size.width, height: alturaSubtitulo)
        
        etiquetaDia.textColor = .white
        etiquetaDiaSubtitulo.textColor = .white
        
        etiquetaDia.adjustsFontSizeToFitWidth = true
        etiquetaDia.minimumScaleFactor = 0.5
        etiquetaDia.lineBreakMode = .byClipping
        
        etiquetaDia.numberOfLines = 0
        
        etiquetaDia.text =  titulo
        etiquetaDiaSubtitulo.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false)
    }
    
//    MARK:- FUNCION BOTONES
   
    @IBAction func botonCompartir(_ sender: Any) {
    
        let fotoEnvio = crearImagenConTitulo(texto: etiquetaDia.text!, texto02: etiquetaDiaSubtitulo.text!, imagen: fotoUnica.image!)
        
        let compartir = UIActivityViewController(activityItems: [fotoEnvio!], applicationActivities: nil)
        
        compartir.popoverPresentationController?.sourceView = self.view
        self.present(compartir, animated: true, completion: nil)
        
    }
    @IBAction func botonCierre(_ sender: Any) {
     cierre()
    }
    
    @IBAction func pulsarBotonAdd(_ sender: Any) {
        
        estadoAddAnotacion()
        
    }
    func estadoAddAnotacion(){
        if editandoAnotacion == false {
            editandoAnotacion = true
            cargarAnotacion()
            
        }
        else
        {
            guardarComentario()
            editandoAnotacion = false
        }
        DispatchQueue.main.async( execute: {
            self.muestraAddAnotacion(estado: self.editandoAnotacion)
        })
    }
    func muestraAddAnotacion(estado:Bool){
     
        if estado {
            contenedorTextview.isHidden = false
            textfiedlVisorUnico.isHidden = false
            textfiedlVisorUnico.becomeFirstResponder()
            fotoUnica.clipsToBounds = true
            
            self.fotoUnica.addBlurEffect()
            contenedorTextview.isHidden = false
          
            UIView.animate(withDuration: 0.2) {
               
                self.botonAddAnotacion.frame.origin.x = 5
                self.botonAddAnotacion.frame.origin.y = UIScreen.main.bounds.size.height/2
               
              
                self.textfiedlVisorUnico.alpha = 1.0

                 self.botonAddAnotacion.backgroundColor = botonActivo
               
            }
        }
        else {
            contenedorTextview.desiluminar()
            textfiedlVisorUnico.desiluminar()
            fotoUnica.unblur()
            dismissKeyboard()
            compruebaSiExisteAnotacion()
            
            UIView.animate(withDuration: 0.2) {
                
                self.botonAddAnotacion.frame.origin.y = self.botonCompartir.frame.origin.y
                self.botonAddAnotacion.frame.origin.x = 40
                                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                
                self.contenedorTextview.isHidden = true
                self.textfiedlVisorUnico.isHidden = true
                
            })
        }
    }
//    MARK:- FUNCIONES DE CIERRE
    
    @IBAction func cierreVC(_ sender: Any) {
        
        if !modoTeatro {
            cierre()
        }
    }
    func cierre(){
       
        if editandoAnotacion {
            editandoAnotacion = false
            DispatchQueue.main.async( execute: {
                self.muestraAddAnotacion(estado: self.editandoAnotacion)
            })
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: - MODO TEATRO
    func modoTeatroApaga(){
        
        if modoTeatro {
            
            configuraBotones()
            if !modoTeatroDesdeSec {    configuracionEtiqueta() }
         
            configuracionEtiqueta()
            botonTearto.backgroundColor = .clear
            
            scrollView.isHidden = false
            
            fotoA.desiluminar()
            contenedorFotoB.desiluminar()
            slider.desiluminar()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                
                self.modoTeatro = false
                
            })
        }
        else {
            
        }
    }
    
    @IBAction func accionSlider(_ sender: UISlider) {
        
        let valorSlider = CGFloat(sender.value)
        
        mueveSlider(valorSlider: valorSlider)
        
    }
    func mueveSlider(valorSlider:CGFloat){
        
     
        contenedorFotoB.frame.origin.x = valorSlider
        contenedorFotoB.frame.size.width = UIScreen.main.bounds.size.width - valorSlider
        
        fotoB.frame.origin.x = -valorSlider
        
        if valorSlider > UIScreen.main.bounds.size.width/2 {
            
            let dia =  Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: unFollowThingTeatro[0].fechaCreacionUnFT!)
            let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: Date()) - dia
          
            
            etiquetaDiaSubtitulo.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false)
            
        }
        if valorSlider < UIScreen.main.bounds.size.width/2 {
            
            let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: unFollowThingTeatro[1].fechaCreacionUnFT!)
            let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: Date()) - dia
          
            etiquetaDiaSubtitulo.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false)
            
        }
    }
    
    @IBAction func gestoCerrarFotoB(_ sender: Any) {
       
        if !modoTeatroDesdeSec { modoTeatroApaga() }  else {
                   performSegueToReturnBack()
               }
    }
    @IBAction func gestpCerrarFotoA(_ sender: Any) {
        
        if !modoTeatroDesdeSec { modoTeatroApaga() } else {
            performSegueToReturnBack()
        }
    }

    //    MARK:- TEXTFIELD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        estadoAddAnotacion()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let previousText:NSString = textField.text! as NSString
        let updatedText = previousText.replacingCharacters(in: range, with: string)
      
        etiquetaInteriorContenedorTerxtview.text = updatedText
        
        if updatedText == "" {
            contenedorTextview.desiluminar()
        } else {
            contenedorTextview.iluminar()
        }
        
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.textfiedlVisorUnico.frame.origin.y  -= keyboardSize.height + 100
                        self.botonAddAnotacion.frame.origin.y = self.textfiedlVisorUnico.frame.origin.y + self.botonCompartir.frame.size.height
                        self.view.layoutIfNeeded()
                    })
                }
        fotoUnica.isUserInteractionEnabled = false
        fotoUnica.blur()
        view.addBlurEffectFondo()
            }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.textfiedlVisorUnico.frame.origin.y += keyboardSize.height
                    self.view.layoutIfNeeded()
                })
            }
        fotoUnica.isUserInteractionEnabled = true
        fotoUnica.unblur()
        view.removeBlurEffect()
        }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        
        
          if (self.lastContentOffset > scrollView.contentOffset.y) {
                 // move up
             }
             else if (self.lastContentOffset < scrollView.contentOffset.y) {
                
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                     
                     if self.zoom == false {
//                        self.dismiss(animated: true, completion: nil)
                         
                     }
                 })
             }
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    private func scrollViewDidScroll(scrollView: UIScrollView!) {
        
     
    }
    //    MARK:- ZOOM TAP
    func setupGestureRecognizer() {
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGest.numberOfTapsRequired = 2
        self.fotoUnica.addGestureRecognizer(doubleTapGest)
        
        let simpleTap = UITapGestureRecognizer(target: self, action: #selector(unToqueFoto(recognizer:)))
        simpleTap.numberOfTouchesRequired = 1
        self.fotoUnica.addGestureRecognizer(simpleTap)
    }
    @objc func unToqueFoto(recognizer: UITapGestureRecognizer){
        
        
        
    }
    func zoomDesdeVisorTabla(recognizer: UITapGestureRecognizer) {
         let escala = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
               
               if escala != scrollView.zoomScale {
                   
                   let point = recognizer.location(in: fotoUnica)
                   let scrollSize = scrollView.frame.size
                   let size = CGSize(width: scrollSize.width / scrollView.maximumZoomScale,
                                     height: scrollSize.height / scrollView.maximumZoomScale)
                   let origin = CGPoint(x: point.x - size.width / 2,
                                        y: point.y - size.height / 2)
                   
                   scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
                   
               }
    }
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
                
        let escala = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)
        
        if escala != scrollView.zoomScale {
            
            let point = recognizer.location(in: fotoUnica)
            let scrollSize = scrollView.frame.size
            let size = CGSize(width: scrollSize.width / scrollView.maximumZoomScale,
                              height: scrollSize.height / scrollView.maximumZoomScale)
            let origin = CGPoint(x: point.x - size.width / 2,
                                 y: point.y - size.height / 2)
            
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
            
        } else if scrollView.zoomScale == 2 {
            
           
            
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: fotoUnica)), animated: true)
        }
    }
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        
        
        var zoomRect = CGRect.zero
        zoomRect.size.height = fotoUnica.frame.size.height / scale
        zoomRect.size.width  = fotoUnica.frame.size.width  / scale
        
        let newCenter = scrollView.convert(center, from: fotoUnica)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    //    MARK:- ZOOM PICH
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       
       
//        fotoUnica.translatesAutoresizingMaskIntoConstraints = true
        return fotoUnica
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if scrollView.zoomScale > 1 {
            if let image = fotoUnica.image {
                
                let ratioW = fotoUnica.frame.width / image.size.width
                let ratioH = fotoUnica.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let left = 0.5 * (newWidth * scrollView.zoomScale > fotoUnica.frame.width ? (newWidth - fotoUnica.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > fotoUnica.frame.height ? (newHeight - fotoUnica.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
                muestraElementos(enciende: false)
                zoom = true
                
            }
        }
        else
        {
            scrollView.contentInset = UIEdgeInsets.zero
            muestraElementos(enciende: true)
            self.zoom = false
        }
        
        fotoUnica.translatesAutoresizingMaskIntoConstraints = true
    }
    //MARK:- COREDATA
    func cargarAnotacion(){
        
  
        let index = unFTDB.firstIndex(where: {$0.fechaCreacionUnFT! == fechaCreacionUnFTRecibido})
        
        if unFTDB[index!].anotaciones != nil {
            
            etiquetaInteriorContenedorTerxtview.text = unFTDB[index!].anotaciones
            textfiedlVisorUnico.text = unFTDB[index!].anotaciones
            contenedorTextview.iluminar()
        }
    }
    func guardarComentario(){
        
        let index = unFTDB.firstIndex(where: {$0.fechaCreacionUnFT! == fechaCreacionUnFTRecibido})
        
        unFTDB[index!].anotaciones = textfiedlVisorUnico.text
        if textfiedlVisorUnico.text == "" {
            unFTDB[index!].anotaciones = nil
        }
        actualizarDatos()
    }
    func actualizarDatos() {
        
        do {
            try conexion().save()
            delegado?.actualizarDatosVisorUnico()
        } catch let error as NSError {
            print("Error al guardar:",error)
        }
    }
    func conexion () -> NSManagedObjectContext {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
        
    }
    //    MARK:- FUNCIONES DE CLASE
    func compruebaSiExisteAnotacion(){
        
        let index = unFTDB.firstIndex(where: {$0.fechaCreacionUnFT! == fechaCreacionUnFTRecibido})
        
        if unFTDB[index!].anotaciones == nil {
            UIView.animate(withDuration: 0.2) {
                self.botonAddAnotacion.backgroundColor = .clear
            }
        } else
        {
            UIView.animate(withDuration: 0.2) {
            self.botonAddAnotacion.backgroundColor = botonActivo
            }
        }
    }

    func muestraElementos(enciende:Bool) {
        
        if enciende {
            etiquetaDia.iluminar()
            etiquetaDiaSubtitulo.iluminar()
            botonCompartir.iluminar()
            botonTearto.iluminar()
            botonCollecionFotos.iluminar()
            botonAddAnotacion.iluminar()
        }
        else {
            etiquetaDia.desiluminar()
            etiquetaDiaSubtitulo.desiluminar()
            botonAddAnotacion.desiluminar()
            botonCollecionFotos.desiluminar()
            botonTearto.desiluminar()
            botonCompartir.desiluminar()
        }
    }
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
           textImgView.image = imageFrom(text: texto, size: viewToRender.frame.size, rect:  CGRect(x: 5, y: alturaY - etiquetaDia.frame.size.height - etiquetaDiaSubtitulo.frame.size.height, width: etiquetaDia.frame.size.width, height: etiquetaDia.frame.size.height))
           viewToRender.addSubview(textImgView)
           
           let textImgView02 = UIImageView(frame: viewToRender.frame)
           textImgView02.image = imageFrom(text: texto02, size: viewToRender.frame.size, rect:  CGRect(x: 5, y: etiquetaDia.frame.origin.y + etiquetaDia.frame.size.height + 10, width: etiquetaDia.frame.size.width, height: etiquetaDia.frame.size.height))
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
}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}
extension UIImage {

    class func createImageWithLabelOverlay(label: UILabel,imageSize: CGSize, image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize.width, height: imageSize.height), false, 2.0)
       
        let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let currentImage = UIImageView.init(image: image)
        currentImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        currentView.addSubview(currentImage)
        label.frame = CGRect(x: 10, y: 10, width: UIScreen.main.bounds.size.width*200, height: 500*2)
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 500*2)
        
        
        currentView.addSubview(label)
        currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

}
extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

extension UIImageView {

    var imageSizeAfterAspectFit: CGSize {
        var newWidth: CGFloat
        var newHeight: CGFloat

        guard let image = image else { return frame.size }

        if image.size.height >= image.size.width {
            newHeight = frame.size.height
            newWidth = ((image.size.width / (image.size.height)) * newHeight)

            if CGFloat(newWidth) > (frame.size.width) {
                let diff = (frame.size.width) - newWidth
                newHeight = newHeight + CGFloat(diff) / newHeight * newHeight
                newWidth = frame.size.width
            }
        } else {
            newWidth = frame.size.width
            newHeight = (image.size.height / image.size.width) * newWidth

            if newHeight > frame.size.height {
                let diff = Float((frame.size.height) - newHeight)
                newWidth = newWidth + CGFloat(diff) / newWidth * newWidth
                newHeight = frame.size.height
            }
        }
        return .init(width: newWidth, height: newHeight)
    }
}


fileprivate func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(backgroundColor.cgColor)
    context?.setStrokeColor(UIColor.clear.cgColor)
    let bounds = CGRect(origin: .zero, size: size)
    context?.addEllipse(in: bounds)
    context?.drawPath(using: .fill)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
