//
//  PantallaCheckOut.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/20/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit

class PantallaCheckOut: UIViewController {

    public var service: GTLRDriveService? = nil
    var nombre: String = ""
    var platillos = [String]()
    var horario: String = ""
    
    // Variables para el Objeto y Arreglo JSON
    var jsonObj = [String: Any]()
    var jsonArr = [String: [String: Any]]()
    
    @IBOutlet weak var tfNotas: UITextField!
    
    @IBOutlet var btnTime: [UIButton]!
    
    @IBAction func setHorario(_ sender: UIButton) {
        // Get current date components
        let date = Date()
        let calendar = Calendar.current
        let selectedTime = (sender.titleLabel?.text)!
        let selectedHour = selectedTime.prefix(upTo: selectedTime.index(of: ":")!)
        let selectedMinute = selectedTime.suffix(2)
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: date)
        dateComponents.month = calendar.component(.month, from: date)
        dateComponents.day = calendar.component(.day, from: date)
        //dateComponents.timeZone = calendar.timeZone
        dateComponents.hour = Int(selectedHour)!
        dateComponents.minute = Int(selectedMinute)!
        
        // Create date from components
        let someDateTime = calendar.date(from: dateComponents)
        let minute: Set<Calendar.Component> = [.minute]
        let difference = NSCalendar.current.dateComponents(minute, from: date, to: someDateTime!)
        
        //Check if there is a gap of at least 30 mins
        if difference.minute! < 30 {
            showAlert(title: "Alerta", message: "Este horario ya no está disponible. Selecciona otro, por favor.")
        }
        else {
            for button in btnTime {
                button.isSelected = false
            }
            sender.isSelected = true
            horario = selectedTime
        }
    }
    
    @IBAction func ordernarMenu(_ sender: Any) {
        print(service!.hashValue)
        print(nombre)
        print(platillos)
        print(horario)
        print(tfNotas.text!)
        updateJSON()
    }
    
    func updateJSON() {
        let fileId = "1dhF_MLdMQ9PIDbKvEHk6wZh_QUFhMxqS"
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        service!.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                let archivo = file as? GTLRDataObject
                if let json = try? JSONSerialization.jsonObject(with: (archivo?.data)!, options: .mutableContainers) as! [String : Any] {
                    let items = json["items"]! as! [String : Any]
                    for (key, element) in items {
                        let item = element as! NSDictionary
                        let nombre = item["nombre"] as! String
                        let platillos = item["platillos"] as! NSArray
                        let horario = item["horario"] as! String
                        let notas = item["notas"] as! String
                        self.jsonArr[key] = ["nombre": nombre, "platillos": platillos, "horario": horario, "notas": notas]
                    }
                    self.jsonArr[String(self.service!.hashValue)] = ["nombre": self.nombre, "platillos": self.platillos, "horario": self.horario, "notas": self.tfNotas.text!]
                    self.jsonObj["items"] = self.jsonArr
                    print(self.jsonObj)
                    let jsonStringPretty = self.JSONStringify(value: self.jsonObj as AnyObject, prettyPrinted: true)
                    print(jsonStringPretty)
                }
            }
            else {
                print("*** Error: \(error.debugDescription)")
            }
        }
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
                print("error")
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
            print("Subió: \(f.identifier!)")
            showAlert(title: "Aviso", message: "Todo listo. Te vemos a las \(horario).")
        } else {
            print("Error: \(error.debugDescription)")
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
