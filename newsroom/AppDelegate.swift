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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(Secrets.MapsAPIKey)
        GMSPlacesClient.provideAPIKey(Secrets.MapsAPIKey)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("did enter forreground")
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("requested for auth")
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

