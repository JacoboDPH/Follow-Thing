//
//  VCVisorFotos.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 03/11/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

class VCVisorFotos: UIViewController, UITableViewDelegate, UITableViewDataSource, ProtocoloCellVisorFotos, ProtocoloDelegadoCollectionViewFotos {
 
//    MARK:- PROTOCOLOS COLLECCION FOTOS
    func envioFotosTeatro(arrayFotos: [UnFollowThing]) {
        
        unFollowThingTeatro = arrayFotos
        
        configuraModoTeatro()
        estadoVisualModoTeatro(visible: true)
    }
    
    func envioFotoCollection(unFollow: UnFollowThing!) {
        
        let indiceObjetivo = indiceFotoSeleccionada(unFollowThingBuscar: unFollow)
        
        self.tablaVisor.scrollToRow(at: indiceObjetivo, at: .middle, animated: false)
    }
    
//    MARK:- PROTOCOLOS CELL VISOR FOTOS
    func estaEnZoom(valor: Bool) {
        tablaVisor.isScrollEnabled = valor
        
        if !valor {
            contenedorEtiquetas.desiluminar()
            contenedorBotones.desiluminar()
        }
        else {
            contenedorEtiquetas.iluminar()
            contenedorBotones.iluminar()
        }
    }
    //    MARK:- IBOULETS
    
    @IBOutlet var tablaVisor: UITableView!
    @IBOutlet var contenedorEtiquetas: UIView!
    @IBOutlet var etiquetaTitulo: UILabel!
    @IBOutlet var etiquetaSubtitulo: UILabel!
   
    
    @IBOutlet var contenedorBotones: UIView!
    @IBOutlet var btn01Visor: UIButton!
    @IBOutlet var btn02Visor: UIButton!
    @IBOutlet var btn03Visor: UIButton!
    @IBOutlet var btn04Visor: UIButton!
    
    
    @IBOutlet var contenedorTeatro: UIView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var fotoA: UIImageView!
    @IBOutlet var contenedorFotoB: UIView!
    @IBOutlet var fotoB: UIImageView!
    
    @IBOutlet var gestoSwipeDerecha: UISwipeGestureRecognizer!
    //    MARK:- VARIABLES
    var followThing:FollowThing!
    var unFollowThings:[UnFollowThing] = []
    var unFollowThingsFotos:[UnFollowThing] = []
    var unFollowThingObjetivo:UnFollowThing!
    var unFollowThingTeatro:[UnFollowThing] = []
    
//    INICIADORES DEL SISTEM
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ORDENAR
        view.backgroundColor = .clear
        view.addBlurEffectFondoOscuro()
        
        
        tablaVisor.backgroundColor = .clear
        tablaVisor.alpha = 0
        self.tablaVisor.estimatedRowHeight = 0;
            self.tablaVisor.estimatedSectionHeaderHeight = 0;
            self.tablaVisor.estimatedSectionFooterHeight = 0;
        for subview in self.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
                break;
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preparaMatrizFotos()
        configuraContenedorEtiquetas()
        
        configuraModoTeatro()
        
        if unFollowThingTeatro.count == 2 {
            estadoVisualModoTeatro(visible: true)
        }
       
    }
