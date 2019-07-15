import UIKit


protocol ChangeCityProtocol{
    func newCityEntered(city: String)
}

class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityProtocol?
    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        let cityName = changeCityTextField.text!
        delegate?.newCityEntered(city: cityName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
