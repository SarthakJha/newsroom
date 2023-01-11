//
//  AppDelegate.swift
//  newsroom
//
//  Created by Sarthak Jha on 16/12/22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let locationManager = CLLocationManager()
    internal var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootVC = MainViewController()
        let navVC = UINavigationController(rootViewController: rootVC)
        window.rootViewController = navVC
        self.window = window
        window.makeKeyAndVisible()
        
        GMSServices.provideAPIKey(Secrets.MapsAPIKey)
        GMSPlacesClient.provideAPIKey(Secrets.MapsAPIKey)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        NetworkMonitor.shared.startMonitoring()
        return true
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            print("no idea")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location: ", locations[locations.count - 1].coordinate)
        MapViewController.getISO3166CountryCode(coordinates: locations[locations.count-1].coordinate) { CountryCode, countryName in
            if(CountryCode == ""){
                return
            }
            UserDefaults.standard.setValue(CountryCode, forKey: "country-code")
        }
        UserDefaults.standard.setValue(locations[locations.count-1].coordinate.latitude.magnitude, forKey: "location-latitude")
        UserDefaults.standard.setValue(locations[locations.count-1].coordinate.longitude.magnitude, forKey: "location-longitude")
        UserDefaults.standard.synchronize()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error1: ", error)
    }

}