//  MARK:- CONFIGURADORES INCIALES
    
    func configuraContenedorBotones(){
        
        contenedorBotones.backgroundColor = .clear
    }
    func indiceFotoSeleccionada(unFollowThingBuscar:UnFollowThing)->IndexPath {
        
        let indice = unFollowThingsFotos.firstIndex(where: {$0.fechaCreacionUnFT! == unFollowThingBuscar.fechaCreacionUnFT!})
       
        let indexPath = IndexPath(row: indice!, section: 0)
        
        return indexPath
    }
    func configuraContenedorEtiquetas(){
        
        contenedorEtiquetas.backgroundColor = .clear
        
        configuraEtiquetas(etiqueta: etiquetaTitulo, fuente: fuenteVisorTitulo!, texto: followThing.titulo!)
        
        let indice = unFollowThingsFotos.firstIndex(where: {$0.fechaCreacionUnFT! == unFollowThingObjetivo.fechaCreacionUnFT!})
       
      
        let indexPath = IndexPath(row: indice!, section: 0)
      
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.tablaVisor.scrollToRow(at: indexPath, at: .middle, animated: false)
            self.tablaVisor.iluminar()
            self.tablaVisor.layoutIfNeeded()
            
       }
        
        let fechaObjetivo = unFollowThingsFotos[indice!].fechaCreacionUnFT
        
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: fechaObjetivo!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date()) - dia


        configuraEtiquetas(etiqueta: etiquetaSubtitulo, fuente: fuenteVistorSubtitulo!, texto: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false))

    }
    func configuraEtiquetas(etiqueta:UILabel,fuente:UIFont,texto:String){
        
        etiqueta.textColor = .white
        etiqueta.backgroundColor = .clear
        etiqueta.font = fuente
        etiqueta.sombreaEtiqueta()
        etiqueta.text = texto
        
    }
    func configuraModoTeatro(){
        
        contenedorTeatro.layoutIfNeeded()
        
        slider.frame.origin.y = contenedorTeatro.frame.size.height/2
        slider.frame.origin.x = 0
        slider.frame.size.width = UIScreen.main.bounds.size.width
        
        slider.minimumValue = 0;
        slider.maximumValue = Float(UIScreen.main.bounds.size.width)
        
        slider.value = slider.maximumValue/2
        
        slider.maximumTrackTintColor = .clear
        slider.sombreaVista()
        
        let circleImage = makeCircleWith(size: CGSize(width: 50, height: 50),
                                         backgroundColor: .white)
        slider.setThumbImage(circleImage, for: .normal)
        slider.setThumbImage(circleImage, for: .highlighted)
        
        slider.alpha = 0

       
        contenedorFotoB.frame.size.height = contenedorTeatro.frame.size.height
        contenedorFotoB.borders(for: [.left], width: 0.5, color: .darkGray)
        fotoA.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: contenedorTeatro.frame.size.height)
        fotoB.frame = CGRect(x:  -UIScreen.main.bounds.size.width/2, y: 0, width: UIScreen.main.bounds.width, height: contenedorTeatro.frame.size.height)
        
        contenedorFotoB.frame.origin.x = UIScreen.main.bounds.width/2
        contenedorFotoB.frame.origin.y = 0
        
        contenedorFotoB.frame.size = contenedorTeatro.frame.size
        
        contenedorTeatro.alpha = 0
        contenedorTeatro.isHidden = true
        
        if unFollowThingTeatro.count == 2 {
        fotoA.image = UIImage(data: unFollowThingTeatro[0].foto! as Data)
        fotoB.image = UIImage(data: unFollowThingTeatro[1].foto! as Data)
        }
    }
    func etiquetaSubtituloDinamica(indice:Int) {

        let fechaObjetivo = unFollowThingsFotos[indice].fechaCreacionUnFT
        
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: fechaObjetivo!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date()) - dia

        configuraEtiquetas(etiqueta: etiquetaSubtitulo, fuente: fuenteVistorSubtitulo!, texto: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false))
    }
//    MARK:- ACCION ENTRE CONTROLADORES DESDE STORYBOARD
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "visorParaCollecion" {
            
            let VCCollecionFotos = segue.destination as! VCCollectionViewFotos
            VCCollecionFotos.delegado = self
            VCCollecionFotos.unFollowThingRecibido = unFollowThings
            VCCollecionFotos.followThingRecibido = followThing
            VCCollecionFotos.iniciaDesdeVisorFotos = false
            VCCollecionFotos.modoTeatro = false
            
        }
       
        if segue.identifier == "vcParaTeatro" {
            
            let VCTeatro = segue.destination as! VCCollectionViewFotos
            
            VCTeatro.delegado = self
            VCTeatro.iniciaDesdeVisorFotos = true
            VCTeatro.unFollowThingRecibido = unFollowThings
            VCTeatro.followThingRecibido = followThing
            VCTeatro.modoTeatro = true
        
        }
    }
