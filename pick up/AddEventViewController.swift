//
//  AddEventViewController.swift
//  pick up
//
//  Created by KYLE C BIBLE on 5/18/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import UIKit
import MapKit

class AddEventViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var delegate: AddEventViewControllerDelegate?
    var data: CLLocationCoordinate2D?
    var zoomedIn = false

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sportSelector: UISegmentedControl!
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonPressed(by: self)
    }
    
    @IBAction func addpin(_ sender: UILongPressGestureRecognizer) {
        let mylocation = sender.location(in: self.map)
        let locCoord = self.map.convert(mylocation, toCoordinateFrom:self.map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        annotation.title = "Play Here?"
        
        self.map.removeAnnotations(map.annotations)
        self.map.addAnnotation(annotation)
        }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        var sport: String?
        switch sportSelector.selectedSegmentIndex {
        case 0:
            sport = "Basketball"
        case 1:
            sport = "Football"
        case 2:
            sport = "Soccer"
        case 3:
            sport = "Baseball"
        case 4:
            sport = "Tennis"
        case 5:
            sport = "Volleyball"
        case 6:
            sport = "Ping Pong"
        default:
            sport = "Basketball"
        }
        let message = textField.text
        let chosenLocation = removeUserLocationFromArr(arr: map.annotations)[0]
        if chosenLocation is MKUserLocation {
            let alert = UIAlertController(title: "Alert", message: "Tap and hold to place a pin!", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
        }
        else {
             delegate?.doneButtonPressed(by: self, data: (String(chosenLocation.coordinate.latitude),String(chosenLocation.coordinate.longitude), sport!, message!))
        }
    }
    
    let locationManager = CLLocationManager()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        if !zoomedIn {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegionMake(myLocation, span)
            map.setRegion(region, animated: false)
            zoomedIn = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.map.delegate = self
        map.showsUserLocation = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeUserLocationFromArr(arr: [MKAnnotation]) -> [MKAnnotation] {
        var myArr = arr
        if myArr.count > 1 {
        for i in 0..<myArr.count {
            if myArr[i] is MKUserLocation {
                myArr.remove(at: i)
                return myArr
            }
        }
        }
        return myArr
    }
    

}
