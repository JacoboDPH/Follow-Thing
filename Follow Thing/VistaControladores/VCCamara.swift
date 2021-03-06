//
//  VCCamara.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 19/08/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import CoreMotion



class VCCamara: UIViewController, AVCapturePhotoCaptureDelegate, UIPopoverPresentationControllerDelegate, VCResultadoCamProtocolo {
    func botonGuardarPulsado() {
        performSegueToReturnBack()
    }
    

//    MARK:- IBOULET
    
    @IBOutlet var botonCamaraFrontal: UIButton!
    @IBOutlet var botonFlash: UIButton!
    @IBOutlet var botonCamara: UIButton!
    @IBOutlet var etiquetaDia: UILabel!
    @IBOutlet var etiquetaDiaSubtitulo: UILabel!
    @IBOutlet var fotoPatron: UIImageView!
    @IBOutlet var botonPatronFoto: UIButton!
    
    
//    MARK:- VARIABLES
    
    public var unFTDB:[UnFollowThing] = []
    public var followThingDesdeSec:FollowThing!
    private var matrizFotos:[UnFollowThing] = []
    
   
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage?
    
    
    
    var fotoPatronEncendido:Bool = false
    
//    MARK:-VARIABLES ESTATICAS
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configuracionEtiqueta()
        configuraFotoPatron()
        configuraBotonPatron()
        configuraBotonFrontal()
        configuraBotonFlash()

        botonFlash.isHidden = true
        botonCamaraFrontal.isHidden = true
        
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            self.configuraBotonCamara()
            self.botonFlash.isHidden = true
            self.botonCamaraFrontal.isHidden = false
        })
      
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkCameraPermission()
       
       
        navigationController?.navigationBar.backIndicatorImage = nil
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = nil

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = .clear
        
    }
    func configuraBotonCamara(){
        
        let altura = (UIScreen.main.bounds.size.height / CGFloat(numeroAureo))
        let alturaFinal = UIScreen.main.bounds.size.height - altura
        
        let anchoBoton = (UIScreen.main.bounds.size.width / CGFloat(numeroAureo)) / CGFloat(numeroAureo)  / CGFloat(numeroAureo)
        
        botonCamara.alpha = 0
        botonCamara.frame = CGRect(x: UIScreen.main.bounds.width/2 - anchoBoton/2, y:  altura + (alturaFinal/2) - anchoBoton/2, width: anchoBoton, height: anchoBoton)
        
        self.botonCamara.redondoCompleto()
        self.botonCamara.sombreaBoton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.etiquetaDia.desiluminar()
            self.etiquetaDiaSubtitulo.desiluminar()
            self.botonPatronFoto.iluminar()
            self.botonCamaraFrontal.iluminar()
//            self.botonFlash.iluminar()
    
             })
        
        view.unblur()
        botonCamara.iluminar()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
      
        super.viewWillDisappear(animated)
        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//        navigationController?.navigationBar.shadowImage = nil
        
        navigationController?.navigationBar.isTranslucent = false
        view.layoutIfNeeded()
        
    }
//    MARK:- CONFIGURACIONES
    func configuraBotonFrontal(){
         
        botonCamaraFrontal.alpha = 0
        botonCamaraFrontal.sombreaBoton()
        
        let altura = (UIScreen.main.bounds.size.height/2)/2
               
        botonCamaraFrontal.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.size.height/2 + altura - 20, width: 40, height: 40)
        
    }
    func configuraBotonFlash(){
        
        botonFlash.alpha = 0
        botonFlash.redondear()
        botonFlash.sombreaVista()
        
        let altura = (UIScreen.main.bounds.size.height/2 )/2 - 20
        
        botonFlash.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: altura, width: 40, height: 40)
        
        botonFlash.isHidden = true
    }
    func configuraBotonPatron(){
        
        botonPatronFoto.sombreaVista()
        botonPatronFoto.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height/2 - 10, width: 40, height: 40)
        
        botonPatronFoto.redondear()
        botonPatronFoto.alpha = 0
        
    }
    func configuraFotoPatron(){
    
        fotoPatron.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        fotoPatron.alpha = 0
        
        DispatchQueue.global(qos: .background).async {
            
            self.preparaMatrizFotos()
            
            DispatchQueue.main.async {
                
                if self.matrizFotos.count > 0 {
                    
                    let imageFotoPatron = self.matrizFotos[0].foto!
                    self.fotoPatron.image = UIImage(data: imageFotoPatron as Data)
                }
            }
        }

    }
    func configuracionEtiqueta() {
        
        let titulo = followThingDesdeSec.titulo!
       
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingDesdeSec.fechaCreacion!, end: Date())
     
        let altura = heightForView(text: titulo, font: fuentePopoverGrande!, width: UIScreen.main.bounds.size.width-80)
        
