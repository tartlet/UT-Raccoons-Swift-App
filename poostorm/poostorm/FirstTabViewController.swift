//
//  FirstTabViewController.swift
//  poostorm
//
//  Created by Jingsi Zhou on 11/24/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreData
import CoreLocation
import MapKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

struct LocationListEntry {
    var id: String
    var latitude: Double
    var longitude: Double
}

class FirstTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var ref:DatabaseReference!
    var posts:[Post] = []
    var coordList:[LocationListEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        eventTableView.delegate =  self
        eventTableView.dataSource = self
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
        getAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        posts.removeAll()
        self.viewDidLoad()
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
    
    func getAllData() {
        posts.removeAll()
        ref.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapDict = snapshot.value as? [String: [String: Any]] else { return }
            for snap in snapDict {
                let post = Post(userKey: snap.key, dict: snap.value)
                self.posts.append(post)
            }
            for post in self.posts {
                print(post.description!)
            }
            print("1", self.posts.count)
            print("3", self.posts.count)
            self.eventTableView.reloadData()
            print("4", self.posts.count)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(posts.count)
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "eventPostCell", for: indexPath) as! EventTableViewCell
        cell.titleLabel.text = posts[indexPath.row].postTitle!
        cell.descriptionLabel.text = posts[indexPath.row].description!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)
        eventTableView.deselectRow(at: indexPath, animated: true)
        let selectionLocation = posts[indexPath.row].location
        let selectionLocationSplit = selectionLocation?.components(separatedBy: ",")
        guard let latitude = Double(selectionLocationSplit![0]),
              let longitude = Double(selectionLocationSplit![1]) else {
            print("invalid input")
            return}
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
        mapView.addAnnotation(annotation)
    }

    @IBAction func seeAllAnnotations(_ sender: Any) {
        coordList.removeAll()
        getAllLocations()
        addAllAnnotations(coordsList: coordList)
    }

    func getAllLocations() {
        for post in posts {
            let selectionLocation = post.location
            let selectionLocationSplit = selectionLocation?.components(separatedBy: ",")
            guard let latitude = Double(selectionLocationSplit![0]),
                  let longitude = Double(selectionLocationSplit![1]) else {
                print("invalid input")
                return}
            coordList.append(LocationListEntry(id:"\(post.postID!)",
                                               latitude: latitude,
                                               longitude: longitude))
        }
        print(coordList)
    }
    
    func addAllAnnotations(coordsList:[LocationListEntry]){
        mapView.removeAnnotations(mapView.annotations)
            for coord in coordsList{
                print(coord)
                let CLLCoordType = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude);
                let annotation = MKPointAnnotation()
                annotation.title = coord.id
                annotation.coordinate = CLLCoordType
                mapView.addAnnotation(annotation)
            }
        }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        return pinView
    }
    
}
