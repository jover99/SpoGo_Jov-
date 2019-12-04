//
//  Games.swift
//  SpoGo
//
//  Created by Richard Jove on 12/2/19.
//  Copyright © 2019 Richard Jove. All rights reserved.
//

import Foundation
import Firebase

class Games {
    var gamesArray = [Game]()
    var db: Firestore!
    
    init () {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("games").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.gamesArray = []
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let game = Game(dictionary: document.data()) //Will load a dictionary up for us
                game.documentID = document.documentID
                self.gamesArray.append(game)
            }
            completed()
        }
    }
    
    
}
