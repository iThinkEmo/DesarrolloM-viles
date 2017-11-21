//
//  PantallaAdmin.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/15/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//
import GoogleAPIClientForREST
import UIKit

class PantallaAdmin: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public var service: GTLRDriveService? = nil
    
    // Variables para el Objeto y Arreglo JSON
    var jsonObj = [String: Any]()
    var jsonArr = [String: [String: Any]]()
    // Esta variable se modifica cuando encuentra un json en la carpeta y le asigna su id
    var jsonId = ""
    // Número de arhivos .json dentro de la carpeta dada
    var size : Int = 0
    
    // Outlets
    @IBOutlet weak var imgPlatillo: UIImageView!
    @IBOutlet weak var tfTitulo: UITextField!
    @IBOutlet weak var tfDesc: UITextField!
    @IBOutlet weak var tfPrecio: UITextField!
    @IBOutlet weak var aiEspera: UIActivityIndicatorView!
    @IBOutlet weak var btnSubirPlatillo: UIButton!
    
    // Actions
    @IBAction func chooseImg(_ sender: Any) {
        
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imgPickerController.sourceType = .camera
                self.present(imgPickerController, animated: true, completion: nil)
            }
            else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imgPickerController.sourceType = .photoLibrary
            self.present(imgPickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgPlatillo.image = img
        picker.dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Subir Platillo a Drive en formato JSON
    
    @IBAction func subirPlatillo(_ sender: UIButton) {
        if ((imgPlatillo.image) != nil) {
            if (tfTitulo.text! == "" || tfPrecio.text! == "") {
                showAlert(title: "Alerta", message: "Debes ingresar al menos título y precio.")
            }
            else {
                btnSubirPlatillo.isUserInteractionEnabled = false
                aiEspera.startAnimating()
                subir(imgPlatillo.image!)
            }
        }
        else {
            showAlert(title: "Alerta", message: "No has escogido una imagen.")
        }
    }
    
    // Sube la foto a Drive para obtener el ID
    func subir(_ img : UIImage) {
        print(service!.authorizer!)
        let data = UIImagePNGRepresentation(img)!
        let folderId = "1Rtj5aRRBAl0kRg67NjqH3g9lghxLjGb3"
        
        let metadata = GTLRDrive_File()
        metadata.name = tfTitulo.text! + ".jpg"
        metadata.parents = [folderId]
        
        let parametros = GTLRUploadParameters(data: data, mimeType: "image/jpeg")
        parametros.shouldUploadWithSingleRequest = true
        let query = GTLRDriveQuery_FilesCreate.query(withObject: metadata, uploadParameters: parametros)
        
        query.fields = "id"
        self.service!.executeQuery(query) { (ticket, file, error) in
            self.aiEspera.stopAnimating()
            if error == nil {
                let f = file as! GTLRDrive_File
                print("Subió: \(f.identifier!)")
                self.btnSubirPlatillo.isUserInteractionEnabled = true
                self.createJSON(f)
            } else {
                print("Error: \(error.debugDescription)")
            }
        }
    }
    
    func createJSON(_ fileId : GTLRDrive_File) {
        jsonArr[fileId.identifier!] = ["title" : tfTitulo.text!, "description" : tfDesc.text!, "price" : tfPrecio.text!]
        jsonObj["items"] = jsonArr
        showAlert(title: "Aviso", message: "Se subió platillo a la base de datos.")
        tfPrecio.text = ""
        tfTitulo.text = ""
        tfDesc.text = ""
    }
    
    // MARK: - JSON Managment
    
    @IBAction func subirMenu(_ sender: Any) {
        if jsonObj.isEmpty {
            showAlert(title: "Alerta", message: "No has subido ningún platillo.")
        }
        else {
            aiEspera.startAnimating()
            let jsonStringPretty = JSONStringify(value: jsonObj as AnyObject, prettyPrinted: true)
             print(jsonStringPretty)
             showAlert(title: "Aviso", message: "Se subió el menú del día exitosamente.")
        }
    }
    
    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                subirJSON(data)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
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
        let folderId = "1Sz9T4HX2j-Z3DYoUOuiQyNalkcxJxOJN"
        let metadata = GTLRDrive_File()
        metadata.name = "config.json"
        let parametros = GTLRUploadParameters(data: json, mimeType: "application/json")
        parametros.shouldUploadWithSingleRequest = true
        let folderSize = listFiles(folderId)
        if (folderSize == 0) {
            metadata.parents = [folderId]
            let query = GTLRDriveQuery_FilesCreate.query(withObject: metadata, uploadParameters: parametros)
            
            query.fields = "id"
            self.service!.executeQuery(query) { (ticket, file, error) in
                self.executedQuery(file, error)
            }
        }
        else {
            let fileId = jsonId
            let query = GTLRDriveQuery_FilesUpdate.query(withObject: metadata, fileId: fileId, uploadParameters: parametros)
            query.addParents = folderId
            query.fields = "id"
            self.service!.executeQuery(query) { (ticket, file, error) in
                self.executedQuery(file, error)
            }
        }
    }
    
    func executedQuery(_ file : Any?, _ error : Error?) {
        self.aiEspera.stopAnimating()
        let f = file as! GTLRDrive_File
        if error == nil {
            print("Subió: \(f.identifier!)")
        } else {
            print("Error: \(error.debugDescription)")
        }
    }
    
    
    func listFiles(_ id: String) -> Int {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 20
        query.q = "'\(id)' in parents"
        service!.shouldFetchNextPages = true
        service!.executeQuery(query) { (ticket, result, error) in
            let result = result as! GTLRDrive_FileList
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                self.size = 0
            }
            if let files = result.files, !files.isEmpty {
                self.jsonId = files[0].identifier!
                self.size = 1
            } else {
                print ("No files found.")
                self.size = 0
            }
        }
        print(size)
        return size
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        aiEspera.stopAnimating()
    }
    

    // MARK: - Fixing Keyboard Input
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tfTitulo.resignFirstResponder()
        tfPrecio.resignFirstResponder()
        tfDesc.resignFirstResponder()
    }
    
    // MARK: - Navigation

    @IBAction func verPedidos(_ sender: Any) {
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
                        let total = item["total"] ?? "0"
                        self.jsonArr[key] = ["nombre": nombre, "platillos": platillos, "horario": horario, "notas": notas, "total": total]
                    }
                    self.jsonObj["items"] = self.jsonArr
                    print(self.jsonObj)
                }
                self.performSegue(withIdentifier: "seguePedidos", sender: self)
            }
            else {
                print("*** Error: \(error.debugDescription)")
            }
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let orden = segue.destination as! PantallaOrdenes
        orden.jsonObj = jsonObj
        orden.service = service
    }

}
