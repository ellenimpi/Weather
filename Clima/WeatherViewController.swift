import UIKit
import CoreLocation // framework by apple
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityProtocol {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "c48bd797dac89c6dc6de340c7745ef2e"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var isCelcius: Bool = true;
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBAction func `switch`(_ sender: UISwitch) {
        if (sender.isOn){
            isCelcius = true;
        }
        else{
            isCelcius = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization() //edit property list in supporting files
        locationManager.startUpdatingLocation()
    }
    
    func getWeatherData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("success")
                
                let weatherInfo : JSON = JSON(response.result.value!)
                print(weatherInfo)
                self.updateWeatherInfo(json: weatherInfo)
            }
            else{ //failed
                print("error: \(response.result.error)")
                self.cityLabel.text = "Connection failed"
            }
        }
    }
    
    func updateWeatherInfo(json: JSON){
        
        if let temp = json["main"]["temp"].double{
            let city = json["name"].stringValue
            let condition = json["weather"][0]["id"].intValue
            let country = json["sys"]["country"].stringValue
            if (isCelcius){
                weatherDataModel.temperature = Int(temp - 273.15) //go from kelvin to celcius
            }
            else{
                weatherDataModel.temperature = Int(1.8 * (temp - 273.15) + 32) //go from kelvin to farenheight
            }
            
          
            weatherDataModel.city = city
            weatherDataModel.country = country
            weatherDataModel.condition = condition
            weatherDataModel.weatherIcon = weatherDataModel.updateWeatherIcon(condition: condition)
            
            updateUI()
        }
        else{
            cityLabel.text = "Weather unavailable"
        }
    }
    
    func updateUI(){
        cityLabel.text = weatherDataModel.city
        countryLabel.text = weatherDataModel.country
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIcon)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        //stop updating when we have a valid result
        if (location.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("long= \(location.coordinate.longitude), lat = \(location.coordinate.latitude)")
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            
            //to send to open weather api
            let params : [String: String] = ["lat": lat, "lon": lon, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable"
    }
    

    
    func newCityEntered(city: String) {
        let params : [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
}


