//
//  CategoryViewController.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Toast

protocol MapViewControllerDelegate {
    func didTapOnSearchResults(_ viewContrller: UIViewController, indexPath: IndexPath)
}

final class MapViewController: UIViewController {
    
    private var newsWebViewController: NewsWebViewController!
    private var marker: GMSMarker!
    private var mapresultViewController: MapResultViewController!
    private let configuration = ToastConfiguration(
        autoHide: true,
        enablePanToClose: true,
        displayTime: 3,
        animationTime: 0.2
    )
    private var currentCamera: GMSCameraPosition? {
        didSet{
            guard let currentCamera = currentCamera else {return}
            mapView.animate(to: currentCamera)
            marker.position = currentCamera.target
        }
    }
    
    private lazy var mapView: GMSMapView = {
        var mapview = GMSMapView(frame: view.frame)
        return GMSMapView(frame: view.frame)
    }()
    private lazy var defaultCamera: GMSCameraPosition = {
        let lat = UserDefaults.standard.double(forKey: "location-latitude")
        let long = UserDefaults.standard.double(forKey: "location-longitude")
           return GMSCameraPosition(latitude: CLLocationDegrees(lat),
                                    longitude: CLLocationDegrees(long),
                                     zoom: 3)
     }()
   
    private var didReachEnd: Bool = false
    
    private var newsItems: ArticleResponse? {
        didSet{

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}

                self.mapresultViewController.articleResponse = self.newsItems
                
                if let sheet = self.mapresultViewController?.sheetPresentationController{
                    sheet.detents = [.medium(),.large()]
                }
                guard let mapresultViewController = self.mapresultViewController else {return}
                mapresultViewController.didReachEnd = self.didReachEnd
                GeneralUtility.makeViewActive(view: &(self.view))
                self.present(mapresultViewController, animated: true)
            }
        }
    }
    
    static func getISO3166CountryCode(coordinates: CLLocationCoordinate2D, completion: @escaping((String, String)->())){
    
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude.magnitude, longitude: coordinates.longitude.magnitude)) { places, error in
            if let error = error{
                completion("","")
                return
            }
            guard var country = places?[0].country else {
                completion("","")
                return
            }
            if(Locale.preferredLanguages[0] == "hi"){
                country = CountryCode.hindiCountryData[country.trimmingCharacters(in: .whitespaces)] ?? country
            }
            print("country", country)
            if let code = CountryCode.data[country] {
                completion(code, country)
            }else{
                completion("","")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsWebViewController = NewsWebViewController()
        mapresultViewController = MapResultViewController()
        mapresultViewController.delegate = self
        view.backgroundColor = .blue
        view.addSubview(mapView)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        marker = GMSMarker()
        currentCamera = defaultCamera
        marker.position = currentCamera!.target
        marker.map = mapView
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            GeneralUtility.makeViewInactive(view: &(self.view))
        }
        currentCamera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 4)
        MapViewController.getISO3166CountryCode(coordinates: coordinate) { countryCode, country in
            if (countryCode == ""){
                ToastHandler.performToast(toastTitle: String(localized: "TOAST_UNKNOWN_LOCATION_TITLE"), toastDescription: String(localized: "TOAST_UNKNOWN_LOCATION_DESCRIPTION"), toastConfig: self.configuration)
                GeneralUtility.makeViewActive(view: &(self.view))
                return
            }
            self.marker.title = country
            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: countryCode, page: 1) { response, error in
                if let error = error{
                    DispatchQueue.main.async {
                        GeneralUtility.makeViewActive(view: &(self.view))
                        ToastHandler.performToast(toastTitle: String(localized: "TOAST_INTERNAL_ERROR_TITLE"), toastDescription: String(localized: "TOAST_INTERNAL_ERROR_DESCRIPTION"), toastConfig: self.configuration)
                    }
                    return
                }
                self.handleResponse(response: response)
            }
        }
        
    }
    
    private func handleResponse(response: ArticleResponse?) {
        guard let response = response else {return}
        if response.status == .ok && (response.totalResults)! > 0{
            self.newsItems = response
            if((self.newsItems?.articles.count)! == (self.newsItems?.totalResults!)!){
                self.didReachEnd = true
            }
        }else{
            DispatchQueue.main.async {
                GeneralUtility.makeViewActive(view: &(self.view))
                ToastHandler.performToast(toastTitle: String(localized: "TOAST_NOT_FOUND_TITLE"), toastDescription: NSLocalizedString("TOAST_UNKNOWN_LOCATION_DESCRIPTION", comment: ""), toastConfig: self.configuration)
            }
        }
    }
}

extension MapViewController: MapViewControllerDelegate{
    func didTapOnSearchResults(_ viewContrller: UIViewController, indexPath: IndexPath) {
        mapresultViewController.dissmissSheet()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let navigationController = self.navigationController{
                self.newsWebViewController.url = URL(string: (self.newsItems?.articles[indexPath.row].url)!)
                navigationController.pushViewController(self.newsWebViewController, animated: true)
            }
        }
    }
}
