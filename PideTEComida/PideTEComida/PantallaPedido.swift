//
//  PantallaPedido.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/2/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit

class PantallaPedido: UITableViewController {
    
    public var service: GTLRDriveService? = nil
    var nombre: String = ""

    var platillosArr = [String]()
    var preciosArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platillosArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaBD", for: indexPath)
        cell.textLabel?.text = platillosArr[indexPath.row]
        cell.detailTextLabel?.text = preciosArr[indexPath.row]
        return cell
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let checkout = segue.destination as! PantallaCheckOut
        checkout.service = service!
        checkout.nombre = nombre
        checkout.platillos = platillosArr
    }
    

}
