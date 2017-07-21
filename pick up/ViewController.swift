//
//  ViewController.swift
//  pick up
//
//  Created by KYLE C BIBLE on 5/18/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct cellData {
    let cell : Int!
    let text: String!
    let image : UIImage
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, AddEventViewControllerDelegate {
//    var pinArr = [(37.378099,-121.916571, "basketball", "come play with me!"),(37.376155, -121.898847, "basketball", "Hey Let's Play"),(37.388192, -121.874192, "basketball", "hoops over here")]
    var currentLocation: CLLocation?
//    var serverData = ServerData()
    var zoomedIn = false
    
    var pinArr = [(Double, Double, String, String, Int)]()
    var jsonObject : [Dictionary<String,Any>]?
    var serverdata = ServerData()
    
    
    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
        var id: Int!
    }
    
    func update() {
        print(serverdata.getData{jsonObj in self.getArray(jsonobj: jsonObj)})
        print(pinArr.count)
    }

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        currentLocation = location
        if !zoomedIn {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(myLocation, span)
            map.setRegion(region, animated: true)
            zoomedIn = true
        }
    }

    @IBAction func showMyLocationButtonPressed(_ sender: UIButton) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(map.userLocation.coordinate, span)
        map.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        serverdata.getData{jsonObj in self.createArray(jsonobj: jsonObj)}
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.map.delegate = self
        map.showsUserLocation = true
        //        let myData = serverData.getData()
        //Populate Table
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
            let annotation = cell.annotation
            let coordinates = annotation?.coordinate
            map.setCenter(coordinates!, animated: true)
            map.selectAnnotation(annotation!, animated: true)
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: "myAnnotation")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            annotationView!.canShowCallout = true
            
        }
        else {
            annotationView!.annotation = annotation
        }
        let cpa = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named: cpa.imageName)
        annotationView!.frame.size = CGSize(width: 35, height: 35)
        return annotationView
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func removeUserLocationFromArr(arr: [MKAnnotation]) -> [MKAnnotation] {
        var myArr = arr
        for i in 0..<myArr.count {
            if myArr[i] is MKUserLocation {
                myArr.remove(at: i)
                return myArr
            }
        }
        return myArr
    }


    
    //Grab Data Functions
    func createArray(jsonobj : [Dictionary<String,Any>]?){
        jsonObject = jsonobj
//                print(jsonObject)
        for res in jsonObject!{
            let lat = Double(res["latitude"] as! String)
            let lng = Double(res["longitude"] as! String)
            pinArr.append((lat!, lng!, res["message"] as! String, res["sport"] as! String, res["id"] as! Int))
        }
        print(pinArr.count)
        generatePins(arr: pinArr)
    }
    
    func getArray(jsonobj : [Dictionary<String,Any>]?){
        jsonObject = jsonobj
        if pinArr.count < (jsonObject?.count)! {
            let res = jsonObject?[(jsonObject?.count)!-1]
            let lat = Double(res?["latitude"] as! String)
            let lng = Double(res?["longitude"] as! String)
            pinArr.append((lat!, lng!, res?["message"] as! String, res?["sport"] as! String, res?["id"] as! Int))
            map.removeAnnotations(map.annotations)
            generatePins(arr: pinArr)
            DispatchQueue.main.async() {
                self.tableView.reloadData()
                let annotationsArr = self.map.annotations
                self.map.removeAnnotations(self.map.annotations)
                self.map.addAnnotations(annotationsArr)
            }
        }
    }
    
    func appendArray(jsonobj : [String:Any]?) {
        print("arrayfunction")
        var results = jsonobj
        let lat = Double(results?["latitude"] as! String)
        let lng = Double(results?["longitude"] as! String)
        pinArr.append((lat!, lng!, results?["message"] as! String, results?["sport"] as! String, results?["id"] as! Int))
        
        //only display pins if they are within a certain distance
        map.removeAnnotations(map.annotations)
        generatePins(arr: pinArr)
        DispatchQueue.main.async() {
            self.tableView.reloadData()
            let annotationsArr = self.map.annotations
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotations(annotationsArr)
        }
        let latitude = Double(results?["latitude"] as! String)
        let longitude = Double(results?["longitude"] as! String)
        let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(latitude!), CLLocationDegrees(longitude!))
        map.setCenter(coordinates, animated: false)
    }
    
func generatePins(arr: [(Double, Double, String, String, Int)]){
        for i in arr {
            let pinLocation = CLLocation(latitude: CLLocationDegrees(i.0), longitude: CLLocationDegrees(i.1))
            //only display pins if they are within a certain distance
            if let myLocation = locationManager.location {
                if myLocation.distance(from: pinLocation) < 50000 {
                    let pinAnnotation = CustomPointAnnotation()
                    let image = changeImageName(str: i.3)
                    let miles = Double(round((myLocation.distance(from: pinLocation)/1609.34)*10)/10)
                    pinAnnotation.coordinate = pinLocation.coordinate
                    pinAnnotation.title = i.2
                    pinAnnotation.subtitle = "\(i.3) \(miles) miles away!"
                    pinAnnotation.imageName = image
                    pinAnnotation.id = i.4
                    map.addAnnotation(pinAnnotation)
                }
            }
            
    }
    DispatchQueue.main.async() {
        let annotationsArr = self.map.annotations
        self.map.removeAnnotations(self.map.annotations)
        self.map.addAnnotations(annotationsArr)
        print("annotations", self.map.annotations.count)
        self.tableView.reloadData()
    }
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return removeUserLocationFromArr(arr: map.annotations).count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myAnnotationsArray = removeUserLocationFromArr(arr: map.annotations)
    let cell = Bundle.main.loadNibNamed("CustomTableViewCell", owner: self, options: nil)?.first as! CustomTableViewCell
    let annotation = myAnnotationsArray[indexPath.row] as! CustomPointAnnotation
    cell.mainImageView.image = UIImage(named: annotation.imageName)
    cell.mainImageView.image?.accessibilityFrame.size = CGSize(width: 35, height: 35)
    //    let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
    cell.mainLabelView.text = myAnnotationsArray[indexPath.row].title!!
    cell.annotation = myAnnotationsArray[indexPath.row]
    return cell
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let add = nav.topViewController as! AddEventViewController
        add.delegate = self
        add.data = map.userLocation.coordinate
    }
    
    func cancelButtonPressed(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed(by controller: UIViewController, data: (String, String, String, String)) {
        dismiss(animated: true, completion: nil)
        //Post Stuff
        serverdata.postData(tupe: data){jsonObj in self.appendArray(jsonobj: jsonObj)}
        let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(data.0)!, CLLocationDegrees(data.1)!)
        map.setCenter(coordinates, animated: true)
    }
   
    func changeImageName(str: String) -> String {
        var image: String?
        switch (str) {
        case "Basketball":
            image = "basketball"
            break
        case "Football":
            image = "football"
            break
        case "Ping Pong":
            image = "pingpong"
            break
        case "Soccer":
            image = "soccer"
            break
        case "Baseball":
            image = "baseball"
            break
        case "Tennis":
            image = "tennis"
            break
        case "Volleyball":
            image = "volleyball"
            break
        default:
            image = "basketball"
            break
        }
        return image!
    }

    
}
//extension UITableViewCell {
//    var annotation: MKAnnotation?
//}
