//
//  VCCollectionViewFotos.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 13/09/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import UIKit
import CoreData

protocol ProtocoloDelegadoCollectionViewFotos {
    func envioFotosTeatro(arrayFotos:[UnFollowThing])
    func envioFotoCollection(unFollow:UnFollowThing!)
}
class VCCollectionViewFotos: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet var etiquetaInfo: UILabel!
    @IBOutlet var collectionViewFotos: UICollectionView!
    
    public var iniciaDesdeVisorFotos:Bool = false
    public var delegado:ProtocoloDelegadoCollectionViewFotos? = nil
    var followThingRecibido:FollowThing!
    var unFollowThingRecibido:[UnFollowThing] = []
    var unFollowThingEnvioFotos:[UnFollowThing] = []
        
    private var matrizFotos:[UnFollowThing] = []
    private var matrizSeleccionFotos:[Int] = []
    private var enteroSeleccionFotos:Int = 0
    
    private var matrizSeleccionAcumulado = [Int]()
    
    public var fechaCreacionUnFTRecibido:Date?
    
    public var modoTeatro:Bool = false
    public var desdeHace:Bool = false
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.collectionViewFotos.delegate = self
        
        preparaMatrizFotos()
        configuraEtiquetaCabecera()
        configuraCollectionView()
        configuraCabecera()
        
        if iniciaDesdeVisorFotos {
            
           
        }
        if modoTeatro {
            
             configuraDesdeVisorFotos()
        
        }
        else {
            
            configuraCollectionFotos()
            configuraEtiquetaCabeceraSoloFoto()
        }
    }
//    MARK:- CONFIGURACION
    func configuraCabecera(){
        desdeHace = UserDefaults.standard.bool(forKey: "tapDia")
    }
    func configuraCollectionFotos(){
        
        etiquetaInfo.text = "Fotos"
        
    }
    func configuraEtiquetaCabecera() {
        
        let alturaEtiquetaInfo = UIScreen.main.bounds.size.width / CGFloat((numeroAureo*5))
        
        etiquetaInfo.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: alturaEtiquetaInfo)
        
        etiquetaInfo.backgroundColor = .white
        etiquetaInfo.font = fuenteTextView
        etiquetaInfo.textAlignment = .center
        etiquetaInfo.textColor = .black
        
        collectionViewFotos.frame = CGRect(x: 0, y: alturaEtiquetaInfo, width: UIScreen.main.bounds.size.width, height: view.frame.size.height - alturaEtiquetaInfo * 2)
        
    }
    func configuraEtiquetaCabeceraSoloFoto() {
        
        let alturaEtiquetaInfo = UIScreen.main.bounds.size.width / CGFloat((numeroAureo*3))
        
        etiquetaInfo.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.size.width-10, height: alturaEtiquetaInfo)
        
        etiquetaInfo.backgroundColor = .white
        etiquetaInfo.textAlignment = .left
        etiquetaInfo.font = fuentePopoverGrandeSubtitulo
        etiquetaInfo.textColor = .black
        
        collectionViewFotos.frame = CGRect(x: 0, y: alturaEtiquetaInfo, width: UIScreen.main.bounds.size.width, height: view.frame.size.height - alturaEtiquetaInfo * 2)
        
    }
    func configuraDesdeVisorFotos(){
        
        etiquetaInfo.text = "Elige dos fotos"
        
    }
    func configuraCollectionView() {
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:5,left:0,bottom:0,right:0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width/3-5, height: UIScreen.main.bounds.size.width/3*CGFloat(numeroAureo)-5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        collectionViewFotos.collectionViewLayout = layout
        
        collectionViewFotos.frame.origin.y = etiquetaInfo.frame.size.height
        
    }
    func preparaMatrizFotos(){
        
        if unFollowThingRecibido.count > 0 {
            
            for busquedaFoto in 1...unFollowThingRecibido.count {
                if unFollowThingRecibido[busquedaFoto-1].foto != nil {
                    
                    matrizFotos.append(unFollowThingRecibido[busquedaFoto-1])
                }
            }
        }
    }
    //    MARK:- COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrizFotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVFotos", for: indexPath) as! CollectionViewCellFotos
        
        let indexDB = matrizFotos[indexPath.row]
        
        let dia = Fechas.calculaDiasEntreDosFechas(start: followThingRecibido.fechaCreacion!, end: indexDB.fechaCreacionUnFT!)
        let diaInvertido = Fechas.calculaDiasEntreDosFechas(start: followThingRecibido.fechaCreacion!, end: Date()) - dia
        
        cell.foto.image = UIImage(data: indexDB.foto! as Data)
        cell.etiquetaDiaFoto.text = Fechas.creaStringDias(numeroDia: dia, numeroDiaInvertido: diaInvertido, forzarDia: false)
        
        if matrizSeleccionAcumulado.isEmpty == false {
            
            if matrizSeleccionAcumulado[0] == indexPath.row {
                
                cell.etiquetaSeleccionFotos.isHidden = false
                cell.etiquetaSeleccionFotos.text = "1"
                
            }
            else { cell.etiquetaSeleccionFotos.isHidden = true}
            
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionViewFotos.cellForItem(at: indexPath) as! CollectionViewCellFotos
        
        let indexUnFT = matrizFotos[indexPath.row]
        
        if modoTeatro {
        
        switch enteroSeleccionFotos {
        case 0:
            enteroSeleccionFotos += 1
            matrizSeleccionAcumulado.append(indexPath.row)
            cell.etiquetaSeleccionFotos.isHidden = false
            unFollowThingEnvioFotos.append(indexUnFT)
         
            
        case 1:
            
            if matrizSeleccionAcumulado[0] == indexPath.row {
                
                enteroSeleccionFotos -= 1
                matrizSeleccionAcumulado.remove(at: 0)
                unFollowThingEnvioFotos.remove(at: 0)
                
                cell.etiquetaSeleccionFotos.isHidden = true
                
               
                
            } else {
                
                enteroSeleccionFotos += 1
                matrizSeleccionAcumulado.append(indexPath.row)
                cell.etiquetaSeleccionFotos.isHidden = false
                unFollowThingEnvioFotos.append(indexUnFT)
                
                print(unFollowThingEnvioFotos)
                
                if unFollowThingEnvioFotos.count == 2 {
                    
                    delegado?.envioFotosTeatro(arrayFotos: unFollowThingEnvioFotos)
                    performSegueToReturnBack()
                }
            }
            
           break
           
        default:
            break
        }
            
        cell.etiquetaSeleccionFotos.text = "\(enteroSeleccionFotos)"
        }
        
        else {
            
            delegado?.envioFotoCollection(unFollow: indexUnFT)
            performSegueToReturnBack()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//
//        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCellFotos {
//            cell.foto.superRebotar()
//            cell.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
//        }
//    }
    

//MARK:- CORE DATA
    
    
}
class ColumnFlowLayout: UICollectionViewFlowLayout {

    let cellsPerRow: Int

    init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        super.init()

        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}
extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
