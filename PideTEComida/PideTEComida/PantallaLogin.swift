//
//  PantallaLogin.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/19/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class PantallaLogin: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var nombre : String = ""
    
    // MARK: - Google Sign In
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeDrive]
    
    @IBOutlet weak var signInButton: GIDSignInButton! = GIDSignInButton()
    let service = GTLRDriveService()
    
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
            nombre = user.profile.name
            print(nombre)
            if (email == "a01169073@itesm.mx") {
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                performSegue(withIdentifier: "segueAdmin", sender: self)
            }
            else {
                self.signInButton.isHidden = true
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                performSegue(withIdentifier: "segueMenu", sender: self)
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
    
    @IBAction func signingOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        print("fuera")
        // Unhide the sign in button
        self.signInButton.isHidden = false
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAdmin" {
            let adminVC = segue.destination as! PantallaAdmin
            adminVC.service = self.service
        }
        if segue.identifier == "segueMenu" {
            let menuVC = segue.destination as! PantallaMenu
            menuVC.service = self.service
            menuVC.nombre = nombre
        }
    }
    

}
