//
//  ViewController.swift
//  20 - App Where am I
//
//  Created by Marco Linhares on 6/27/15.
//  Copyright (c) 2015 Marco Linhares. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
    var list = Model.singleton
    var annotationMe = MKPointAnnotation ()
    var locationMe = CLLocation ()
    var firstCircle : MKCircle! = nil
    
    var manager = CLLocationManager()
    var centered = true
    var buttonFindPressed = false
    
    // é true quando o usuário chegou nessa view clicando em uma célula da tableview
    var cameFromSegue = false
    
    // índice da coluna clicada na table view
    var indexFromSegue : Int! = nil
    
    @IBAction func buttonFindMe(sender: AnyObject) {
        buttonFindPressed = true
    }
    
    @IBAction func buttonBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    // troca o valor da variável centered
    @IBAction func buttonCenter(sender: AnyObject) {
        if centered == true {
            centered = false
            sender.setTitle ("Center OFF", forState: UIControlState.Normal)
        } else {
            centered = true
            sender.setTitle ("Center ON", forState: UIControlState.Normal)
        }
    }
    
    // função que é chamada toda vez que a localização for atualizada
    func locationManager (manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userLocation : CLLocation = locations[0] as! CLLocation
        
        var lat = userLocation.coordinate.latitude
        var lon = userLocation.coordinate.longitude
        var radius : CLLocationDistance
        
        var myLocation: CLLocationCoordinate2D
    
        if centered == true || buttonFindPressed == true {
            // desenha um novo mapa com a pessoa centralizada
            myLocation = createMap (mapView, latitude: lat, longitude: lon, delta: 0.01)
            
            if buttonFindPressed == true {
                buttonFindPressed = false
            }
        } else {
            // caso não precise centralizar, então pode ser usado o mapa anterior e não
            // é preciso criar um novo mapa. apenas é passada a posição atual da pessoa
            // sem ser criado um novo mapa (que seria com a função createMap)
            myLocation = CLLocationCoordinate2DMake (lat, lon)
        }

        // remove a anotação anterior. na 1a vez que é executado, não acontece nada
        // foi substituído no código abaixo por uma bolinha azul
        //mapView.removeAnnotation(annotationMe)
        //annotationMe = createAnnotation (mapView, location: myLocation, title: "It's me", subtitle: "")
        
        self.mapView.removeOverlay(firstCircle)
        
        locationMe = CLLocation(latitude: lat, longitude: lon)
        
        // If you want the circle to always be the same size, no matter the zoom level, you'll have to do something different.
        // Like you say, in regionDidChange:animated:, get the latitudeDelta, then create a new circle (with a radius that fits into the width),
        // remove the old one and add the new one.
        radius = (15 * mapView.region.span.latitudeDelta) / 0.0126156
        
        if radius < 15 {
            radius = 15
        }

        firstCircle = addRadiusCircle(locationMe, radius: radius)
    }
    
    // desenha o cículo no mapa
    func addRadiusCircle(location: CLLocation, radius : CLLocationDistance) -> MKCircle! {
        var circle = MKCircle(centerCoordinate: location.coordinate, radius: radius as CLLocationDistance)
        
        self.mapView.delegate = self
        self.mapView.addOverlay(circle)
        
        return circle
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.blueColor()
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
            circle.lineWidth = 1
            return circle
        } else {
            return nil
        }
    }
    
    
    // é chamada caso o GPS esteja desligado ou a pessoa não aceitou a permissão
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }
    
    func createMap (map: MKMapView!, latitude : CLLocationDegrees, longitude : CLLocationDegrees, delta: CLLocationDegrees) -> CLLocationCoordinate2D {
        var lat : CLLocationDegrees = latitude
        var lon : CLLocationDegrees = longitude
        
        // quanto maior o número, maior o zoom. 1 é muito e 180 é o valor máximo que é o mundo inteiro
        var latDelta : CLLocationDegrees = delta
        var lonDelta : CLLocationDegrees = delta
        
        // cria a região desejada
        var span     : MKCoordinateSpan       = MKCoordinateSpanMake(latDelta, lonDelta)
        var location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        
        // cria o mapa da região
        var region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        // coloca a região e mostra no mapa
        mapView.setRegion(region, animated: true)
        
        // caso queira parar de atualizar a localização
        //manager.stopUpdatingLocation()
        
        return location
    }
    
    func createAnnotation (map: MKMapView!, location : CLLocationCoordinate2D, title : String, subtitle : String) -> MKPointAnnotation {
        
        // cria uma anotação a ser colocada no mapa
        // veja que essa variável não pode ser declarada como global ou da classe! isso geraria um erro na execução. o que ocorre é que ela
        // é uma variável strong e aponta pra mkpointannotation. a função, quando é encerrada, mata essa variável annotation, porém o mapa
        // continua apontando para ela. quando ela é colocada como global, a mesma variável é passada para o mapa, e assim ela é substituída
        // ao invés de ser criada uma nova anotação (um novo malloc para armazená-la). Faça o teste e coloque weak var annotation na linha
        // abaixo e você vai perceber que na linha logo abaixo, annotation é nil pois a weak só armazena na mesma linha de execução.
        // Variáveis weak não aumentam o reference count dos objetos que apontam. Uma strong aumenta em 1 a reference count e logo depois que
        // a variável strong deixa de existir (quando acabar a função, por exemplo), o contador de referências diminui em 1.
        var annotation = MKPointAnnotation ()
        
        annotation.coordinate = location
        annotation.title      = title
        annotation.subtitle   = subtitle
        
        // coloca as anotações no mapa
        map.addAnnotation(annotation)
        
        return annotation
    }
    
    // pega o endereço através de geolocalização reversa
    // foi usada uma closure completion no final para que o resultado da função fosse passado para outra função
    func getGeolocalization (latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: (String) -> Void) {
        var geocoder = CLGeocoder()
        var location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation (location) {
            (placemarks, error) -> Void in
            if let placemarks = placemarks as? [CLPlacemark] where placemarks.count > 0 {
                var placemark = placemarks [0]
                
                //  rua e números = placemark.name, sublocality = bairro
                let address = (placemark.name != nil) ? placemark.name : (placemark.subLocality != nil) ? placemark.subLocality : nil
                
                // o código é equivalente a:
                //if placemark.name != nil { address = placemark.name }
                //else if placemark.subLocality != nil { address = placemark.subLocality }
                
                // quando a função chegar aqui é executado o código que foi passado por parâmetro pela outra função e passado o valor calculado em address
                completion (address)
            }
        }
    }
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        // onde o usuário clicou na tela
        var touchPoint = gestureRecognizer.locationInView(mapView)
        
        // quais as coordenadas desse ponto na tela
        var newCoordinate : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        // depois de passado o tempo, ele entra no estado began. caso a função de dentro fosse chamada fora do
        // if, ele iria chamar essa função uma quantidade enorme de vezes, colocando uma quantidade muito
        // grande de pontos
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            self.getGeolocalization (newCoordinate.latitude, longitude: newCoordinate.longitude) {
                (addressName) -> Void in
                
                dispatch_async (dispatch_get_main_queue()) {
                    var stringAddress : String = ""
                    
                    // alerta pop up para pegar o nome do local
                    // foi criado um NewAlertController ao invés de UIAlertController pois o alert controller padrão não permite acesso ao método viewDidAppear
                    // e ele era necessário para que o texto fosse automaticamente selecionado quando a caixa de texto aparece. por isso foi criado um novo
                    // arquivo e a classe especializada.
                    var alert = NewAlertController (title: "Place Name", message: "Type the name of the place", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addTextFieldWithConfigurationHandler {
                        (textfield) -> Void in
                        
                        textfield.text = addressName
                        textfield.placeholder = addressName
                    }
                    
                    alert.addAction(UIAlertAction (title: "OK", style: .Default, handler: {
                        (action) -> Void in
                        
                        let textField = alert.textFields! [0] as! UITextField
        
                        dispatch_async (dispatch_get_main_queue()) {
                            
                            if textField.text == ""  {
                                textField.text = addressName
                            }
                            
                            self.createAnnotation (self.mapView, location: newCoordinate, title: textField.text, subtitle: "")
                            
                            self.list.addElement (textField.text, location: newCoordinate)
                        }
                        
                        self.textFieldShouldReturn(textField)
                    
                    }))

                    alert.addAction(UIAlertAction (title: "Cancel", style: .Default, handler: {
                        (action) -> Void in
                        
                        dispatch_async (dispatch_get_main_queue()) {
                            self.createAnnotation (self.mapView, location: newCoordinate, title: addressName, subtitle: "")
                            
                            self.list.addElement (addressName, location: newCoordinate)
                        }

                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // faz o teclado desaparecer quando é apertado <Enter>
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // plota todas as anotações anteriores na tela
        let numberOfElements = list.countElements ()
        
        for var i = 0; i < numberOfElements; i++ {
            let description = list.elementAtIndex(i)
            let position = list.positionAtIndex (i)
            
            self.createAnnotation (self.mapView, location: position.coordinate, title: description, subtitle: "")
        }
        
        if cameFromSegue == true {
            centered = false
            
            // botão center on/off
            (view.viewWithTag (1) as! UIButton?)!.setTitle ("Center OFF", forState: UIControlState.Normal)
            
            let position = list.positionAtIndex (indexFromSegue)
            
            createMap (mapView, latitude: position.coordinate.latitude, longitude: position.coordinate.longitude, delta: 0.01)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // coloca o delegate. é preciso fazer via código pois ele não é um elemento do storyboard. self = ViewController
        manager.delegate = self
        
        // quanto maior a acurácia, maior o gasto de bateria. use o menor possível
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // faz o pedido para pegar a localização
        manager.requestWhenInUseAuthorization()
        
        manager.startUpdatingLocation()
        
        // o "action:" com os : é porque a função tem um parâmetro, por isso precisa para ele reconhecer
        var longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        
        // tempo necessário para apertar o botão
        longPress.minimumPressDuration = 0.5
        
        // adiciona o gesture recognizer no mapa. poderia ser escrito view.addGestureRecognizer, mas daí iria pegar cliques na
        // view inteira, o que não é o desejado
        mapView.addGestureRecognizer (longPress)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

