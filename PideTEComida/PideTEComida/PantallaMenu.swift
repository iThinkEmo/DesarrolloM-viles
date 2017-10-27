//
//  PantallaMenu.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/26/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class PantallaMenu: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet var imageViews: [UIImageView]!
    
    @IBOutlet weak var imgConsome: UIImageView!
    @IBOutlet weak var imgSopa: UIImageView!
    @IBOutlet weak var imgArroz: UIImageView!
    @IBOutlet weak var imgPasta: UIImageView!
    @IBOutlet weak var imgGuisado1: UIImageView!
    @IBOutlet weak var imgGuisado2: UIImageView!
    @IBOutlet weak var imgGuisado3: UIImageView!
    @IBOutlet weak var imgAgua: UIImageView!
    @IBOutlet weak var btnDesc: UIButton!
    
    
    @IBAction func showDesc(_ sender: UIButton) {
        print(sender.tag)
        performSegue(withIdentifier: "segueID", sender: self)
        
    }
    
    @IBAction func showMap(_ sender: UIButton) {
        performSegue(withIdentifier: "segueID2", sender: self)
    }
    
    @IBAction func showDescription(_ sender: UIImageView) {
        print(sender.tag)
        performSegue(withIdentifier: "segueID", sender: self)
    }
    
    func parseJSON(_ datos: Data, _ int: Int, _ segue: UIStoryboardSegue){
        if let json = try? JSONSerialization.jsonObject(with: datos, options: .mutableContainers) as! [String : Any]{
            let items = json["items"] as! NSArray
            let item = items[int] as! NSDictionary
            let title = item["title"] ?? ""
            let desc = item["description"] ?? ""
            print("Titulo: \(title)")
            print("Deescripción: \(desc)")
            print("\n")
            let platilloVC = segue.destination as! PantallaPlatillo
            platilloVC.titulo = title as! String
            platilloVC.descripcion = desc as! String
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let path = Bundle.main.path(forResource: "infoComida", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                //parseJSON(data, 2, segue)
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeDriveReadonly]
    
    
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    
    @IBAction func signingOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        print("fuera")
        // Unhide the sign in button
        self.signInButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure Google Sign-in.
        //GIDSignIn.sharedInstance().delegate = self
        //GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().scopes = scopes
        //GIDSignIn.sharedInstance().signInSilently()
        //signInButton.center = view.center
        // Add the sign-in button.
        //view.addSubview(signInButton)
        
    }
    
    @IBAction func signInWithGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signIn()
        sender.isHidden = true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            descargarArchivo()
        }
    }
    
    func descargarArchivo() {
        let fileIdArr: [String] = ["0B3extIoZ7yVrSGs3YTRGdk9kTWc","0B3extIoZ7yVrTDZWeW1MZnpoWHM", "0B3extIoZ7yVrWk9HaDVZaHNQWDg"]
        for i in 0...imageViews.count-1 {
            //imageViews[i].image = #imageLiteral(resourceName: "google")
            let fileId = fileIdArr[i]
            let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
            service.executeQuery(query) { (ticket, file, error) in
                if error == nil {
                    let archivo = file as! GTLRDataObject
                    
                    print("\n\n___Descargado: \(file.debugDescription)")
                    let img = UIImage(data: archivo.data)
                    self.imageViews[i].image = img!
                }
                else {
                    print("*** Error: \(error.debugDescription)")
                }
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
}