//        let alturaSubtitulo = heightForView(text: Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: 0, forzarDia: true), font: fuentePopoverGrandeSubtitulo!, width: UIScreen.main.bounds.size.width-80)
        
//        etiquetaDiaSubtitulo.font = fuentePopoverGrandeSubtitulo
//        etiquetaDia.font = fuentePopoverGrande
        
//        etiquetaDia.frame = CGRect(x: 40, y: 60, width: UIScreen.main.bounds.size.width-80, height: altura)
//
//        etiquetaDiaSubtitulo.frame = CGRect(x: 40, y: 60+altura, width: UIScreen.main.bounds.size.width-80, height: alturaSubtitulo)
//
       etiquetaDia.textColor = .white
        etiquetaDiaSubtitulo.textColor = .white
//
//        etiquetaDia.adjustsFontSizeToFitWidth = true
//        etiquetaDia.minimumScaleFactor = 0.5
//        etiquetaDia.lineBreakMode = .byClipping
        
//        etiquetaDia.numberOfLines = 0
//
        etiquetaDia.text =  titulo
        etiquetaDiaSubtitulo.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: 0, forzarDia: true)
        
        etiquetaDia.contentMode = .scaleToFill
        etiquetaDia.adjustsFontSizeToFitWidth = true
        etiquetaDia.minimumScaleFactor = 0.25
        etiquetaDia.sombreaVista()
        etiquetaDiaSubtitulo.sombreaVista()
    }
    func configure(){
      
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInDualWideCamera,.builtInTelephotoCamera,.builtInTripleCamera,.builtInTrueDepthCamera,.builtInUltraWideCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        if currentDevice != nil {
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        
        
        stillImageOutput = AVCapturePhotoOutput()
        
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // Bring the camera button to front
        
        view.bringSubviewToFront(etiquetaDia)
        view.bringSubviewToFront(etiquetaDiaSubtitulo)
        view.bringSubviewToFront(fotoPatron)
        view.bringSubviewToFront(botonPatronFoto)
        view.bringSubviewToFront(botonFlash)
        view.bringSubviewToFront(botonCamaraFrontal)
        view.bringSubviewToFront(botonCamara)
        captureSession.startRunning()
        }
    }
