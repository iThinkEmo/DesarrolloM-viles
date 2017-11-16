//
//  PantallaPedido.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/2/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import UIKit

class PantallaPedido: UITableViewController {

    var baseDatos: OpaquePointer? = nil
    var comidas: [String]?
    var precios: [String]?
    
    let modeloBD = comidaBD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modeloBD.abrirBaseDatos()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        var declaracion: OpaquePointer? = nil
        let sqlCount = "SELECT COUNT(*) FROM COMIDAS"
        if sqlite3_prepare_v2(baseDatos, sqlCount, -1, &declaracion, nil) == SQLITE_OK {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(declaracion) == SQLITE_ROW ) {
                let count = sqlite3_column_int(declaracion, 0)
                return Int(count)
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaBD", for: indexPath)

        cell.textLabel?.text = comidas?[indexPath.row]
        cell.detailTextLabel?.text = precios?[indexPath.row]

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
