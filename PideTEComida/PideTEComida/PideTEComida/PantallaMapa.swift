//
//  PantallaMapa.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/26/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PantallaMapa: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let gps = CLLocationManager()
    
    @IBOutlet weak var mapa: MKMapView!
    
    private func configurarMapa(){
        mapa.delegate = self
        gps.delegate = self
        gps.desiredAccuracy = kCLLocationAccuracyBest
        gps.requestWhenInUseAuthorization()
        
        // Tamaño inicial del mapa
        let centro = CLLocationCoordinate2DMake(19.602293, -99.231386)
        // El span indica el espacio que deberá ser visible en el mapa, recibe proporción de latitud y proporción de longitud. Un valor de 1 es aproximadamente 111 km en el ecuador y 0 km en los polos.
        let span = MKCoordinateSpan(latitudeDelta: 0.027, longitudeDelta: 0.027)
        let region = MKCoordinateRegionMake(centro, span)
        mapa.region = region
        
        // Ahora agregemos un marcador en la plaza de borregos
        /*let centroBorregos = CLLocationCoordinate2DMake(19.595402, -99.226725)
        let pin = MKPointAnnotation()
        pin.coordinate = centroBorregos
        pin.title = "Plaza Borregos"
        pin.subtitle = "Un solo Tec"
        mapa.addAnnotation(pin)*/
    }
    
    // Para notificar que hay actualizaciones, el mapa llama al método del delegado
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // Cambió la posición
        let posicion = userLocation.location!
        mapa.setCenter(posicion.coordinate, animated: true)
    }
    
    // Para personalizar la imagen del pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title! == "My Location" {
            return nil // Imagen por default
        }
        var pinView:MKAnnotationView! = nil
        pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        }
        else {
            pinView.annotation = annotation
        }
        pinView.image = UIImage(named: "carro")
        pinView.canShowCallout = true
        return pinView
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            // Hay permiso, iniciar las actualizaciones
            gps.startUpdatingLocation()
        }
        else if status == .denied {
            gps.stopUpdatingLocation()
            print("Puedes habilitar el gps en Ajustes") // Alerta
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarMapa()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
