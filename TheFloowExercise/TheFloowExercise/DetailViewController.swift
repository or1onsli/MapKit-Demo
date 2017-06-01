//
//  ViewController.swift
//  TheFloowExercise
//
//  Created by Andrea Vultaggio on 30/05/2017.
//  Copyright © 2017 Andrea Vultaggio. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!                          //outlet for the MapView
    @IBOutlet weak var tableView: UITableView!                      //outlet for the TableView containing the journey's infos
    
    var journey: Journey!                                           //variable for the Journey selected
    var journeyInfo = [String : String]()                           //variable for the info-TableView's DataSource
    var journeyPath = [EncodedCoordinates]()                        //variable for the array of coordinates which will be used for showing the journey's path
    
    let detailOrder = ["Date", "Distance", "From", "To", "Started At", "Stopped At"]    //array of convenience for displaying the infos in the table view always in the same order
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //I set the TableView delegate and DataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        //I set the mapView delegate and I disable the MapKit realtime localization
        mapView.delegate = self
        mapView.showsUserLocation = false
        
        //loading the Journey's info from the Journey entity through a singleton class which implements all the required methods
        journeyInfo = JourneyManager.shared.getJourneyInfo(journey)
        
        //loading the path drawing from the array of coordinates through a singleton class which implements all the required methods
        if let path: [EncodedCoordinates] = NSKeyedUnarchiver.unarchiveObject(with: (journey.path! as Data)) as? [EncodedCoordinates] {
            MapDrawer.shared.drawJourney(path, map: mapView)

        }
        
        //calling the reloadData() method of the tableView
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        //using the detail order array for the creation of the right entries in the right order in the tableview
        let detail = detailOrder[indexPath.row]
        
        cell.textLabel?.text = detail
        
        //using the detail string as key for keeping the right value for the current cell from my info's dictionary
        if let value = journeyInfo[detail] {
            cell.detailTextLabel?.text = value
        }
        
        return cell
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //creating a renderer for the polyline to put as overlay on the map in order to show the journey's path
        let polylineRenderer = MapDrawer.shared.setRenderer(overlay)
        return polylineRenderer
    }
    
    
}

