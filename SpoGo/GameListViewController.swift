//
//  GameListViewController.swift
//  SpoGo
//
//  Created by Richard Jove on 12/1/19.
//  Copyright © 2019 Richard Jove. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn

class GameListViewController: UIViewController {

    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //var gamesArray = ["Football","Hockey","Basketball","Soccer"]
    var games = Games()
    var locationsArray = [WeatherDetail]()
    
    var sportName = ""
    
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var newLocation = WeatherDetail(coordinates: "")
        locationsArray.append(newLocation)
        
        games.loadData {
            self.tableView.reloadData()
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() { //Sign out UI at 36:34 on 9.3
        let providers: [FUIAuthProvider] = [
          FUIGoogleAuth()
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGameDetail" {
            let destination = segue.destination as! GameDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.game = games.gamesArray[selectedIndexPath.row]
        } else {
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedPath, animated: true)
            }
        }
    }
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
    @IBAction func unwindFromSaveGameDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! GameDetailViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            games.gamesArray[selectedIndexPath.row] = source.game
            games.gamesArray[selectedIndexPath.row].saveData { (success) in
                if !success {
                    print("It didn't work")
                }
                self.tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            }
        } else {
            let newIndexPath = IndexPath(row: games.gamesArray.count, section: 0)
            games.gamesArray.append(source.game)
            games.gamesArray[newIndexPath.row].saveData { (success) in
                if !success {
                    // alert
                    print("Save didn't work")
                }
                self.tableView.insertRows(at: [newIndexPath], with: .bottom)
                self.tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
            }
        }
    }
}

extension GameListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.gamesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameTableViewCell
        let game = games.gamesArray[indexPath.row]
        cell.gameCellTextView.text = game.gameSummary
        cell.gameCellLocation.text = game.location
        cell.gameCellIcon.image = UIImage(named: game.sport)
        cell.gameCellTemp?.text = String(game.temp)
        
        if game.skillLevel == 0 {
            cell.gameCellAverageSkill.text = "Skill Level: Beginner"
        } else if game.skillLevel == 1 {
            cell.gameCellAverageSkill.text = "Skill Level: Intermediate"
        } else {
            cell.gameCellAverageSkill.text = "Skill Level: Advanced"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            games.gamesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = games.gamesArray[sourceIndexPath.row]
        games.gamesArray.remove(at: sourceIndexPath.row)
        games.gamesArray.insert(itemToMove, at: destinationIndexPath.row)
    }
}

extension GameListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            print("*** We signed in with the user \(user.email ?? "unknown email")")
        }
    }
    
}


