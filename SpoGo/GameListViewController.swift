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
    
    var games = Games()
    var game = Game()
    var sportName = ""
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        games.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        games.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() { //Sign out UI at 36:34 on 9.3
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI.providers = providers
            present(authUI.authViewController(), animated: true, completion: nil)
        } else {
            tableView.isHidden = false
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
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            print("Attempt to dismiss")
            dismiss(animated: true, completion: nil)
        } else {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
        }
    }
    
    @IBAction func signOutBarButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
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
        game.getWeather {
            let roundedTemp = String(format: "%3.f", game.temp)
            cell.gameCellTemp?.text = "\(roundedTemp)°F"
            cell.gameCellWeatherIcon.image = UIImage(named: "\(game.weatherIcon)")
        }
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
            let game = games.gamesArray[indexPath.row]
            game.deleteData() { (success) in
                if success {
                    print("Deleted Successfully!")
                } else {
                    print("Error: Delete Unsuccessful!")
                }
            }
        }
    }
}

extension GameListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            tableView.isHidden = false
            print("*** We signed in with the user \(user.email ?? "unknown email")")
        }
    }
}


