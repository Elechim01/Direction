//
//  ViewController.swift
//  Direction
//
//  Created by Michele Manniello on 29/01/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var getDirectionsButton: UIButton!
    @IBOutlet weak var textFieldForAdd: UITextField!
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func getDirectionTapped(_ sender: Any) {
        getAddress() 
    }
    func getAddress() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textFieldForAdd.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location
            else{
                print("no location found ")
                return
            }
            print(location)
            self.mapThis(destinationCord: location.coordinate)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    func mapThis(destinationCord: CLLocationCoordinate2D){
        let sourceCordinate = locationManager.location?.coordinate
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCordinate!)
        let destPlaceMark = MKPlacemark(coordinate: destinationCord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destItem = MKMapItem(placemark: destPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
//        scelta del mezzo di trasposrto
        destinationRequest.transportType = .automobile
//        Richiestra strade alternative
        destinationRequest.requestsAlternateRoutes = true
        let direction = MKDirections(request: destinationRequest)
        direction.calculate { (response, error) in
            guard let response = response else{
                if let error = error{
                    print("something is wrong :(")
                }
                return
            }
            let route = response.routes[0]
//            Aggiugerlo alla mappa
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
}

