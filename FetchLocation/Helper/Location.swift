import CoreLocation
import UIKit

final class LocationManager: NSObject {
    static let shared = LocationManager()

    private var backgroundTask = UIBackgroundTaskIdentifier.invalid
    private let manager = CLLocationManager()
    var updatedLocation = CLLocation()
   
    
    func requestAuth() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.requestWhenInUseAuthorization()
    }
    
    func stop() {
        manager.stopUpdatingLocation()
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
    
    func checkAuthorisation() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                break
            }
        } else {
            return false
        }
        return false
    }


}

//MARK:- Extension CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("LocationManager didStartMonitoringFor")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager \(error)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("LocationManager \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        postLocation(location: locations.first)
        updatedLocation = locations.last ?? CLLocation()
    }
}

//MARK:- Extension LocationManager
extension LocationManager {
    private func postLocation(location: CLLocation?) {
        guard let location = location else { return }

        if UIApplication.shared.applicationState == .background {

            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "test_Location", expirationHandler: {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            })

            DispatchQueue.global(qos: .background).async {
                self.postRequest(location: location) { [weak self] in
                    guard let self = self else { return }
                    UIApplication.shared.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                }
            }
        } else {
            postRequest(location: location)
        }

    }

    private func postRequest(location: CLLocation, completion: (() -> Void)? = nil) {
       // TODO Send Post
    }
}
