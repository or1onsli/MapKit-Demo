//
//  MyJourneysViewController.swift
//  TheFloowExercise
//
//  Created by Andrea Vultaggio on 30/05/2017.
//  Copyright © 2017 Andrea Vultaggio. All rights reserved.
//

import UIKit

class MyJourneysViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var journeys: [Journey] = []                                                    //array which contains the list of all my saved journeys
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
            journeys = JourneyManager.shared.getData()
            self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let journey = journeys[indexPath.row]
        
        
        if let date = journey.date {
            cell.textLabel?.text = "My Journey On " + date
        }
        
        if let start = journey.startTime, let end = journey.endTime {
            cell.detailTextLabel?.text = "From " + start + " to " + end
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //get the journey corresponding to the current cell
            let journey = journeys[indexPath.row]
            //delete the journey from CoreData
            context.delete(journey)
            //save the context
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //remove the journey from the array source
            journeys.remove(at: indexPath.row)
            //call the deleteRows for removing it from the TableView graphically
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            do {
                //fetch the updated content of CoreData
                journeys = try context.fetch(Journey.fetchRequest())
            } catch {
                print(error.localizedDescription)
            }
            
        } else if editingStyle == .insert {}
        
        //reload tableView's data
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get the selected journey and perform the segue for the launch of the detailViewController
        let journey = journeys[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: journey)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //In this few line of code I pass the right Journey entity for the selected row at the DetailViewController which will be showed up after the segue
        if segue.identifier == "detailSegue", let message = sender as? Journey {
                let destinationVC = segue.destination as! DetailViewController
                destinationVC.journey = message
        }
    }

}
