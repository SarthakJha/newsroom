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

    private var mapViewModel: MapViewModel = MapViewModel(screenType: .mapResult)
    
    private var newsWebViewController: NewsWebViewController!
    private var marker: GMSMarker = GMSMarker()
    private var mapresultViewController: MapResultViewController!
    private let configuration = ToastConfiguration(
        autoHide: true,
        enablePanToClose: true,
        displayTime: 3,
        animationTime: 0.2
    )
    
    private lazy var mapView: GMSMapView? = {
        var mapview = GMSMapView(frame: view.frame)
        mapview.isMyLocationEnabled = true
        return GMSMapView(frame: view.frame)
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mapView = mapView else {return}
        view.addSubview(mapView)

        newsWebViewController = NewsWebViewController()
        mapViewModel.mapDelegate = self
        mapView.delegate = self

        marker.map = mapView
    }
    
    deinit {
        mapView = nil
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            GeneralUtility.makeViewInactive(view: &(self.view))
        }
        mapViewModel.setCurrentCamera(position: GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 4))
        MapViewModel.getISO3166CountryCode(coordinates: coordinate) { countryCode, country in
            if (countryCode == ""){
                ToastHandler.performToast(toastTitle: String(localized: "TOAST_UNKNOWN_LOCATION_TITLE"), toastDescription: String(localized: "TOAST_UNKNOWN_LOCATION_DESCRIPTION"), toastConfig: self.configuration)
                GeneralUtility.makeViewActive(view: &(self.view))
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.marker.title = country
                self.mapresultViewController = MapResultViewController()
                self.mapresultViewController.countryCode = countryCode
                self.mapresultViewController.delegate = self

                
                if let sheet = self.mapresultViewController?.sheetPresentationController{
                    sheet.detents = [.medium(),.large()]
                }
                guard let mapresultViewController = self.mapresultViewController else {return}
                GeneralUtility.makeViewActive(view: &(self.view))
                self.present(mapresultViewController, animated: true)
            }
        }
        
    }
}

extension MapViewController: MapViewControllerDelegate{
    func didTapOnSearchResults(_ viewContrller: UIViewController, indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if let navigationController = self.navigationController{
                let url = self.mapViewModel.getArticleForIndexPath(indexPath: indexPath)?.url
                guard let url = url else {return}
                self.newsWebViewController.url = URL(string: url)
                navigationController.pushViewController(self.newsWebViewController, animated: true)
            }
        }
    }
}


extension MapViewController: MapViewDelegate {
    func animateToCurrentCamera(currentCamera: GMSCameraPosition) {
        
        DispatchQueue.main.async {
                self.mapView!.animate(to: currentCamera)
                self.marker.position = currentCamera.target
        }
    }
   
}
