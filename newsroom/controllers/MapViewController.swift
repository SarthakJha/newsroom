//
//  CategoryViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import GoogleMaps
import GooglePlaces

struct KyivLocation {
  static let latitude: CLLocationDegrees = 50.450001
  static let longitude: CLLocationDegrees = 30.523333
}


class MapViewController: UIViewController {
    
    var geoCoder: CLGeocoder!
    
    var currentCamera: GMSCameraPosition? {
        didSet{
            guard let currentCamera = currentCamera else {return}
            mapView.animate(to: currentCamera)
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: currentCamera.target.latitude.magnitude, longitude: currentCamera.target.longitude.magnitude)) { places, error in
                print(places![0].country)
            }
        }
    }
    
    lazy var mapView: GMSMapView = {
        return GMSMapView(frame: view.frame)
    }()
    private lazy var defaultCamera: GMSCameraPosition = {
           return GMSCameraPosition(latitude: KyivLocation.latitude,
                                    longitude: KyivLocation.longitude,
                                     zoom: 3)
     }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.addSubview(mapView)
        mapView.delegate = self
        geoCoder = CLGeocoder()
        currentCamera = defaultCamera
        
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        currentCamera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 5)
        print(coordinate)
    }
}
