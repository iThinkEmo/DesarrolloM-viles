//
//  PantallaOrdenes.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/16/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit

class PantallaOrdenes: UITableViewController {

    public var service: GTLRDriveService? = nil
    
    var jsonObj : [String: Any]?
    var jsonArr : [Any]? = [Any]()
    var keysArr = [String]()
    var itemsArr = [String : Any]()
    var jsonObjUpdate = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = jsonObj!["items"]! as! [String : Any]
        for (key, element) in items {
            jsonArr!.append(element)
            keysArr.append(key)
        }
        let fileId = "1dhF_MLdMQ9PIDbKvEHk6wZh_QUFhMxqS"
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        service!.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                let archivo = file as? GTLRDataObject
                if let json = try? JSONSerialization.jsonObject(with: (archivo?.data)!, options: .mutableContainers) as! [String : Any] {
                    let items = json["items"]! as! [String : Any]
                    self.itemsArr = items
                    
                }
            }
            else {
                //print("*** Error: \(error.debugDescription)")
            }
        }
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
        let size = jsonArr!.count
        return size
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaPedido", for: indexPath) as! tvCell
        let pedido = jsonArr?[indexPath.row] as! NSDictionary
        let nombre = pedido["nombre"]
        let notas = pedido["notas"]
        let total = pedido["total"]
        let horario = pedido["horario"]
        let platillos = pedido["platillos"] as! NSArray
        let comida = platillos.componentsJoined(by: ", ")
        cell.tvComida.text = "\(nombre!) pidió \(comida) a las \(horario!). Notas: \(notas!). Total: $\(total!).00"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            jsonArr?.remove(at: indexPath.row)
            tableView.reloadData()
            updateJSON(keysArr[indexPath.row])
        }
    }
    
    func updateJSON(_ id: String) {
        itemsArr.removeValue(forKey: id)
        jsonObjUpdate["items"] = itemsArr
        //print(jsonObjUpdate,"\n")
        let jsonStringPretty = JSONStringify(value: jsonObjUpdate as AnyObject, prettyPrinted: true)
        //print(jsonStringPretty)
    }
    
    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    subirJSON(data)
                    return string as String
                }
            }
            catch {
                //print("error")
            }
        }
        return ""
    }
    
    func subirJSON(_ json : Data) {
        let folderId = "1KQxUf5ki0VSwHdfUH7TVNkycWVaOQeOc"
        let metadata = GTLRDrive_File()
        metadata.name = "config.json"
        let parametros = GTLRUploadParameters(data: json, mimeType: "application/json")
        parametros.shouldUploadWithSingleRequest = true
        let fileId = "1dhF_MLdMQ9PIDbKvEHk6wZh_QUFhMxqS"
        let query = GTLRDriveQuery_FilesUpdate.query(withObject: metadata, fileId: fileId, uploadParameters: parametros)
        query.addParents = folderId
        query.fields = "id"
        self.service!.executeQuery(query) { (ticket, file, error) in
            self.executedQuery(file, error)
        }
        
    }
    
    func executedQuery(_ file : Any?, _ error : Error?) {
        if error == nil {
            let f = file as! GTLRDrive_File
            //print("Subió: \(f.identifier!)")
        } else {
            //print("Error: \(error.debugDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
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
