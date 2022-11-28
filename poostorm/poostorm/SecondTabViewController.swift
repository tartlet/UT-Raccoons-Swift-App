//
//  SecondTabViewController.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/24/22.
//

import UIKit
import CoreData
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseDatabase

class SecondTabViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var durationStepper: UIStepper!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var durationField: UITextField!
    @IBOutlet weak var eventTitleLabel: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var delegateFirstTab: UIViewController!
    var locationManager = CLLocationManager()
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationStepper.stepValue = 0.5
        descriptionField.delegate = self
        locationField.delegate = self
        durationField.delegate = self
        eventTitleLabel.delegate = self
        ref = Database.database().reference()
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        checkLocationStatus()
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func checkLocationStatus() {
        if CLLocationManager.locationServicesEnabled() {
            checkAuthorizationStatus()
        } else {
            let controller = UIAlertController(
                title: "Uh-oh!",
                message: "Please enable your location",
                preferredStyle: .alert)
            let settingsAction = UIAlertAction(
                title: "Go to Settings",
                style: .default) {
                    (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                     }
                }
            controller.addAction(settingsAction)
            controller.addAction(UIAlertAction(
                title: "Dismiss",
                style: .cancel))
            present(controller, animated: true)
        }
    }
    
    func checkAuthorizationStatus() {
      switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
          mapView.showsUserLocation = true
        case .denied:
          let controller = UIAlertController(
              title: "Uh-oh!",
              message: "Please enable your location",
              preferredStyle: .alert)
          controller.addAction(UIAlertAction(
              title: "Dismiss",
              style: .cancel))
          let settingsAction = UIAlertAction(
              title: "Go to Settings",
              style: .default) {
                  (_) -> Void in
                  guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                      return
                  }
                  if UIApplication.shared.canOpenURL(settingsUrl) {
                      UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                   }
              }
          controller.addAction(settingsAction)
          present(controller, animated: true)
        case .notDetermined:
          locationManager.requestWhenInUseAuthorization()
          mapView.showsUserLocation = true
        case .restricted:
          let controller = UIAlertController(
              title: "Uh-oh!",
              message: "You do not have current location enabled...",
              preferredStyle: .alert)
          controller.addAction(UIAlertAction(
              title: "Dismiss",
              style: .default))
        case .authorizedAlways: break
      default: break
      }
    }
    
    @IBAction func enterCurrentLocationButton(_ sender: Any) {
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationField.text =  "current location added!"
    }
    
    @IBAction func durationStepperChange(_ sender: UIStepper) {
        durationField.text = String((sender).value)
    }
    
    
    @IBAction func postNewEventButton(_ sender: Any) {
        let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let CLLCoordType = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude);
        let annotation = MKPointAnnotation();
        annotation.coordinate = CLLCoordType;
        mapView.addAnnotation(annotation);
        let eventDate = dateTime.date as NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy h:m:ss"
        let stringDate: String = dateFormatter.string(from: eventDate as Date)
        print(stringDate)
        let eventStringDateArr = stringDate.components(separatedBy: " ")
        let eventDateString:String = eventStringDateArr[0]
        let eventStartTime:String = eventStringDateArr[1]
        let duration = durationField.text
        guard let durationFloat = Float(duration!) else {
            print("String does not contain Float")
            return
        }
        let eventEndDate = eventDate.addingTimeInterval(Double(durationFloat)*60*60)
        let endDateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "dd-MM-yyyy h:m:ss"
        let stringEndDate: String = endDateFormatter.string(from: eventEndDate as Date)
        print(stringEndDate)
        let eventEndStringDateArr = stringEndDate.components(separatedBy: " ")
        let eventEndTime:String = eventEndStringDateArr[1]
        let user = Auth.auth().currentUser
        let id = UUID().uuidString
        let newEvent:[String:Any] = ["postID": id,
                                     "uid":user!.uid,
                                     "postTitle":self.eventTitleLabel.text!,
                                     "date": eventDateString,
                                     "timeStart": eventStartTime,
                                     "timeStop": eventEndTime,
                                     "location": ("\(locValue.latitude),\(locValue.longitude)"),
                                     "description": descriptionField.text!]
        self.ref.child("posts").child(id).setValue(newEvent)
        eventTitleLabel.text = nil
        durationField.text = nil
        locationField.text = nil
        descriptionField.text = nil
        self.tabBarController!.selectedIndex = 0;

    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

}
