//
//  MapDrawer.swift
//  TheFloowExercise
//
//  Created by Andrea Vultaggio on 01/06/2017.
//  Copyright © 2017 Andrea Vultaggio. All rights reserved.
//

import MapKit

final class MapDrawer {
    
    static let shared = MapDrawer()
    
    let regionRadius = 1000.0
    
    private init() {}
    
    //sets the current location for the MapView
    func setLocation(_ location: MKUserLocation, map: MKMapView) -> Void {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(region, animated: true)
    }
    
    //this function draws the journey path through an MKPolyline object
    func drawRoute(_ path: [EncodedCoordinates], map: MKMapView) -> Void {
        let numberOfSteps = path.count
        var coordinates = [CLLocationCoordinate2D]()
        
        for point in path {
            let coordinate = CLLocationCoordinate2D(latitude: point.coordinates.lat, longitude: point.coordinates.lon)
            coordinates.append(coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: numberOfSteps)
        map.add(polyline)
        
    }
    
    //this function sets the renderer for the path's polyline
    func setRenderer(_ overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(red: 58/255.0, green: 150/255.0, blue: 255/255.0, alpha: 1.0)
        polylineRenderer.lineWidth = 8.0
        
        return polylineRenderer

    }
    
    //this function adds a pin to the MapView
    func addPin(_ title: String, map: MKMapView) {
        
        let annotation = MKPointAnnotation()
        
        if let location = map.userLocation.location?.coordinate {
            annotation.coordinate = location
        }
        
        annotation.title = title
        map.addAnnotation(annotation)
    }
    
    //this function draws the polyline of an entire journey through the drawRoute function
    func drawJourney(_ path: [EncodedCoordinates], map: MKMapView) -> Void {
        
        let start = CLLocationCoordinate2D(latitude: (path.first?.coordinates.0)!, longitude: (path.first?.coordinates.1)!)
        
        let region = MKCoordinateRegionMakeWithDistance(start, regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(region, animated: true)
                
        drawRoute(path, map: map)
    }
}
