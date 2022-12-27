//
//  CategoryViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import GoogleMaps
import GooglePlaces


class MapViewController: UIViewController {
    
    var marker: GMSMarker!
    var mapresultViewController: MapResultViewController!
    
    var newsItems: ArticleResponse? {
        didSet{

            DispatchQueue.main.async { [self] in
                self.mapresultViewController = MapResultViewController()
                mapresultViewController!.articleResponse = newsItems
                
                if let sheet = mapresultViewController?.sheetPresentationController{
                    sheet.detents = [.medium(),.large()]
                }
                guard let mapresultViewController = mapresultViewController else {return}
                present(mapresultViewController, animated: true)
            }
        }
    }
    
    static func getISO3166CountryCode(coordinates: CLLocationCoordinate2D, completion: @escaping((String, String)->())){
    
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude.magnitude, longitude: coordinates.longitude.magnitude)) { places, error in
            if let error = error{
                print("decoding error: ", error)
                return
            }
            print("this is coordinates:", coordinates)
            guard let country = places?[0].country else {return}
            if let code = CountryCode.data[country] {
                completion(code, country)
            }
        }
    }
    
    var currentCamera: GMSCameraPosition? {
        didSet{
            guard let currentCamera = currentCamera else {return}
            mapView.animate(to: currentCamera)
            marker.position = currentCamera.target
        }
    }
    
    lazy var mapView: GMSMapView = {
        return GMSMapView(frame: view.frame)
    }()
    private lazy var defaultCamera: GMSCameraPosition = {
        let lat = UserDefaults.standard.double(forKey: "location-latitude")
        let long = UserDefaults.standard.double(forKey: "location-longitude")
           return GMSCameraPosition(latitude: CLLocationDegrees(lat),
                                    longitude: CLLocationDegrees(long),
                                     zoom: 3)
     }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.addSubview(mapView)
        mapView.delegate = self
        marker = GMSMarker()
        currentCamera = defaultCamera
        marker.position = currentCamera!.target
        marker.map = mapView
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        currentCamera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 4)
        MapViewController.getISO3166CountryCode(coordinates: coordinate) { countryCode, country in
            if (countryCode == ""){
                print("erorr: ")
                return
            }
            debugPrint("cointry", countryCode)
            self.marker.title = country
            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: countryCode) { response, error in
                if let error = error{
                    print(error)
                    return
                }
                if response?.status == .ok && (response?.totalResults)! > 0{
                    self.newsItems = response
                }
            }
        }
       
    }
}
