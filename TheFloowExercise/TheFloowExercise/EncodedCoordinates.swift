//
//  EncodedCoordinates.swift
//  TheFloowExercise
//
//  Created by Andrea Vultaggio on 31/05/2017.
//  Copyright © 2017 Andrea Vultaggio. All rights reserved.
//

import Foundation

//this is a class (conform to the NSCoding protocol) which I use as a wrapper for storing a tuple with user's coordinates
class EncodedCoordinates: NSObject, NSCoding {
    var coordinates: (lat: Double, lon: Double)!
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        let x = decoder.decodeDouble(forKey: "latitude")
        let y = decoder.decodeDouble(forKey: "longitude")
        
        coordinates = (x , y)
    }
    
    func encode(with coder: NSCoder) {
        
        print(coordinates)
        
        coder.encode(coordinates.lat, forKey: "latitude")
        coder.encode(coordinates.lon, forKey: "longitude")
    }
}

