//
//  PantallaPlatilloCVC.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/30/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class PantallaMenu: UICollectionViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    let modeloBD = comidaBD()
    var baseDatos: OpaquePointer? = nil
    
    var fileIdArr: [String]? = [String]()
    var imgArr: [UIImage]? = [UIImage]()
    var selectedRow: Int? = 0
    var selectedImg: UIImage? = UIImage()
    public var pedidoArr: [String]? = [String]()
    var archivoMenu : GTLRDataObject? = nil
    
    // Variables para el Objeto y Arreglo JSON
    public var jsonObj = [String: Any]()
    public var jsonArr = [String]()
    
    @IBOutlet weak var aiEspera: UIActivityIndicatorView!
    
    // MARK: - Google Sign In
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeDriveReadonly]
    
    @IBOutlet weak var signInButton: GIDSignInButton! = GIDSignInButton()
    private let service = GTLRDriveService()
    //let signInButton = GIDSignInButton()
    let output = UITextView()
    
    @IBAction func signInWithGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signIn()
        //sender.isHidden = true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            let email = user.profile.email
            print(email ?? "No tiene correo")
            if (email == "a01169073@itesm.mx") {
                performSegue(withIdentifier: "segueAdmin", sender: self)
            }
            else {
                self.signInButton.isHidden = true
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                aiEspera.startAnimating()
                listFiles()
            }
        }
    }
    
    // List up to 20 files in Drive
    func listFiles() {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 20
        query.q = "'1Sz9T4HX2j-Z3DYoUOuiQyNalkcxJxOJN' in parents"
        query.orderBy = "modifiedTime desc"
        service.shouldFetchNextPages = true
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRDrive_FileList,
                                       error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        if let files = result.files, !files.isEmpty {
            let fileId = files[0].identifier
            let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId!)
            service.executeQuery(query) { (ticket, file, error) in
                if error == nil {
                    self.archivoMenu = file as? GTLRDataObject
                    if let json = try? JSONSerialization.jsonObject(with: (self.archivoMenu?.data)!, options: .mutableContainers) as! [String : Any]{
                        let items = json["items"] as! NSDictionary
                        let fileIds = items.allKeys
                        print("Estas son las file ids")
                        print(fileIds)
                        self.fileIdArr = fileIds as? [String]
                        print("File arr ", self.fileIdArr!)
                        self.myCollectionView.reloadData()
                    }
                }
                else {
                    print("*** Error: \(error.debugDescription)")
                }
            }
        } else {
            print ("No files found.")
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
    
    @IBAction func signingOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        print("fuera")
        // Unhide the sign in button
        self.signInButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let itemSize = UIScreen.main.bounds.width/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        myCollectionView.collectionViewLayout = layout
        aiEspera.stopAnimating()
        print(jsonArr)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - JSON Managment
    
    func parseJSON(_ platilloVC: PantallaPlatillo){
        if let json = try? JSONSerialization.jsonObject(with: (archivoMenu?.data)!, options: .mutableContainers) as! [String : Any]{
            let items = json["items"] as! NSDictionary
            let item = items[fileIdArr![selectedRow!]] as! NSDictionary
            let title = item["title"] ?? ""
            let desc = item["description"] ?? ""
            let price = item["price"] ?? ""
            print("Titulo: \(title)")
            print("Descripción: \(desc)")
            print("Costo: \(price)")
            print("\n")
            platilloVC.titulo = title as? String
            platilloVC.descripcion = desc as? String
            platilloVC.costo = price as? String
        }
    }
    
    
    @IBAction func rastrearOrden(_ sender: UIButton) {
        performSegue(withIdentifier: "segueMapa", sender: self)
    }
    
    @IBAction func verOrden(_ sender: Any) {
        print(self.pedidoArr ?? "no hay pedido")
        modeloBD.abrirBaseDatos()
        performSegue(withIdentifier: "seguePedido", sender: self)
    }
    
    // Return selected image
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:
        IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! myCell
        if (cell.imgCell.image != nil){
            selectedImg = cell.imgCell.image!
            selectedRow = indexPath.row
            performSegue(withIdentifier: "seguePlatillo", sender: self)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seguePlatillo" {
            let platilloVC = segue.destination as! PantallaPlatillo
            platilloVC.imagen = selectedImg!
            platilloVC.codigo = fileIdArr![selectedRow!]
            print(fileIdArr![selectedRow!])
            parseJSON(platilloVC)
        }
        else if segue.identifier == "seguePedido" {
            let datos = segue.destination as! PantallaPedido
            datos.baseDatos = baseDatos
            let sqlConsulta = "SELECT * FROM COMIDAS"
            var declaracion: OpaquePointer? = nil
            if sqlite3_prepare_v2(baseDatos, sqlConsulta, -1, &declaracion, nil) == SQLITE_OK {
                while sqlite3_step(declaracion) == SQLITE_ROW {
                    let id = String.init(cString: sqlite3_column_text(declaracion, 0))
                    let comida = String.init(cString: sqlite3_column_text(declaracion, 1))
                    let precio = String.init(cString: sqlite3_column_text(declaracion, 2))
                    print("\(id), \(comida), \(precio)")
                    let currencyFormatter = NumberFormatter()
                    currencyFormatter.usesGroupingSeparator = true
                    currencyFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
                    currencyFormatter.locale = NSLocale.current
                    let priceString = currencyFormatter.string(from: Double(precio+".00")! as NSNumber)
                    datos.comidas!.append(comida)
                    datos.precios!.append(precio)
                }
            }
        }
    }
    
    

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fileIdArr!.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Img Arr ", imgArr!)
        aiEspera.startAnimating()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        let fileId = fileIdArr![indexPath.row]
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        service.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                let archivo = file as! GTLRDataObject
                print("\n\n___Descargado: \(file.debugDescription)")
                let img = UIImage(data: archivo.data)
                self.imgArr!.append(img!)
                cell.imgCell.image = img!
                self.aiEspera.stopAnimating()
            }
            else {
                print("*** Error: \(error.debugDescription)")
            }
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
