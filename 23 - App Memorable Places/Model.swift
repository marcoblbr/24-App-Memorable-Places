//
//  Model.swift
//
//
//  Created by Marco Linhares on 6/14/15.
//
//

import Foundation
import MapKit

class Model {

    // aqui está sendo usado o padrão Singleton = só permite uma instância da classe instanciada na memória. Além isso, é ela mesmo que se
    // instancia, por isso o seu init é private. O que faz ter apenas uma instância é o fato da variável ser static.
    static let singleton = Model()
    
    var list: [String]
    var locationList: [CLLocation]
    
    // essa função é caso ele queira carregar os dados da memória ou criar uma lista em branco
    // o método é private pois é uma classe singleton
    private init () {
        list = []
        locationList = []
        
        if let listInMemory = NSUserDefaults.standardUserDefaults().objectForKey ("table") as? [String] {
            if let locationInMemory = NSUserDefaults.standardUserDefaults().objectForKey ("location") as? NSData {
                
                list = listInMemory as [String]
                
                // não dá pra colocar direto um objeto, por isso ele é colocado dentro de um keyarchiver que obtém
                // o arquivo através de serialização. outro ponto é que o dado que realmente precisamos é
                // CLLocationCoordinate2D que está dentro de CLLocation. Porém, CLLocationCoordinate2D é um struct
                // é não é possível armazenar structs, apenas objetos. Por isso que é salvo o CLLocation que é um
                // objeto
                locationList = NSKeyedUnarchiver.unarchiveObjectWithData (locationInMemory) as! [CLLocation]
                
                // caso por algum motivo o número de elementos seja diferente, isso gerará um erro em execução e 
                // assim é melhor zerar as listas e começar o processo corretamente
                if list.count != locationList.count {
                    list = []
                    locationList = []
                }
            }
        }
    }
    
    func addElement (element : String, location: CLLocationCoordinate2D) {
        // insere sempre no começo do vetor
        list.insert(element, atIndex: 0)
        
        // não dá pra salvar um struct (CLLocationCoordinate2D), por isso ele é colocado dentro de um objeto CLLocation
        // e este é salvo em disco
        let newLocation = CLLocation (latitude: location.latitude, longitude: location.longitude)
        
        locationList.insert(newLocation, atIndex: 0)
        
        writeToDisk ()
    }
    
    func removeElement (index : Int) {
        list.removeAtIndex(index)
        locationList.removeAtIndex(index)
        
        writeToDisk ()
    }
    
    func removeAll () {
        list.removeAll(keepCapacity: false)
        locationList.removeAll(keepCapacity: false)
        
        writeToDisk ()
    }
    
    func writeToDisk () {
        // cria ou atualiza uma variável permanente
        NSUserDefaults.standardUserDefaults().setObject (list, forKey: "table")
        
        // não é possível salvar diretamente, por isso o objeto é serializado e gravado com key archiver
        NSUserDefaults.standardUserDefaults().setObject (NSKeyedArchiver.archivedDataWithRootObject (locationList), forKey: "location")
        
        // save permanently on disk
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func countElements () -> Int {
        return list.count
    }
    
    func elementAtIndex (index : Int) -> String! {
        if list.count > 0 {
           return list [index]
        } else {
            return nil
        }
    }
    
    func positionAtIndex (index : Int) -> CLLocation! {
        if list.count > 0 {
            return locationList [index]
        } else {
            return nil
        }
    }
}
