//
//  VCAlarmaEstadisticaColor.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 01/10/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData


protocol ProtocoloVCEstadisticaColorAlarma {
    
    func actualizaDatos(nuevoElemento:Bool)
    func vuelveDeVCEstColAlar()
    func muestraSeleccionadosDesdeEstadistica(unFollowThingEnvio:UnFollowThing)
}

class VCAlarmaEstadisticaColor: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {

    @IBOutlet var etiquetaTitulo: UILabel!
    @IBOutlet var botonRepetir: UIButton!
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var contenedorAlarma: UIView!
    @IBOutlet var etiquetaTituloAlarma: UILabel!
    @IBOutlet var switchAlarma: UISwitch!
    @IBOutlet var pickerAlarma: UIPickerView!
    @IBOutlet var etiquetaExisteAlarma: UILabel!
    @IBOutlet var vistaContenedorInfoAlarma: UIView!
    @IBOutlet var btnCancelar: UILabel!
    
    @IBOutlet var etiquetaSubInfoAlarma: UILabel!
    @IBOutlet var vistaCabeceraAlarma: UIView!
    @IBOutlet var botonAlarma: UIButton!
    
    @IBOutlet var contenedorColor: UIView!
    @IBOutlet var etiquetaTituloColor: UILabel!
    @IBOutlet var collectionColor: UICollectionView!
    @IBOutlet var vistaCabeceraColor: UIView!
    
    
    @IBOutlet var contenedorEstadistica: UIView!
    @IBOutlet var etiquetaTituloEstadistica: UILabel!
    @IBOutlet var etiquetaPromedio: UILabel!
    @IBOutlet var etiquetaVecesRepetido: UILabel!
    @IBOutlet var etiquetaUltimaAnotacion: UILabel!
    @IBOutlet var vistaCabeceraEstadistica: UIView!
    @IBOutlet var vistaContenidoEstadistica: UIView!
    
   
    
    var mostrarContenedorEstadistica:Bool = false
    var mostrarContenedorAlarma:Bool = false
    var mostrarContenedorColor:Bool = false
    
    var editarHorasMinutos:Bool = false
    
    var diasPicker:Int = 0
    var horas:Int = 12
    var minutos:Int = 0

    var diasPickerMatriz:[Int] = []
    var horasPickerMatriz:[Int] = []
    var minutosPickerMatriz:[Int] = []
    
    var fechaDeAlarma = DateComponents()
    var fechaDeNotificacionProxima = Date()
    var fechaAlarmaDB = Date()
    
    var delegado:ProtocoloVCEstadisticaColorAlarma? = nil
    
    public var unFollowThing:[UnFollowThing] = []
    public var followThing:FollowThing!
    public var unFTEstadistica:[UnFollowThing] = []
    public var todasAlarmas:[AlarmasUnFT] = []
    public var alarmaUnFT:AlarmasUnFT!
    
    public var titulo:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().delegate = self
        compruebaSiExisteAlarma()
        
        iniciaConfiguraciones()

        recuperaEstadoContenedores()
        estadoAlarma(alarma: recuperaAlarmasDB())
        
       view.addBlurEffectFondo()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
    }
    func compruebaSiExisteAlarma(){

        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("TODAS LAS ALARMAS",request)
            }
        })
       
        let identificadorAlarma = "\(self.followThing.titulo!):\(self.etiquetaTitulo.text!)"
    
        let consultaSiExiste = UNUserNotificationCenter.current()
        consultaSiExiste.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                               
                if request.identifier == identificadorAlarma {
                    
                    let lanzadorNotificacion = request.trigger  as! UNCalendarNotificationTrigger
                    let localFecha = lanzadorNotificacion.dateComponents
                    
                    self.fechaDeNotificacionProxima = NSCalendar.current.date(from: localFecha)!

                    print("*Alarmas Reales:",request.identifier,localFecha)
                }
            }
        })
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
     
        
    }
    func lanzadorAlarmasOtroVC(){
        
    }