//    MARK:- COMPARTIR
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
        textImgView.image = imageFrom(text: texto, size: viewToRender.frame.size, rect:  CGRect(x: 5, y: alturaY - etiquetaTitulo.frame.size.height - etiquetaSubtitulo.frame.size.height, width: etiquetaTitulo.frame.size.width, height: etiquetaSubtitulo.frame.size.height))
        viewToRender.addSubview(textImgView)
        
        let textImgView02 = UIImageView(frame: viewToRender.frame)
        textImgView02.image = imageFrom(text: texto02, size: viewToRender.frame.size, rect:  CGRect(x: 5, y: etiquetaTitulo.frame.origin.y + etiquetaTitulo.frame.size.height + 10, width: etiquetaTitulo.frame.size.width, height: etiquetaTitulo.frame.size.height))
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
    
    @IBAction func btn04Compartir(_ sender: Any) {
    
        let foto:UIImage = UIImage(data: unFollowThingObjetivo.foto! as Data)!
        
        let fotoEnvio = crearImagenConTitulo(texto: etiquetaTitulo.text!, texto02: etiquetaSubtitulo.text!, imagen: foto)
        
        let compartir = UIActivityViewController(activityItems: [fotoEnvio!], applicationActivities: nil)
        
        compartir.popoverPresentationController?.sourceView = self.view
        self.present(compartir, animated: true, completion: nil)
    }
    @IBAction func btnCierre(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    @IBAction func swipeCierre(_ sender: Any) {
        performSegueToReturnBack()
    }
    @IBAction func btn03Visor(_ sender: Any) {
        
        if !estaEnModoTeatro() {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let VCTeatro = storyboard.instantiateViewController(identifier: "VCCollectionViewFotos") as! VCCollectionViewFotos
            
            VCTeatro.delegado = self
            VCTeatro.iniciaDesdeVisorFotos = true
            VCTeatro.unFollowThingRecibido = unFollowThings
            VCTeatro.followThingRecibido = followThing
            VCTeatro.modoTeatro = true
            
            VCTeatro.modalPresentationStyle = .popover
            
            self.present(VCTeatro, animated: true)
        }
        else {
            
           cierreModoTeatro()
        }
    }
    //    MARK:- MODO TEATRO
    func estaEnModoTeatro()->Bool{
        
        var existe:Bool = false
       
        if contenedorTeatro.alpha > 0 {
            existe = true
            gestoSwipeDerecha.isEnabled = false
        }
        return existe
    }
    
    @IBAction func accionSalirModoTeatro(_ sender: Any) {
       
        cierreModoTeatro()
        
        
    }
    func cierreModoTeatro(){
      
        let valorSlider = CGFloat(slider.value)
        
        if valorSlider > UIScreen.main.bounds.size.width/2 {
            
            tablaVisor.scrollToRow(at: indiceFotoSeleccionada(unFollowThingBuscar: unFollowThingTeatro[0]), at: .middle, animated: false)
        }
        if valorSlider < UIScreen.main.bounds.size.width/2 {
            
            tablaVisor.scrollToRow(at: indiceFotoSeleccionada(unFollowThingBuscar: unFollowThingTeatro[1]), at: .middle, animated: false)
        }
        gestoSwipeDerecha.isEnabled = true
        unFollowThingTeatro.removeAll()
        
        estadoVisualModoTeatro(visible: false)
    }
    func estadoVisualModoTeatro(visible:Bool){
        
        if visible {
            
            tablaVisor.desiluminar()
            contenedorTeatro.isHidden = false
            contenedorTeatro.iluminar()
            
            btn03Visor.backgroundColor = .red
            btn03Visor.redondear()
            btn03Visor.setTitle("   Salir ", for: .normal)
          
            let pulse = CASpringAnimation(keyPath: "transform.scale")
                pulse.duration = 2.9
                pulse.fromValue = 1.0
                pulse.toValue = 1.12
                pulse.autoreverses = true
                pulse.repeatCount = .infinity
                pulse.initialVelocity = 3.5
                pulse.damping = 0.8
                btn03Visor.layer.add(pulse, forKey: nil)
           
//            btn01Visor.isHidden = true
            btn02Visor.isHidden = true
            btn04Visor.isHidden = true
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               
                self.slider.iluminar()
                self.slider.superRebotar()
            }
        }
        else
        {
            tablaVisor.iluminar()
            contenedorTeatro.desiluminar()
            contenedorTeatro.isHidden = true
            slider.desiluminar()
            
            btn03Visor.backgroundColor = .clear
            btn03Visor.redondear()
            btn03Visor.setTitle("", for: .normal)
            
//            btn01Visor.isHidden = false
            btn02Visor.isHidden = false
            btn04Visor.isHidden = false
            
            btn03Visor.layer.removeAllAnimations()
        }
    }
    @IBAction func accionSlider(_ sender: UISlider) {
        
        let valorSlider = CGFloat(sender.value)
        
        contenedorFotoB.frame.origin.x = valorSlider
        contenedorFotoB.frame.size.width = UIScreen.main.bounds.size.width - valorSlider
        
        fotoB.frame.origin.x = -valorSlider
        
        if valorSlider > UIScreen.main.bounds.size.width/2 {
   
            let fechaObjetivo =  unFollowThingTeatro[0].fechaCreacionUnFT
                        
            let dia = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: fechaObjetivo!)
            let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date()) - dia

            configuraEtiquetas(etiqueta: etiquetaSubtitulo, fuente: fuenteVistorSubtitulo!, texto: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false))
        }
        
        if valorSlider < UIScreen.main.bounds.size.width/2 {
            
            let fechaObjetivo = unFollowThingTeatro[1].fechaCreacionUnFT
            
            let dia = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: fechaObjetivo!)
            let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date()) - dia
            
            configuraEtiquetas(etiqueta: etiquetaSubtitulo, fuente: fuenteVistorSubtitulo!, texto: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false))
            
        }
    }
    //    MARK:- FUNCIONES DE CLASE
    func preparaMatrizFotos(){
        
        for fotos in 1...unFollowThings.count {
            
            if unFollowThings[fotos-1].foto != nil {
                
                unFollowThingsFotos.append(unFollowThings[fotos-1])
                
            }
        }
    }
    
    
