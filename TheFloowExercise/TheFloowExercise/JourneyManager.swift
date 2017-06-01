//
//  JourneyManager.swift
//  TheFloowExercise
//
//  Created by Andrea Vultaggio on 31/05/2017.
//  Copyright © 2017 Andrea Vultaggio. All rights reserved.
//

import UIKit
import CoreLocation

//This is a singleton class which I use for managing all the Journey related datas
final class JourneyManager {
   
    static let shared = JourneyManager()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var startTime = ""
    
    private init() {}
    
    //This function stores a single Journey as a new entity in CoreData
    func store(_ path: [EncodedCoordinates]) {
        
        print(path)
        
        let journey = Journey(context: context)
        let path = NSKeyedArchiver.archivedData(withRootObject: path)
        
        journey.path = NSData(data: path)
        journey.date = getDate()
        journey.endTime = getTime()
        journey.startTime = startTime
        
        startTime = ""
        delegate.saveContext()
    }
    
    //This function unwraps a Journey entity and gets all the necessary infos from the attributes
    func getJourneyInfo(_ journey: Journey)  -> [String : String]{
        
        var info = [String: String]()
        
        //decoding the path's array from an NSData object, if I have a path it is a valid object so I start decoding the other informations
        if let path: [EncodedCoordinates] = NSKeyedUnarchiver.unarchiveObject(with: (journey.path! as Data)) as? [EncodedCoordinates] {
            
            //getting and formatting the start position
            let startPosition: (String, String) = (String(format: "%.2f",(path.first?.coordinates.0)!), String(format: "%.2f",(path.first?.coordinates.1)!))
            let endPosition: (String, String) = (String(format: "%.2f",(path.last?.coordinates.0)!), String(format: "%.2f",(path.last?.coordinates.1)!))
            
            //I map the userPath array
            let locations = path.map {
                return CLLocation(latitude: $0.coordinates.0, longitude: $0.coordinates.1)
            }
            
            //Then I enumerate the mapping array...
            let enumeratedLocations = locations.enumerated()
            
            //...and I create tuples with all the adiacent positions
            let coupledLocations = enumeratedLocations.map {
                (index, loc) -> (CLLocation, CLLocation?) in
                
                let nextLoc: CLLocation? = index + 1 < locations.count ? Array<CLLocation>(locations)[index + 1] : nil
                
                return (loc, nextLoc)
            }
            
            //then I map an array with all the distances between the coordinates of every single tuple
            let distances = coupledLocations.map { (loc, next) -> CLLocationDistance in
                if let nextLoc = next {
                    return loc.distance(from: nextLoc)
                } else {
                    return 0
                }
            }
            
            //and then I sum them for getting the journey elapsed distance
            let distanceInMeters = distances.reduce(0, +)
            let distanceInMiles = distanceInMeters / 1609.344
            
            //then I fill the info dictionary
            info = ["Date" : journey.date!, "From" : "lat: " + startPosition.0 + ", lon: " + startPosition.1, "To" : "lat: " + endPosition.0 + ", lon: " + endPosition.1, "Started At" : journey.startTime!, "Stopped At" : journey.endTime!, "Distance" : "\(distanceInMiles)"]
        }
        
        
        
        return info
    }
    
    //this function retrieves all the entries from CoreData
    func getData() -> [Journey]{
        
        var journeys: [Journey] = []
        
        do{
            journeys = try context.fetch(Journey.fetchRequest())
        }catch{
            print(error.localizedDescription)
        }
        
        return journeys
    }
    
    //This functions temporary saves the starting time of the journey
    func getStart() -> Void {
        
        startTime = getTime()

    }
    
    //This function gets the date of the journey
    private func getDate() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return "\(day)/\(month)/\(year)"
    }
    
    //This function gets the time, in general...
    private func getTime() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        return "\(hour):\(minutes):\(seconds)"
    }
}