//    MARK:- CONFIGURACIONES
    func configuraEtiquetaInicial(){
        
        etiquetaTitulo.font = fuenteVisorTitulo
        etiquetaTitulo.text = titulo
        etiquetaTitulo.textColor = coloresAnotacion[Int(unFTEstadistica.first!.colorAnotacion)]
        
        etiquetaTitulo.sombraLargaVista()
        
    }
    func configuraBotonesAlarmaColor(){
        
        botonRepetir.redondear()
        botonRepetir.backgroundColor = verdeBtnAlarma

    }
    func configuraContenedorAlarma(){
        
        contenedorAlarma.borders(for: [.all], width: 0.5, color: .gray)
        contenedorEstadistica.borders(for: [.all], width: 0.5, color: .gray)
        contenedorColor.borders(for: [.all], width: 0.5, color: .gray)
        
        contenedorAlarma.heightConstraint?.constant = 49
        contenedorColor.layoutIfNeeded()
        
        contenedorAlarma.backgroundColor = colorFondoContenedores
        vistaCabeceraAlarma.backgroundColor = colorFondoTituloContenedores
  
        pickerAlarma.dataSource = self
        pickerAlarma.delegate = self
        
        etiquetaTituloAlarma.font = fuenteTituloContendores
        etiquetaTituloAlarma.text = "Recordar en..."
        etiquetaTituloAlarma.backgroundColor = .clear
        etiquetaTituloAlarma.textColor = .darkGray
        

        etiquetaExisteAlarma.backgroundColor = .clear
        etiquetaExisteAlarma.font = fuenteContendorInformativoGrande
        etiquetaExisteAlarma.textAlignment = .center
      
        etiquetaSubInfoAlarma.font = fuenteTextField
        etiquetaSubInfoAlarma.textColor = .systemBlue
        etiquetaSubInfoAlarma.textAlignment = .center
     
        btnCancelar.textColor = .systemBlue
        
        botonAlarma.redondear()
        
        vistaContenedorInfoAlarma.alpha = 0
        vistaContenedorInfoAlarma.backgroundColor = .clear
        
        
//        botonAlarma.alpha = 0
    }
    func configuraContenedorColor(){
        
        contenedorColor.heightConstraint?.constant = 49
        contenedorColor.layoutIfNeeded()
        contenedorColor.backgroundColor = colorFondoContenedores
        vistaCabeceraColor.backgroundColor = colorFondoTituloContenedores
        
        collectionColor.delegate = self
        collectionColor.dataSource = self
        collectionColor.backgroundColor = .clear
                
        etiquetaTituloColor.font = fuenteTituloContendores
        
        etiquetaTituloColor.text = "Color anotación..."
        etiquetaTituloColor.backgroundColor = .clear
        etiquetaTituloColor.textColor = .darkGray
        

        
        contenedorColor.sombraLargaVista()
    }
    func configuraContenedorEstadistica(){
        
        contenedorEstadistica.grandienteVertical(color01: colorFondoContenedores, color02: .white)
        contenedorAlarma.grandienteVertical(color01: colorFondoContenedores, color02: .white)
        contenedorColor.grandienteVertical(color01: colorFondoContenedores, color02: .white)
        
        
        
        contenedorEstadistica.heightConstraint?.constant = 49
        contenedorEstadistica.layoutIfNeeded()
        
        contenedorEstadistica.backgroundColor = colorFondoContenedores
        vistaCabeceraEstadistica.backgroundColor = colorFondoTituloContenedores
        
       
        etiquetaTituloEstadistica.font = fuenteTituloContendores
        etiquetaTituloEstadistica.text = "Estadísticas..."
        etiquetaTituloEstadistica.backgroundColor = .clear
        etiquetaTituloEstadistica.textColor = .darkGray

//        Promedio
        
        let diaTotal = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date())
        let diaUltimo = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: unFTEstadistica.first!.fechaCreacionUnFT!)
       
        let promedio = CGFloat(unFTEstadistica.count) / CGFloat((diaTotal + 1))
        let promedioUltimo = CGFloat(unFTEstadistica.count) / CGFloat(diaUltimo+1)
      
        let promedioS = String(format: "%01.2f", promedio)
        let promedioUltimoS = String(format: "%01.2f", promedioUltimo)
        
        etiquetaPromedio.text = "El impacto promedio en los \(diaTotal) días es del " + promedioS + "%\nEl impacto hasta la última entrada es \(promedioUltimoS)%"
        
        etiquetaPromedio.textColor = .gray
        etiquetaVecesRepetido.textColor = .gray
        etiquetaUltimaAnotacion.textColor = .gray
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.green]

            let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.white]

            let attributedString1 = NSMutableAttributedString(string:"Drive", attributes:attrs1)

            let attributedString2 = NSMutableAttributedString(string:"safe", attributes:attrs2)

            attributedString1.append(attributedString2)
//            self.lblText.attributedText = attributedString1
      
//        Veces repetido
        
        let diasTranscurridos = Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date())
        if unFTEstadistica.count == 1 {
             etiquetaVecesRepetido.text = "\(unFTEstadistica.count) vez en \(diasTranscurridos) días"
        }
        else {
             etiquetaVecesRepetido.text = "\(unFTEstadistica.count) veces en \(diasTranscurridos) días"
        }
//      Ultima vez
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(VCAlarmaEstadisticaColor.tapFunction))
                etiquetaUltimaAnotacion.isUserInteractionEnabled = true
                etiquetaUltimaAnotacion.addGestureRecognizer(tap)
        
        let diasDesdeUltimaVez = Fechas.calculaDiasEntreDosFechas(start: (unFTEstadistica.first?.fechaCreacionUnFT)!, end: Date())
        
        if diasTranscurridos == 1 {
             etiquetaUltimaAnotacion.text = "La última vez fue hace \(diasDesdeUltimaVez) día"
            let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.gray]
            let attributedString1 = NSMutableAttributedString(string: "La última vez fue hace \(diasDesdeUltimaVez) día.", attributes:attrs1)
            let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
            let attributedString2 = NSMutableAttributedString(string:"Mostrar", attributes:attrs2)
            attributedString1.append(attributedString2)
            etiquetaUltimaAnotacion.attributedText = attributedString1
        }
        else {
             etiquetaUltimaAnotacion.text = "La última vez fue hace \(diasDesdeUltimaVez) días"
            let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.gray]
            let attributedString1 = NSMutableAttributedString(string: "La última vez fue hace \(diasDesdeUltimaVez) días.", attributes:attrs1)
            let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
            let attributedString2 = NSMutableAttributedString(string:"Mostrar", attributes:attrs2)
            attributedString1.append(attributedString2)
            etiquetaUltimaAnotacion.attributedText = attributedString1
        }
        