//    MARK:- FLASH
    @IBAction func accionFlash(_ sender: Any) {
      
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
   
         captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInDualWideCamera,.builtInTelephotoCamera,.builtInTripleCamera,.builtInTrueDepthCamera,.builtInUltraWideCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

           guard let device = deviceDiscoverySession.devices.first
               else {
            
            return}

           if device.hasTorch {
               do {
                   try device.lockForConfiguration()
                   let on = device.isTorchActive
                   if on != true && device.isTorchModeSupported(.on) {
                       try device.setTorchModeOn(level: 1.0)
                    botonFlash.backgroundColor = botonActivo
                    botonFlash.rebotar()
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                           generator.impactOccurred()
                   } else if device.isTorchModeSupported(.off){
                       device.torchMode = .off
                    botonFlash.backgroundColor = .clear
                    botonFlash.rebotar()
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                           generator.impactOccurred()
                   } else {
                       print("Torch mode is not supported")
                   }
                   device.unlockForConfiguration()
               } catch {
                   print("Torch could not be used")
               }
           } else {
               print("Torch is not available")
            botonFlash.isHidden = true
           }
    }
    //    MARK:- CAMARA FRONTAL
    @IBAction func accionCamaraFrontal(_ sender: Any) {
        
        botonCamaraFrontal.rebotar()
        botonFlash.desiluminar()
        
               let currentCameraInput: AVCaptureInput = captureSession.inputs[0]
               captureSession.removeInput(currentCameraInput)
               var newCamera: AVCaptureDevice
               newCamera = AVCaptureDevice.default(for: AVMediaType.video)!

                   if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
                       UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                        newCamera = self.cameraWithPosition(.front)!
                        
                       }, completion: nil)
                   } else {
                       UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromRight, animations: {
                           newCamera = self.cameraWithPosition(.back)!
                       
                       
                       }, completion: nil)
                   }
                   do {
                    try self.captureSession.addInput(AVCaptureDeviceInput(device: newCamera))
                   }
                   catch {
                       print("error: \(error.localizedDescription)")
                   }

           
    }
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
      
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera,.builtInDualCamera,.builtInDualWideCamera,.builtInTelephotoCamera,.builtInTripleCamera,.builtInTrueDepthCamera,.builtInUltraWideCamera,.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)

        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    //    MARK:- FOTO PATRON
    @IBAction func accionFotoPatron(_ sender: Any) {
        
        if matrizFotos.count > 0 {
        
        compruebaEstadoBotonFotoPatron()
            UserDefaults.standard.set(fotoPatronEncendido, forKey: "fotoPatron")
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        botonPatronFoto.superRebotar()
        }
        
    }
    func compruebaEstadoBotonFotoPatron(){
       
        
        if fotoPatronEncendido {
        
        botonPatronFoto.backgroundColor = .clear
        fotoPatron.desiluminar()
        fotoPatronEncendido = false
           
        }
        else {
            
            botonPatronFoto.backgroundColor = botonActivo
            fotoPatron.iluminar05()
            
            fotoPatronEncendido = true
        }
       
    }
    @IBAction func subeAlpha(_ sender: Any) {
        
        if fotoPatron.alpha < 0.70 {
            
            fotoPatron.alpha = fotoPatron.alpha + 0.10
        }
    }
    
    @IBAction func bajaAlpha(_ sender: Any) {
        
        if fotoPatron.alpha >= 0 {
            
            fotoPatron.alpha = fotoPatron.alpha - 0.10
        }
    }
    //    MARK:- CAMARA
    
    @IBAction func capture(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        
        stillImageOutput.isHighResolutionCaptureEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        
        // Get the image from the photo buffer
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        stillImage = UIImage(data: imageData)
     
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popVC = storyboard.instantiateViewController(identifier: "VCResultadoCamara") as! VCResultadoCamara
   
        popVC.popoverPresentationController?.delegate = self
      
    
        popVC.delegado = self
        popVC.image = stillImage
        popVC.unFollowThingRecibidoCam = unFTDB
        popVC.followThingDesdeCam = followThingDesdeSec
         
       view.addBlurEffect()
        
        self.present(popVC, animated: true, completion: nil)
       
    }
    
    func checkCameraPermission() {

        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self](granted) in
                if granted {
                    print("access granted")
                    DispatchQueue.main.async { [weak self] in
                        self?.startSceneViewSession()
                        
                            self?.configuraBotonCamara()
                            self?.botonFlash.isHidden = true
                            self?.botonCamaraFrontal.isHidden = false
                     
                    }

                } else {
                    print("access denied")
                    DispatchQueue.main.async { [weak self] in
                        self?.alertUserCameraPermissionMustBeEnabled()
                    }
                }
            }

        case .authorized:
            print("Access authorized")
            startSceneViewSession()

        case .denied, .restricted:
            print("restricted")
            alertUserCameraPermissionMustBeEnabled()

        @unknown default:
            fatalError()
        }
    }

    func alertUserCameraPermissionMustBeEnabled() {

        let message = "El acceso de cámara es necesario para tomar fotografías del objeto seguido. Las fotos tomadas permanecerán unicamente en el dispositivo"

        let alert = UIAlertController (title: "Acceso de cámara requerido", message: message, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .default, handler: { (action) in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (_) in
                })
            }
        })

        alert.addAction(settingsAction)

        present(alert, animated: true, completion: nil)
    }

    // this is for ARKit
    func startSceneViewSession() {
       
    }
//    MARK:- FUNCIONES ENTRE CONTROLADORES
    func cierraPopover(){
           
        view.unblur()
       }
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
           
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          
    if segue.identifier == "camaraToResultado" {
         
        let VCResultado: VCResultadoCamara = segue.destination as! VCResultadoCamara
      
        VCResultado.image = stillImage
    }
    }
//    MARK:- FUNCIONES DE CLASE
    func preparaMatrizFotos(){
        
        if unFTDB.count > 0 {
            
            for busquedaFoto in 1...unFTDB.count {
                if unFTDB[busquedaFoto-1].foto != nil {
                    
                    matrizFotos.append(unFTDB[busquedaFoto-1])
                    
                }
            }
        }
    }
}
extension AVCaptureDevice {
    enum AuthorizationStatus {
        case justDenied
        case alreadyDenied
        case restricted
        case justAuthorized
        case alreadyAuthorized
        case unknown
    }

    class func authorizeVideo(completion: ((AuthorizationStatus) -> Void)?) {
        AVCaptureDevice.authorize(mediaType: AVMediaType.video, completion: completion)
    }

    class func authorizeAudio(completion: ((AuthorizationStatus) -> Void)?) {
        AVCaptureDevice.authorize(mediaType: AVMediaType.audio, completion: completion)
    }

    private class func authorize(mediaType: AVMediaType, completion: ((AuthorizationStatus) -> Void)?) {
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .authorized:
            completion?(.alreadyAuthorized)
        case .denied:
            completion?(.alreadyDenied)
        case .restricted:
            completion?(.restricted)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        completion?(.justAuthorized)
                    } else {
                        completion?(.justDenied)
                    }
                }
            })
        @unknown default:
            completion?(.unknown)
        }
    }
}



