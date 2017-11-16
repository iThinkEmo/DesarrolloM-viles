//
//  PantallaAdmin.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/15/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class PantallaAdmin: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeDrive]
    //private let scopes = [kGTLRAuthScopeDriveReadonly]
    
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    //let output = UITextView()
    
    // Variables para el Objeto y Arreglo JSON
    var jsonObj = [String: Any]()
    var jsonArr = [String: [String: String]]()
    // Esta variable se modifica cuando encuentra un json en la carpeta y le asigna su id
    var jsonId = ""
    
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
    
    // MARK: - JSON Managment
    
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
        let data = UIImagePNGRepresentation(img)!
        let folderId = "1Rtj5aRRBAl0kRg67NjqH3g9lghxLjGb3"
        
        let metadata = GTLRDrive_File()
        metadata.name = tfTitulo.text! + ".jpg"
        metadata.parents = [folderId]
        
        let parametros = GTLRUploadParameters(data: data, mimeType: "image/jpeg")
        parametros.shouldUploadWithSingleRequest = true
        let query = GTLRDriveQuery_FilesCreate.query(withObject: metadata, uploadParameters: parametros)
        
        query.fields = "id"
        self.service.executeQuery(query) { (ticket, file, error) in
            self.aiEspera.stopAnimating()
            let f = file as! GTLRDrive_File
            if error == nil {
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
    
    @IBAction func subirMenu(_ sender: Any) {
        aiEspera.startAnimating()
        let jsonStringPretty = JSONStringify(value: jsonObj as AnyObject, prettyPrinted: true)
        print(jsonStringPretty)
        showAlert(title: "Aviso", message: "Se subió el menú del día exitosamente.")
    }
    
    func listFiles(_ id: String) -> Int {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 20
        query.q = "'\(id)' in parents"
        service.shouldFetchNextPages = true
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
        print(size)
        return size
    }
    
    // Número de arhivos .json dentro de la carpeta dada
    var size : Int = 0
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRDrive_FileList,
                                       error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            size = 0
        }
        if let files = result.files, !files.isEmpty {
            jsonId = files[0].identifier!
            size = 1
        } else {
            print ("No files found.")
            size = 0
        }
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
            self.service.executeQuery(query) { (ticket, file, error) in
                self.executedQuery(file, error)
            }
        }
        else {
            let fileId = jsonId
            let query = GTLRDriveQuery_FilesUpdate.query(withObject: metadata, fileId: fileId, uploadParameters: parametros)
            query.addParents = folderId
            query.fields = "id"
            self.service.executeQuery(query) { (ticket, file, error) in
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signIn()
        aiEspera.stopAnimating()
    }
    

    // MARK: - Fixing Keyboard Input
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }
    
    @objc func mostrarAlerta(_ mensaje: String) {
        print("Alerta")
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        let aceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(aceptar)
        self.present(alerta, animated: true, completion: nil)
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
        service.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                let archivo = file as? GTLRDataObject
                if let json = try? JSONSerialization.jsonObject(with: (archivo?.data)!, options: .mutableContainers) as! [String : Any] {
                    let items = json["items"]! as! [String : Any]
                    //print(items)
                    for (key, element) in items {
                        let item = element as! NSDictionary
                        let nombre = item["nombre"]
                        print(nombre)
                        let platillos = item["platillos"] as! NSArray
                        let horario = item["horario"]
                        let notas = item["notas"]
                        print("platillos: \(platillos)")
                    }
                }
            }
            else {
                print("*** Error: \(error.debugDescription)")
            }
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*let menuVC = segue.destination as! PantallaMenu
        menuVC.signInButton.isHidden = false*/
        
    }

}
