//
//  mapViewModel.swift
//  newsroom
//
//  Created by Sarthak Jha on 15/01/23.
//

import Foundation
import GoogleMaps
import GooglePlaces

protocol MapViewDelegate {
    func animateToCurrentCamera(currentCamera: GMSCameraPosition)
}

final class MapViewModel: NewsViewmodel {
    
    public var mapDelegate: MapViewDelegate?
    private var currentCamera: GMSCameraPosition? {
        didSet{
            guard let currentCamera = currentCamera else {return}
            mapDelegate?.animateToCurrentCamera(currentCamera: currentCamera)
        }
    }
    
    override init(screenType: NewsControllerType, countryCode: String? = "in", delegate: ViewModelDelegate? = nil, newsArticles: ArticleResponse? = nil) {
        super.init(screenType: screenType)
        
        // setting default camera
        let lat = UserDefaults.standard.double(forKey: "location-latitude")
        let long = UserDefaults.standard.double(forKey: "location-longitude")
        currentCamera = GMSCameraPosition(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 3)
    }
    
    public func getCurrentCamera()-> GMSCameraPosition? {
        return currentCamera
    }
    
    public func setCurrentCamera(position: GMSCameraPosition?){
        currentCamera = position
    }
    
    public static func getISO3166CountryCode(coordinates: CLLocationCoordinate2D, completion: @escaping((String, String)->())){
    
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
}
