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

class MapViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    var newsWebViewController: NewsWebViewController!
    var marker: GMSMarker!
    var mapresultViewController: MapResultViewController!
    var didReachEnd: Bool = false
    
    var newsItems: ArticleResponse? {
        didSet{

            DispatchQueue.main.async { [self] in
                mapresultViewController.articleResponse = newsItems
                
                if let sheet = mapresultViewController?.sheetPresentationController{
                    sheet.detents = [.medium(),.large()]
                }
                guard let mapresultViewController = mapresultViewController else {return}
                mapresultViewController.didReachEnd = self.didReachEnd
                view.isUserInteractionEnabled = true
                view.alpha = 1
                activityIndicator.stopAnimating()
                present(mapresultViewController, animated: true)
            }
        }
    }
    
    static func getISO3166CountryCode(coordinates: CLLocationCoordinate2D, completion: @escaping((String, String)->())){
    
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude.magnitude, longitude: coordinates.longitude.magnitude)) { places, error in
            if let error = error{
                print("decoding error: ", error)
                completion("","")
                return
            }
            print("this is coordinates:", coordinates)
            guard let country = places?[0].country else {return}
            print(country)
            if let code = CountryCode.data[country] {
                completion(code, country)
            }else{
                completion("","")
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
        view.addSubview(activityIndicator)
        activityIndicator.backgroundColor = .red
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
        DispatchQueue.main.async { [self] in
            self.view.isUserInteractionEnabled = false
            view.alpha = 0.7
        }
        currentCamera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 4)
        let configuration = ToastConfiguration(
            autoHide: true,
            enablePanToClose: true,
            displayTime: 3,
            animationTime: 0.2
        )
        MapViewController.getISO3166CountryCode(coordinates: coordinate) { countryCode, country in
            print("this is country code: ", countryCode)
            if (countryCode == ""){
                let toast = Toast.default(image: nil, title: "Unknown Location!", subtitle: "Location couldn't be identified",configuration: configuration)
                toast.enableTapToClose()
                self.view.alpha = 1
                self.view.isUserInteractionEnabled = true
                toast.show(haptic: .error)
                
                return
            }
            self.marker.title = country
            self.activityIndicator.startAnimating()
            NewsroomAPIService.APIManager.fetchHeadlines(category: nil, countryCode: countryCode, page: 1) { response, error in
                if let error = error{
                    print(error)
                    let toast = Toast.default(image: nil, title: "Internal Error!", subtitle: "Something went wrong!",configuration: configuration)
                    toast.enableTapToClose()
                    self.view.alpha = 1
                    self.view.isUserInteractionEnabled = true
                    DispatchQueue.main.async {
                        toast.show(haptic: .error)
                    }
                    return
                }
                if response?.status == .ok && (response?.totalResults)! > 0{
                    self.newsItems = response
                    if((self.newsItems?.articles.count)! == (self.newsItems?.totalResults!)!){
                        self.didReachEnd = true
                    }
                }else{
                    DispatchQueue.main.async {
                        
                        let toast = Toast.default(image: nil, title: "No results found!", subtitle: "No news articles could be found for \(country)",configuration: configuration)
                        toast.enableTapToClose()
                        self.view.isUserInteractionEnabled = true
                        self.view.alpha = 1
                        toast.show(haptic: .error)
                    }
                }
            }
        }
       
    }
}

extension MapViewController: MapViewControllerDelegate{
    func didTapOnSearchResults(_ viewContrller: UIViewController, indexPath: IndexPath) {
        mapresultViewController.dissmissSheet()
        DispatchQueue.main.async { [self] in
            if let navigationController = navigationController{
                newsWebViewController.url = URL(string: (newsItems?.articles[indexPath.row].url)!)
                navigationController.pushViewController(newsWebViewController, animated: true)
            }
        }
    }
}