//        vistaContenidoEstadistica.alpha = 0
    }
    
    func iniciaConfiguraciones(){
        
        preparaMatrizAnotacion()
        preparaMatrizDiasAlarma()
        preparaMatrizHorasMinutos()
        
        configuraEtiquetaInicial()
        configuraBotonesAlarmaColor()
        configuraContenedorAlarma()
        configuraContenedorColor()
        configuraContenedorEstadistica()
    }
    //    MARK:-ESTADOS
    func muestraEstadisticaAlarmaColor(vista:Int){
        
        switch vista {
        case 0:
            UIView.animate(withDuration: 0.2) {
                
                self.contenedorColor.translatesAutoresizingMaskIntoConstraints = false
                self.contenedorColor.heightConstraint?.constant = 0
                
                self.contenedorAlarma.translatesAutoresizingMaskIntoConstraints = false
                self.contenedorAlarma.heightConstraint?.constant = 0
                
                self.view.layoutIfNeeded()
            }
        case 1:
            cambiaConstrainAltura(vista01: self.contenedorAlarma, vista02: self.contenedorColor, altura: 240)
        case 2:
            cambiaConstrainAltura(vista01: self.contenedorColor, vista02: self.contenedorAlarma, altura: 240)
            
        default:
            break
        }
    }
    func cambiaConstrainAltura(vista01:UIView,vista02:UIView, altura:CGFloat){
        
        UIView.animate(withDuration: 0.20, animations: {
            
            if vista02.heightConstraint?.constant != 0 {
                vista02.translatesAutoresizingMaskIntoConstraints = false
                
                vista02.heightConstraint?.constant = 0
                self.view.layoutIfNeeded()
            }
        }) { (completion) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                
                vista01.translatesAutoresizingMaskIntoConstraints = false
                
                UIView.animate(withDuration: 0.40, animations: {
                    vista01.heightAnchor.constraint(equalToConstant: altura).isActive = true
                    vista01.heightConstraint?.constant = altura
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    //    MARK:- ACCION BOTONES
    var repetirAnotacionUnaVez:Bool = false
    @IBAction func tapMostrarTodasAnotaciones(_ sender: Any) {
     
      
        let generator = UIImpactFeedbackGenerator(style: .medium)
               generator.impactOccurred()
        etiquetaTitulo.superRebotar()
        self.delegado?.muestraSeleccionadosDesdeEstadistica(unFollowThingEnvio: unFTEstadistica.first!)
        
        self.performSegueToReturnBack()
        
    }
    
    @IBAction func tapReptieAnotacion(_ sender: Any) {
        if !repetirAnotacionUnaVez {
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            etiquetaTitulo.superRebotar()
            crearAnotacionExistente()
            repetirAnotacionUnaVez = true
        }
    }
    @IBAction func tapCancelar(_ sender: Any) {
        
        if editarHorasMinutos {
            editarHorasMinutos = false
            pickerAlarma.reloadAllComponents()
            estadoAlarma(alarma: recuperaAlarmasDB())
            btnCancelar.isHidden = true
            
        }
        if alarmaUnFT.completado == true {
            borrarAlarmasDB()
            estadoAlarma(alarma: recuperaAlarmasDB())
            btnCancelar.isHidden = true
        }
    }
    @IBAction func tapHoraAlarma(_ sender: Any) {
        
        if !editarHorasMinutos {
            editarHorasMinutos = true
            pickerAlarma.reloadAllComponents()
            estadoAlarma(alarma: recuperaAlarmasDB())
            btnCancelar.isHidden = false
        }
    }
    func opcionesBtnAlarma(recuperarAlarma:Bool,editarHorasMinutos:Bool)->Int {
        
        var opcion:Int = 0
        
        var completado:Bool = false
        
        if alarmaUnFT != nil {
            if alarmaUnFT.completado == true {
                completado = true
            }
        }
        
        if recuperarAlarma && !editarHorasMinutos  && !completado {
            opcion = 1
            
        }
        if !recuperarAlarma && !editarHorasMinutos  && !completado{
            opcion = 2
        }
        if  recuperarAlarma && editarHorasMinutos && !completado {
            opcion = 3
        }
        if recuperarAlarma && !editarHorasMinutos && completado {
            opcion = 4
        }
        
   
    return opcion
        
    }
    @IBAction func botonAlarma(_ sender: Any) {
    
        let opcion = opcionesBtnAlarma(recuperarAlarma: recuperaAlarmasDB(), editarHorasMinutos: editarHorasMinutos)
        
        estadoAlarma(alarma: recuperaAlarmasDB())
        botonAlarma.animadoVibracionMedio()
        
        switch opcion {
        case 1:
            
            preparaAlarmaSugerencia(dia: diasPickerMatriz[0])
            
            let dia = Fechas.calculaDiasEntreDosFechas(start: Date(), end: alarmaUnFT.fechaAlarma!)
            
            if dia >= 0 || dia <= 30 {
                pickerAlarma.selectRow(dia, inComponent: 0, animated: true)
                preparaAlarmaSugerencia(dia: dia)
            }
            
            borrarAlarmasDB()
            estadoAlarma(alarma: recuperaAlarmasDB())
        case 2:
            creaUnaAlarmaDB(fecha: fechaAlarmaDB)
            estadoAlarma(alarma: recuperaAlarmasDB())
        case 3:
            UserDefaults.standard.set(horas, forKey: "hora")
            UserDefaults.standard.setValue(minutos, forKey: "minutos")
            alarmaUnFT.fechaAlarma = fechaAlarmaDB
            actualizaDatosDB()
            editarHorasMinutos = false
            btnCancelar.isHidden = true
            pickerAlarma.reloadAllComponents()
            estadoAlarma(alarma: recuperaAlarmasDB())
            self.estableceAlarmas()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
                
                self.estadoAlarma(alarma: self.recuperaAlarmasDB())
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                
                self.compruebaSiExisteAlarma()
                
            }
        case 4:
            borrarAlarmasDB()
            crearAnotacionExistente()
            
        default:
            break
        }
        
        delegado?.vuelveDeVCEstColAlar()

    }
    func estadoAlarma(alarma:Bool){
        
//        Estado visual del contendor recordatorio
        
        let opcion = opcionesBtnAlarma(recuperarAlarma: recuperaAlarmasDB(), editarHorasMinutos: editarHorasMinutos)
      
        
        switch opcion {
        case 1:
//            Activa la alarma por primera vez
            
            etiquetaSubInfoAlarma.isUserInteractionEnabled = true
            etiquetaSubInfoAlarma.textColor = .link
            vistaContenedorInfoAlarma.iluminar()
            pickerAlarma.desiluminar()
            botonAlarma.setTitle("Desactivar", for: .normal)
            botonAlarma.backgroundColor = rojoBtnAlarma
            
            let hora = NSCalendar.current.component(.hour, from: alarmaUnFT.fechaAlarma!)
            let minuto = NSCalendar.current.component(.minute, from: alarmaUnFT.fechaAlarma!)
           
            horas = hora
            minutos = minuto
                      
            let ceroIzquierda:String = String(format: "%02d", minuto)
            etiquetaSubInfoAlarma.text = "a las \(hora):" + ceroIzquierda + " horas"
        case 2:
//            Desactiva la alarma
            
            etiquetaSubInfoAlarma.isUserInteractionEnabled = false
            vistaContenedorInfoAlarma.desiluminar()
            pickerAlarma.iluminar()
            botonAlarma.setTitle("Activar", for: .normal)
            botonAlarma.backgroundColor = verdeBtnAlarma
            
        case 3:
//            La alarma ya lanzada permite cambiar la hora
            
            etiquetaSubInfoAlarma.isUserInteractionEnabled = false
            let hora = NSCalendar.current.component(.hour, from: alarmaUnFT.fechaAlarma!)
            let minuto = NSCalendar.current.component(.minute, from: alarmaUnFT.fechaAlarma!)
    
            horas = hora
            minutos = minuto
            
            pickerAlarma.selectRow(horas, inComponent: 0, animated: true)
            pickerAlarma.selectRow(minutos, inComponent: 1, animated: true)

            vistaContenedorInfoAlarma.desiluminar()
            pickerAlarma.iluminar()
            botonAlarma.setTitle("Modificar", for: .normal)
            botonAlarma.backgroundColor = .orange
        case 4:
//            La alarma está excedida, el usuario sólo puede añadir la anotación o borrarla
            
            etiquetaSubInfoAlarma.isUserInteractionEnabled = false
            etiquetaSubInfoAlarma.textColor = .darkGray
            etiquetaSubInfoAlarma.text = "Estaba programado para las \(horas):\(minutos)"
            vistaContenedorInfoAlarma.iluminar()
            pickerAlarma.desiluminar()
            botonAlarma.backgroundColor = .orange
            botonAlarma.setTitle("Añadir", for: .normal)
            btnCancelar.isHidden = false
        default:
            break
        }

        
    }
    @IBAction func botonRepetir(_ sender: Any) {
        
      
        botonRepetir.pulsarAnimadoVibracion()
        crearAnotacionExistente()
       
    }
    
    @IBAction func tapEstadistica(_ sender: Any) {
       
        contenedorEstadistica.animadoVibracionMedio()
        
        if !mostrarContenedorEstadistica {
            aumentaTamañoContenedor(contenedor: contenedorEstadistica, altura: 240,vistaCabecera: vistaCabeceraEstadistica)
            mostrarContenedorEstadistica = true
           
        }
        else
        {
            reduceTamañoContenedor(contenedor: contenedorEstadistica, altura: 49,vistaCabecera: vistaCabeceraEstadistica)
            mostrarContenedorEstadistica = false
           
        }
        UserDefaults.standard.set(mostrarContenedorEstadistica, forKey: "tapEstadistica")
          
    }
    @IBAction func tapAlarma(_ sender: Any) {
        
        contenedorAlarma.animadoVibracionMedio()
        
        if !mostrarContenedorAlarma {
            aumentaTamañoContenedor(contenedor: contenedorAlarma, altura: 240,vistaCabecera: vistaCabeceraAlarma)
          
            mostrarContenedorAlarma = true
            
            if mostrarContenedorEstadistica  {
        
                let bottomOffset = CGPoint(x: 0, y: contenedorAlarma.frame.origin.y)
            scroll.setContentOffset(bottomOffset, animated: true)
            }
        }
        else {
            reduceTamañoContenedor(contenedor: contenedorAlarma, altura: 49,vistaCabecera: vistaCabeceraAlarma)
          
            mostrarContenedorAlarma = false
        }
        UserDefaults.standard.set(mostrarContenedorAlarma, forKey: "tapAlarma")
    }
    @IBAction func tapColor(_ sender: Any) {
      
        contenedorColor.animadoVibracionMedio()
        
        if !mostrarContenedorColor {
            aumentaTamañoContenedor(contenedor: contenedorColor, altura: 240,vistaCabecera: vistaCabeceraColor)
            mostrarContenedorColor = true
           
            if mostrarContenedorEstadistica || mostrarContenedorAlarma {
        
                let bottomOffset = CGPoint(x: 0, y: scroll.contentSize.height - scroll.bounds.size.height)
            scroll.setContentOffset(bottomOffset, animated: true)
            }
        }
        else {
            reduceTamañoContenedor(contenedor: contenedorColor, altura: 49,vistaCabecera: vistaCabeceraColor)
            mostrarContenedorColor = false
        }
        UserDefaults.standard.set(mostrarContenedorColor, forKey: "tapColor")
    }
    func aumentaTamañoContenedor(contenedor:UIView,altura:CGFloat,vistaCabecera:UIView){
        
        contenedor.translatesAutoresizingMaskIntoConstraints = false
        contenedor.frame.size.height = contenedor.frame.size.height + 191
        
        contenedor.heightAnchor.constraint(equalToConstant: altura).isActive = true
        contenedor.heightConstraint?.constant = altura
      
        UIView.animate(withDuration: 0.25, animations: {
          
            self.view.layoutIfNeeded()
        })
        vistaCabecera.borders(for: [.bottom], width: 0.5, color: .gray)
    }
    func reduceTamañoContenedor(contenedor:UIView,altura:CGFloat,vistaCabecera:UIView){
     
        contenedor.translatesAutoresizingMaskIntoConstraints = false
        
        UIView.animate(withDuration: 0.20, animations: {
            
            if contenedor.heightConstraint?.constant != altura {
                
                
                contenedor.heightConstraint?.constant = altura
                self.scroll.layoutIfNeeded()
                self.stackView.layoutIfNeeded()
            }
        })
        vistaCabecera.borders(for: [.bottom], width: 0.0, color: .clear)
        
    }
    func recuperaEstadoContenedores(){
        
        mostrarContenedorColor = UserDefaults.standard.bool(forKey: "tapColor")
        mostrarContenedorEstadistica = UserDefaults.standard.bool(forKey: "tapEstadistica")
        mostrarContenedorAlarma = UserDefaults.standard.bool(forKey: "tapAlarma")
        
        if mostrarContenedorEstadistica {
            aumentaTamañoContenedor(contenedor: contenedorEstadistica, altura: 240,vistaCabecera: vistaCabeceraEstadistica)
        }
        if mostrarContenedorColor {
           aumentaTamañoContenedor(contenedor: contenedorColor, altura: 240,vistaCabecera: vistaCabeceraColor)
        }
        if mostrarContenedorAlarma {
            aumentaTamañoContenedor(contenedor: contenedorAlarma, altura: 240,vistaCabecera: vistaCabeceraAlarma)
        }
    }
        
    
    //    MARK:- ESTADISTICA
    @objc
        func tapFunction(sender:UITapGestureRecognizer) {
          
            self.delegado?.muestraSeleccionadosDesdeEstadistica(unFollowThingEnvio: unFTEstadistica.first!)
            
            self.performSegueToReturnBack()
        }
    func preparaMatrizHorasMinutos(){
        
        for horas in 1...24 {
            horasPickerMatriz.append(horas-1)
        }
        for minutos in 1...60 {
            
            minutosPickerMatriz.append(minutos-1)
        }
        
    }
    func preparaMatrizDiasAlarma(){
       
        var unFTEstadisticaDias:[UnFollowThing] = []
        
        for busquedaDias in 1...unFTEstadistica.count {
            
            let diaMaster = Fechas.calculaDiasEntreDosFechas(start: unFTEstadistica[busquedaDias-1].fechaCreacionUnFT!, end: Date())
            
            if unFTEstadisticaDias.count == 0 {
                
                unFTEstadisticaDias.append(unFTEstadistica[busquedaDias-1])
            }
            else {
                
                let diaReferencia = Fechas.calculaDiasEntreDosFechas(start: unFTEstadisticaDias.last!.fechaCreacionUnFT!, end: Date())
                    
                    if diaMaster != diaReferencia {
                        unFTEstadisticaDias.append(unFTEstadistica[busquedaDias-1])
                }
            }
        }
        let intervaloFinal =  Fechas.calculaDiasEntreDosFechas(start: followThing.fechaCreacion!, end: Date()) / unFTEstadisticaDias.count
        let diasDesdeUltimaVez = Fechas.calculaDiasEntreDosFechas(start: (unFTEstadistica.first?.fechaCreacionUnFT)!, end: Date())
        
        let diaSugerido = intervaloFinal - diasDesdeUltimaVez
        
        if diaSugerido < 0 {
            diasPickerMatriz.append(0)
        } else {
            diasPickerMatriz.append(diaSugerido)
        }
        
        ajustaHoraMinutoAlarmaHoy()
        preparaAlarmaSugerencia(dia: diasPickerMatriz[0])
       
        
        for _ in 1...30 {
            diasPicker += 1
            diasPickerMatriz.append(diasPicker)
        }
    }
    func ajustaHoraMinutoAlarmaHoy(){
        
        let hora = NSCalendar.current.component(.hour, from: Date())
        let minuto = NSCalendar.current.component(.minute, from: Date())
        
        horas = hora
        minutos = minuto + 5
        
        if minuto > 55 && minuto < 59 {
            
            horas = hora + 1
            minutos = 0
        }
    }
    func preparaMatrizAnotacion () {
        
        if unFollowThing.count > 0 {
            
            for busquedaAnotacion in 1...unFollowThing.count {
                
                if unFollowThing[busquedaAnotacion-1].anotaciones == titulo {
                    
                    unFTEstadistica.append(unFollowThing[busquedaAnotacion-1])
                    
                }
            }
        }
    }
    func asignaColorAnotacionTipo(colorAnotacion:Int16) {
        
        if unFollowThing.count > 0 {
            for busquedaAnotacion in 1...unFollowThing.count {
                if unFollowThing[busquedaAnotacion-1].anotaciones == titulo {
                    unFollowThing[busquedaAnotacion-1].colorAnotacion = colorAnotacion
                    unFollowThing[busquedaAnotacion-1].fechaUltimaModificacion = Date()
                }
            }
        }
        actualizaDatosDB()
    }
    //    MARK:-COLLECTION VIEW COLORES
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return coloresAnotacion.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellColores", for: indexPath) as! CollectionViewCellColores
            
            cell.vistaCeldaColores.backgroundColor = coloresAnotacion[indexPath.row]
            cell.vistaCeldaColores.redondearVista()
            cell.vistaCeldaColores.layer.borderWidth = 0.5
            cell.vistaCeldaColores.layer.borderColor = UIColor.lightGray.cgColor
            cell.etiquetaColoresCell.text = ""
            
            return cell
        }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellColores", for: indexPath) as! CollectionViewCellColores
        
        //                let indexUnFT = unFollowThing[indexPath.row]
        asignaColorAnotacionTipo(colorAnotacion: Int16(indexPath.row))
        
        cell.vistaCeldaColores.layer.borderWidth = 2.0
        cell.vistaCeldaColores.layer.borderColor = UIColor.gray.cgColor
        
        etiquetaTitulo.textColor = coloresAnotacion[indexPath.row]
        
        etiquetaTitulo.superRebotar()
        
        self.delegado?.actualizaDatos(nuevoElemento: false)
        
        //           seleccionColor = indexPath.row
        
    }
//    MARK:-ALARMAS AL SISTEMA
    func borrarAlarmasUnFT(){
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { [self] (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier.contains("\(followThing.titulo!)") {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    @objc func estableceAlarmas() {
        
        DispatchQueue.background(delay: 0.3, completion:{ [self] in
        
            self.borrarAlarmasUnFT()
        
        var titulo:String = followThing.titulo!
        
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),self.followThing.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            let followThingDB = resultado.first
            todasAlarmas = (followThingDB?.alarmaUnFTSet?.sortedArray(using: [NSSortDescriptor(key: "tituloAlarma", ascending: false)])) as! [AlarmasUnFT]
            
            titulo = followThingDB!.titulo!
            
        } catch let error as NSError {
            print("error cargar DB",error)
        }
        
        if todasAlarmas.count > 0 {
            
            for alarma in 1...self.todasAlarmas.count {
                
                print("Lanzada:",self.todasAlarmas[alarma-1].tituloAlarma!)
                print("Lanzada:",self.todasAlarmas[alarma-1].fechaAlarma!)
                
                lanzaNotificacion(titulo: titulo, subTitulo: self.todasAlarmas[alarma-1].tituloAlarma!, cuerpo: "Recuerda incluir esta anotación", fecha: Alarmas.obtenFechaComponenteAlarma(fecha: self.todasAlarmas[alarma-1].fechaAlarma!))
                
            }
            
        }
        })
    }
    
    func lanzaNotificacion(titulo:String,subTitulo:String,cuerpo:String, fecha:DateComponents){
        
        let solicitud = Alarmas.lanzaNotificacionLocal(titulo: titulo, subTitulo: subTitulo, cuerpo: cuerpo, fecha: fecha)
        print("Alarma:"+titulo+" de "+subTitulo)
        
        print("solicitud:",solicitud)
        UNUserNotificationCenter.current().add(solicitud, withCompletionHandler: {(error) in
            if let error = error {
                print("error al lanzar notificacion: ",error)
            }
        })
        compruebaSiExisteAlarma()
    
    }
    func compruebaNotificacionEnCurso(){
        
        let identificadorAlarma = "\(self.followThing.titulo!):\(self.etiquetaTitulo.text!)"
        
        let consultaSiExiste = UNUserNotificationCenter.current()
        consultaSiExiste.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                
                if request.identifier == identificadorAlarma {
                    
                    let lanzadorNotificacion = request.trigger  as! UNCalendarNotificationTrigger
                    let localFecha = lanzadorNotificacion.dateComponents
                    
                    self.fechaDeNotificacionProxima = NSCalendar.current.date(from: localFecha)!
                    
                    print("*Bingo Alarmas Reales:",request.identifier,localFecha)
                }
            }
        })
    }
    
    //MARK:-ALARMA
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = fuenteTablaAnotaciones
            pickerLabel?.textAlignment = .center
            
        }
        if editarHorasMinutos {
            
            
            switch component {
            case 0:
                pickerLabel?.textColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.gray : UIColor.gray
                
                pickerLabel?.textAlignment = .right
                pickerLabel?.text = "\(horasPickerMatriz[row])  "
            case 1:
                pickerLabel?.textColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.gray : UIColor.gray
                pickerLabel?.textAlignment = .left
                let ceroIzquierda:String = String(format: "  %02d", minutosPickerMatriz[row])
                pickerLabel?.text = ceroIzquierda
                
               
            default:
                break
            }
        }
        else {
            pickerLabel?.textColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.gray : UIColor.gray
            if row == 0 {
                if diasPickerMatriz[row] <= 0 {
                    pickerLabel?.text = "Sugerencia : HOY"
    
                }
                else {
                    pickerLabel?.text = "Sugerencia \(diasPickerMatriz[row]) días"
                }
            }
            else {
                pickerLabel?.text = "\(diasPickerMatriz[row]) días"
            }
            pickerLabel?.textColor = .black
        }
        return pickerLabel!
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if editarHorasMinutos {
            return 2
        }
        else {
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if editarHorasMinutos {
            
            switch component {
            case 0:
                return 24
            case 1:
                return 60
            default:
                return 1
            }
        }
        else {
            return 31
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        
        if !editarHorasMinutos {
            preparaAlarmaSugerencia(dia: diasPickerMatriz[row])
            
        }
        else {
            switch component {
            case 0:
                horas = row
            case 1:
                minutos = row
            default:
                break
            }
        
            modificaHoraAlarma(hora: horas, minuto: minutos)
            
        }
        
    }
    func modificaHoraAlarma(hora:Int,minuto:Int) {
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: Date(), end: alarmaUnFT.fechaAlarma!)
        
        var dayComponent    = DateComponents()
        dayComponent.day    = dia
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
        
        
        let calendar = Calendar.current
        calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate!)
        
        fechaDeAlarma.hour = hora
        fechaDeAlarma.minute = minuto
        fechaDeAlarma.day = calendar.component(.day, from: nextDate!)
        fechaDeAlarma.month = calendar.component(.month, from: nextDate!)
        fechaDeAlarma.year = calendar.component(.year, from: nextDate!)
        
        fechaAlarmaDB =  NSCalendar.current.date(from: fechaDeAlarma)!
        
    }
    func preparaAlarmaSugerencia(dia:Int){
                 
        var dayComponent    = DateComponents()
        dayComponent.day    = dia
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
        
        
        let calendar = Calendar.current
        calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate!)
        
        fechaDeAlarma.hour = horas
        fechaDeAlarma.minute = minutos
        fechaDeAlarma.day = calendar.component(.day, from: nextDate!)
        fechaDeAlarma.month = calendar.component(.month, from: nextDate!)
        fechaDeAlarma.year = calendar.component(.year, from: nextDate!)
        
        
        fechaAlarmaDB =  NSCalendar.current.date(from: fechaDeAlarma)!
       
    }
    
    //    MARK: - FUNCIONES COREDATA
    
    func conexion () -> NSManagedObjectContext {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
        
    }
    func actualizaDatosDB() {
        do {
            try conexion().save()
            print("Guardado con éxito")
            
            
        } catch let error as NSError {
            print("Error al guardar: ",error)
        }
    }
    func creaUnaAlarmaDB(fecha:Date){
        
        let contexto = conexion()
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThing.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThing = resultado.first
            
        } catch let error as NSError {
            print("error",error)
        }
        
        let entidadAlarma = NSEntityDescription.insertNewObject(forEntityName: "AlarmasUnFT", into: contexto) as! AlarmasUnFT
        
        entidadAlarma.tituloAlarma = etiquetaTitulo.text!
        entidadAlarma.fechaAlarma = fecha
        entidadAlarma.fechaCreacionAlarma = Date()
        entidadAlarma.completado = false
        
        followThing.mutableSetValue(forKey: "alarmaUnFTSet").add(entidadAlarma)
        
        do {
            try contexto.save()
        } catch let error as NSError {
            print("No ha podido guardas la alarma:",error)
        }
        
    }
    func recuperaAlarmasDB()->Bool{
        
        var existe:Bool = false
        
        let alarmaBuscar = etiquetaTitulo.text!
        
//        todasAlarmas = Alarmas.leerAlarmaDB(followThing: followThing, unFollowThing: unFollowThing)
        
        let funcionesAlarmaDB = AlarmaDB.init()
        
        todasAlarmas = funcionesAlarmaDB.leerAlarmaDB(followThing: followThing, unFollowThing: unFollowThing)
        todasAlarmas = funcionesAlarmaDB.compruebaAlarmaIncluida(unFT: unFollowThing, alarmaFT: todasAlarmas, followThing: followThing)
        todasAlarmas = funcionesAlarmaDB.compruebaFechaExcedida(alarmas: todasAlarmas, followThing: followThing, unFollowThing: unFollowThing)
        
        
        if todasAlarmas.count > 0 {
            for alarma in 1...todasAlarmas.count {
                if todasAlarmas[alarma-1].tituloAlarma == alarmaBuscar {
                    alarmaUnFT = todasAlarmas[alarma-1]
                    let dia = Fechas.calculaDiasEntreDosFechas(start: Date(), end: alarmaUnFT.fechaAlarma!)
                    etiquetaExisteAlarma.text = "en \(dia) días"
                    
                    if dia <= 0 {
                        alarmaExcedida(dia: dia)
                        horas = NSCalendar.current.component(.hour, from: alarmaUnFT.fechaAlarma!)
                        minutos = NSCalendar.current.component(.minute, from: alarmaUnFT.fechaAlarma!)
                    }
                    existe = true
                }
            }
        }
        return existe
    }
    
    func alarmaExcedida(dia:Int){
        
        let diaPositivo = abs(dia)
        
        if dia == 0 {
            
            etiquetaExisteAlarma.text = "Hoy"
            
            let fechaActual = Date()
            if fechaActual > alarmaUnFT.fechaAlarma! {
                alarmaUnFT.completado = true
            }
            
        }
        if dia == -1 {
            alarmaUnFT.completado = true
            etiquetaExisteAlarma.text = "Ayer"
            
        }
        if dia < -1 {
            alarmaUnFT.completado = true
            etiquetaExisteAlarma.text = "hace \(diaPositivo) días"
        }
    }
    func borrarAlarmasDB(){
        
        let tituloAlarma = etiquetaTitulo.text!
        Alarmas.borrarAlarmaDB(tituloAlarma: tituloAlarma, alarmaFT: todasAlarmas)
    }
    func crearAnotacionExistente(){
        
        let contexto = conexion()
        let fetch:NSFetchRequest<FollowThing> = FollowThing.fetchRequest()
        
        fetch.predicate = NSPredicate (format: "%K == %@", #keyPath(FollowThing.id_FollowThing),followThing.id_FollowThing! as CVarArg)
        
        do {
            let resultado = try conexion().fetch(fetch)
            followThing = resultado.first
            followThing.fechaUltimaEntrada = Date()
            
        } catch let error as NSError {
            print("error",error)
        }
        
        let entidadUnFollowThing = NSEntityDescription.insertNewObject(forEntityName: "UnFollowThing", into: contexto) as! UnFollowThing
        
        entidadUnFollowThing.anotaciones = unFTEstadistica.first!.anotaciones
        entidadUnFollowThing.fechaCreacionUnFT = Date()
        entidadUnFollowThing.colorAnotacion = unFTEstadistica.first!.colorAnotacion
        
        followThing.fechaUltimaEntrada = Date()
        followThing.mutableSetValue(forKey: "unFollowThingSet").add(entidadUnFollowThing)
        
        do {
            try contexto.save()
            delegado?.actualizaDatos(nuevoElemento: true)
            performSegueToReturnBack()
            
        } catch let error as NSError {
            print("no guardo anotación :", error)
        }
        
    }
    
}
extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}
