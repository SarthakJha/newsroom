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
  static let latitude: CLLocationDegrees = 28.679079
  static let longitude: CLLocationDegrees = 77.069710
}

class MapViewController: UIViewController {
    
    var marker: GMSMarker!
    var mapresultViewController: MapResultViewController?
    
    var geoCoder: CLGeocoder!
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
    
    private func getISO3166CountryCode(countryName country: String)->String{
        if let code = CountryCode.data[country] {
            return code.lowercased()
        }
        return ""
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
           return GMSCameraPosition(latitude: KyivLocation.latitude,
                                    longitude: KyivLocation.longitude,
                                     zoom: 3)
     }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.addSubview(mapView)
        geoCoder = CLGeocoder()
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
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: currentCamera!.target.latitude.magnitude, longitude: currentCamera!.target.longitude.magnitude)) { [self] places, error in
            
            guard let country = places?[0].country else {return}
            marker.title = country
            let countryCode = self.getISO3166CountryCode(countryName: country)
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
