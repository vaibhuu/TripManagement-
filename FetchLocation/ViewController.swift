import UIKit

class ViewController: UIViewController {
    
    //MARK:- Variable
    var fetchLocationTimer = Timer()
    var locationDict = [[String:Any]]()
    var jsonDict = [String:Any]()
    var uniqTripId = 0
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonDict = ["trip_id":"","start_time":"","end_time":"", "locations":[[String:Any]]()]
        LocationManager.shared.requestAuth()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- IBAction to stort and stop fetching location
    @IBAction func btnStartStop(_ sender: UIButton) {
        if LocationManager.shared.checkAuthorisation() {
            if sender.isSelected { // State where location is already fetching
                stopLocationReading()
            } else {// State location fetch
                startLocationReading()
            }
            sender.isSelected.toggle()
        } else {
            askPermissionToAllowLocationInSetting()
        }
    }
    
    //MARK:- Manage reading location ans add timer add location in array at every 5 second
    func startLocationReading() {
        jsonDict["trip_id"] = "\(uniqTripId)"
        jsonDict["start_time"] = "\(Date())"
        fetchLocationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
        LocationManager.shared.start()
    }
    
    //MARK:- Store location array and end time in a dictionary and stop updating location and timer
    func stopLocationReading() {
        jsonDict["locations"] = locationDict
        jsonDict["end_time"] = "\(Date())"
        fetchLocationTimer.invalidate()
        LocationManager.shared.stop()
        
        saveLocationDataInUserDefault()
        
        uniqTripId += 1
    }
    
    //MARK:- Convert location Dictionary array to json and store in UserDefault
    func saveLocationDataInUserDefault() {
        if let json = jsonDict.jsonStringRepresentation {
            UserDefaults.standard.setValue(json, forKey: "lastLocation")
        }
    }
    
    //MARK:- Custom Func Append fetched location and store in array
    @objc func updateLocation() {
        print("Update")
        locationDict.append(["latitude":LocationManager.shared.updatedLocation.coordinate.latitude, "longitide":LocationManager.shared.updatedLocation.coordinate.longitude, "timestamp":"\(Date())", "accuracy": LocationManager.shared.updatedLocation.speedAccuracy.binade])
    }
    
    //MARK:- Permission for location
    func askPermissionToAllowLocationInSetting() {
        let alert = UIAlertController(title: "Allow Location Access", message: "Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
        
        // Button to Open Settings
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}





