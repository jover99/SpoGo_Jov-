//
//  GameDetailViewController.swift
//  SpoGo
//
//  Created by Richard Jove on 12/1/19.
//  Copyright © 2019 Richard Jove. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import CoreLocation

class GameDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var numberOfPeopleTextField: UITextField!
    @IBOutlet weak var sportPickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var levelSegmentedControl: UISegmentedControl!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var gameLocationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var sportsArray = ["Football","Hockey","Basketball","Soccer","Golf","PingPong","Cricket","Bicycle","Baseball","Archery","Crew","Run","Tennis","Volleyball","Weights"]
    var game: Game!
    var locationManager: CLLocationManager!
    let regionDistance: CLLocationDistance = 750 //750 meters or about a half mile
    // let currentLocation: CLLocation!
    let currentLocation = CLLocation()
    var level: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sportPickerView.delegate = self
        self.sportPickerView.dataSource = self
        self.mapView.delegate = self
        
        if game == nil {
            game = Game()
        }
        
        let region = MKCoordinateRegion(center: self.game.coordinate, latitudinalMeters: self.regionDistance, longitudinalMeters: self.regionDistance)
        self.mapView.setRegion(region, animated: true)
        
        self.loadCurrentLocation {
            self.updateUI()
        }
    }
    
    func updateUI() {
        let i = self.sportsArray.firstIndex(of: self.game.sport) ?? 0
        self.sportPickerView.selectRow(i, inComponent: 0, animated: false)
        self.datePicker.date = self.game.date
        self.descriptionTextView.text = self.game.gameSummary
        self.levelSegmentedControl.selectedSegmentIndex = Int(self.game.skillLevel)
        //self.numberOfPeopleTextField.text =
        self.gameLocationTextField.text = self.game.location
        updateMap()
    }
    
    func loadCurrentLocation(completed: @escaping ()-> ()) {
        self.getLocation()
        print("Should have gotten location by now")
        completed()
    }
    
    func updateMap() {
        print("\(game.latitude)😎😎")
        print("*** Just updated the map")
        print("location = \(game.location)")
        print("coordinate = \(game.coordinate)")
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(game)
        mapView.setCenter(game.coordinate, animated: true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "unwindFromSave" {
//            game.saveData { (success) in //This doesn't seem to be right
//                self.game.location = self.gameLocationTextField.text ?? ""
////                self.game.getWeather {
////                    <#code#>
////                }
//                // game.sportIcon
//                // game.temp
//                // game.weatherIcon
//                self.game.gameSummary = self.descriptionTextView.text ?? ""
//                self.game.skillLevel = Double(self.levelSegmentedControl.selectedSegmentIndex)
//            }
//        }
//    }
    
    // func showAlert
    
    //MARK:- NEED TO GET THIS TO WORK PROPERLY... ISSUE IS SHOWING INITIAL VIEW CONTROLLER
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            print("Attempt to dismiss")
            dismiss(animated: true, completion: nil)
        } else { //This is not working... it's taking me too far
            print("does this shit happen?????")
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
            //for controller in self.navigationController!.viewControllers as Array {
            //    if controller.isKind(of: GameListViewController.self) {
            //        self.navigationController!.popToViewController(controller, animated: true)
            //        break
                }
            }
            //navigationController!.popToRootViewController(animated: true)
        
    
    
    @IBAction func gameLocationPressed(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        self.game.location = self.gameLocationTextField.text!
        self.game.gameSummary = self.descriptionTextView.text!
        //Insert field for sport type
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateUserInterface()
        game.saveData { success in
            if success {
                self.leaveViewController()
                print("Success!")
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func cancelBarButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        game.date = datePicker.date
    }
}

extension GameDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sportsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sportsArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        game.sport = sportsArray[row]
    }
}

extension GameDetailViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        game.location = place.name ?? "unknown place name"
        game.address = place.formattedAddress ?? "address unknown"
        gameLocationTextField.text = place.name
        game.coordinate = place.coordinate
        print(place.coordinate)
        self.mapView.setCenter(place.coordinate, animated: true)
        updateUI()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again. Show indicator that shows that progress is being made.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension GameDetailViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("Sorry, we cannot show the location because the user has not authorized it.")
        case .restricted:
            print("Access denied. Likely parental controls are restricting location services in this app.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard game.location == "" else {
            return
        }
        game.coordinate = locations.last!.coordinate
        print("Did update locations")
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}








