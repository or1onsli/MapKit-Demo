//
//  TrackingViewController.swift
//  TheFloowExercise
//
//  Created by Andrea Vultaggio on 30/05/2017.
//  Copyright © 2017 Andrea Vultaggio. All rights reserved.
//

import UIKit
import MapKit

class TrackingViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopButton: UIButton!
    
    var userPath = [EncodedCoordinates]()                                           //array of EncodedCoordinates
    var isFirst = true                                                              //bool variable of convenience
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setup the start-stop button
        startStopButton.setTitle("Start Tracking", for: .normal)
        startStopButton.backgroundColor = .green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting the delegate for the MapView
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //setting the current user location through a singleton class which implements all the required methods
        MapDrawer.shared.setLocation(userLocation, map: mapView)
        
        //saving the coordinates in an EncodedCoordinates object
        let locationObj = EncodedCoordinates()
        locationObj.coordinates = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        //appending the coordinates' object to the UserPath array
        userPath.append(locationObj)
        
        //if is the first start of the app get the current location through MapKit and then stop the localization and pin it
        if isFirst {
            MapDrawer.shared.addPin("START", map: mapView)
            mapView.showsUserLocation = false
            isFirst = false
        }
        
        //if more than two locations have been saved start drawing the user's path through a singleton class which implements all the required methods
        if userPath.count >= 2 {
            MapDrawer.shared.drawRoute(userPath, map: mapView)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //IBAction which starts and stops the user localization
    @IBAction func startStopFunction(_ sender: UIButton) {
        
        //if I am not localizing...
        if sender.titleLabel?.text == "Start Tracking" {
            //if I have stopped the registration and I restart it
            if mapView.annotations.count > 1 {
                mapView.removeAnnotation(mapView.annotations.last!)
            }
            
            //...I get the starting time
            JourneyManager.shared.getStart()
            
            //...I start localizing the user
            mapView.showsUserLocation = true
            
            //change the button properties
            startStopButton.setTitle("Stop Tracking", for: .normal)
            startStopButton.backgroundColor = .red
            
        }
        else if sender.titleLabel?.text == "Stop Tracking" {            //if I was localizing...
            
            //I store the journey through a singleton class which implements all the required methods
            JourneyManager.shared.store(userPath)
            
            //...I stop localizing the user
            mapView.showsUserLocation = false
            //...and I add a pin to the finish point
            MapDrawer.shared.addPin("STOP", map: mapView)
            
            //change the button properties
            startStopButton.setTitle("Start Tracking", for: .normal)
            startStopButton.backgroundColor = .green
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //creating a renderer for the polyline to put as overlay on the map in order to show the journey's path
        let polylineRenderer = MapDrawer.shared.setRenderer(overlay)
        return polylineRenderer
    }
    
}