//    MARK:- TABLA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unFollowThingsFotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tablaVisor.dequeueReusableCell(withIdentifier: "TableViewCellVisorFoto", for: indexPath) as! TableViewCellVisorFoto
        
        cell.delegado = self
        
        let indice = unFollowThingsFotos[indexPath.row]
        
        cell.fotoScrollTabla.image = UIImage(data: indice.foto! as Data)
        
       
        cell.backgroundColor = .clear
        cell.fotoScrollTabla.backgroundColor = .clear
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.tablaVisor.frame.height
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            if tableView.visibleCells.contains(cell) {
                self.etiquetaSubtituloDinamica(indice: indexPath.row)
                self.unFollowThingObjetivo = unFollowThings[indexPath.row]
            }
        }
    }
    var lecturaCelda:Bool = false
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         self.lecturaCelda = false
      
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lecturaCelda = true
        
        print("valorOffsetFinal",tablaVisor.contentOffset.y)
        let con = tablaVisor.contentSize.height
        let des = tablaVisor.frame.size.height
        
        print("total",con,des)
     
      
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

//        ********* DEPURAR ESTE CODIGO
        
        if tablaVisor.contentOffset.y < 0 {

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)

            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

                self.tablaVisor.contentOffset.y = 0

            }, completion: { _ in

                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

                    self.tablaVisor.contentOffset.y = 0
                }, completion: nil)
            })
        }

        if tablaVisor.contentOffset.y > (tablaVisor.contentSize.height - tablaVisor.frame.size.height) {

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)

            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

                self.tablaVisor.contentOffset.y = self.tablaVisor.contentOffset.y - 20

            }, completion: { _ in

                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [self] in

                    self.tablaVisor.contentOffset.y = tablaVisor.contentSize.height - tablaVisor.frame.size.height
                }, completion: nil)
            })
        }
        
        //        ********* DEPURAR ESTE CODIGO
    }

    
    //    MARK:- ZOOM TAP
    
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
