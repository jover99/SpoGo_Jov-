//
//  Game.swift
//  SpoGo
//
//  Created by Richard Jove on 12/2/19.
//  Copyright © 2019 Richard Jove. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON

class Game: NSObject, MKAnnotation {
    var sport: String
    var coordinate: CLLocationCoordinate2D
    var address: String
    var numPeopleNeeded: Int
    var date: Date
    var sportIcon: String
    var location: String
    var temp: Double
    var gameSummary: String
    var weatherIcon: String
    var skillLevel: Double
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var coordinateLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return location
    }
    
    var subtitle: String? {
        return address
    }
    
    var dictionary: [String: Any] {
        return ["sport": sport, "date": date, "sportIcon": sportIcon, "location": location, "temp": temp, "gameSummary": gameSummary, "address": address, "numPeopleNeeded": numPeopleNeeded, "longitude": longitude, "latitude": latitude, "weatherIcon": weatherIcon, "averageSkill": skillLevel, "postingUserID": postingUserID]
    }
    
    init(sport: String, date: Date, sportIcon: String, location: String, address: String, numPeopleNeeded: Int, coordinate: CLLocationCoordinate2D, temp: Double, gameSummary: String, weatherIcon: String, averageSkill: Double, postingUserID: String, documentID: String) {
        
        self.sport = sport
        self.date = date
        self.address = address
        self.numPeopleNeeded = numPeopleNeeded
        self.coordinate = coordinate
        self.sportIcon = sportIcon
        self.location = location
        self.temp = temp
        self.gameSummary = gameSummary
        self.weatherIcon = weatherIcon
        self.skillLevel = averageSkill
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience override init() {
        self.init(sport: "", date: Date(), sportIcon: "", location: "", address: "", numPeopleNeeded: 0, coordinate: CLLocationCoordinate2D(), temp: 0.0, gameSummary: "", weatherIcon: "", averageSkill: 0.0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        //Want to add number of people needed, sportIcon, sport result from pickerView,
        let sport = dictionary["sport"] as! String? ?? ""
        let timeStamp = dictionary["date"] as! Timestamp
        let date = timeStamp.dateValue()
        let sportIcon = dictionary["sportIcon"] as! String? ?? ""
        let location = dictionary["location"] as! String? ?? ""
        let temp = dictionary["temp"] as! Double? ?? 0.0
        let address = dictionary["address"] as! String? ?? ""
        let numPeopleNeeded = dictionary["numPeopleNeeded"] as! Int? ?? 0
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let gameSummary = dictionary["gameSummary"] as! String? ?? ""
        let weatherIcon = dictionary["weatherIcon"] as! String? ?? ""
        let averageSkill = dictionary["averageSkill"] as! Double? ?? 0.0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(sport: sport, date: date, sportIcon: sportIcon, location: location, address: address, numPeopleNeeded: numPeopleNeeded, coordinate: coordinate, temp: temp, gameSummary: gameSummary, weatherIcon: weatherIcon, averageSkill: averageSkill, postingUserID: postingUserID, documentID: "")
    }
    
    func getWeather(completed: @escaping () -> ()) {
        print(latitude)
        print(longitude)
        let weatherURL = urlBase + urlAPIKey + "\(latitude),\(longitude)"
        Alamofire.request(weatherURL).responseJSON { response in
            print("Success!")
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let temperature = json["currently"]["temperature"].double {
                    //self.temp = roundedTemp + "°F"
                    self.temp = temperature
                } else {
                    print("Could not return a temperature.")
                }
                if let icon = json["currently"]["icon"].string {
                    self.weatherIcon = icon
                } else {
                    print("Could not return an icon")
                }
            case .failure(let error):
                print(error)
            }
            completed()
        }
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //Grab the userID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("**** ERROR: Could not save data because we don't have a valid postingUserID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing the data we want to save
        let dataToSave = self.dictionary
        // if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("games").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let firestore create the new documentID
            ref = db.collection("games").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("*** ERROR: creating new document  \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ New document created with ref ID \(ref?.documentID ?? "unknown")")
                    //self.documentID = ref!.documentID
                    completed(true)
                }
            }
        }
    }
    
    func deleteData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("games").document(documentID).delete { (error) in
            if let error = error {
                print("Unable to delete document, reason: \(error)")
                completed(false)
            } else {
                print("Data deleted successfully")
                completed(true)
            }
        }
    }
}

