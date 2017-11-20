//
//  PantallaPlatilloCVC.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/30/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import UIKit

class PantallaMenu: UICollectionViewController, MyProtocol {

    public var service: GTLRDriveService? = nil
    var nombre: String = ""
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var fileIdArr: [String]? = [String]()
    var imgArr: [UIImage]? = [UIImage]()
    var selectedRow: Int? = 0
    var selectedImg: UIImage? = UIImage()
    var archivoMenu : GTLRDataObject? = nil
    
    // Variables para el Objeto y Arreglo JSON
    public var jsonObj = [String: Any]()
    public var platillos = [String]()
    public var costos = [String]()
    public var codigos = [String]()
    
    @IBOutlet weak var aiEspera: UIActivityIndicatorView!

    
    // List up to 20 files in Drive
    func listFiles() {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 20
        query.q = "'1Sz9T4HX2j-Z3DYoUOuiQyNalkcxJxOJN' in parents"
        query.orderBy = "modifiedTime desc"
        service!.shouldFetchNextPages = true
        service!.executeQuery(query) { (ticket, result, error) in
            let result = result as! GTLRDrive_FileList
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            if let files = result.files, !files.isEmpty {
                let fileId = files[0].identifier
                let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId!)
                self.service!.executeQuery(query) { (ticket, file, error) in
                    if error == nil {
                        self.archivoMenu = file as? GTLRDataObject
                        if let json = try? JSONSerialization.jsonObject(with: (self.archivoMenu?.data)!, options: .mutableContainers) as! [String : Any]{
                            let items = json["items"] as! NSDictionary
                            let fileIds = items.allKeys
                            self.fileIdArr = fileIds as? [String]
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
        let itemSize = UIScreen.main.bounds.width/2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 4
        myCollectionView.collectionViewLayout = layout
        listFiles()
        print(platillos)
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
            platilloVC.myProtocol = self
            print(fileIdArr![selectedRow!])
            parseJSON(platilloVC)
        }
        else if segue.identifier == "seguePedido" {
            let pedido = segue.destination as! PantallaPedido
            pedido.platillosArr = platillos
            pedido.preciosArr = costos
            pedido.service = service!
            pedido.nombre = nombre
        }
    }
    
    

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileIdArr!.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Img Arr ", imgArr!)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        let fileId = fileIdArr![indexPath.row]
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
        service!.executeQuery(query) { (ticket, file, error) in
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
    
    // MARK: - Implementation of MyProtocol
    
    func agregarPlatillo(platillo: String, precio: String, codigo: String) {
        if !codigos.contains(codigo) {
            codigos.append(codigo)
            platillos.append(platillo)
            costos.append(precio)
        }
        print(platillos)
        print(costos)
    }

}
