//
//  PantallaPlatillo.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/30/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import UIKit

protocol MyProtocol {
    func agregarPlatillo(platillo: String, precio: String, codigo: String)
}

class PantallaPlatillo: UIViewController, UINavigationControllerDelegate {
    
    var descripcion : String?
    var titulo : String?
    var codigo : String?
    var costo  : String?
    var imagen : UIImage?
    var myProtocol : MyProtocol?
    
    // Variables para el Objeto y Arreglo JSON
    var jsonObj = [String: Any]()
    var jsonArr = [String]()


    @IBOutlet weak var tvDescripcion: UITextView!
    @IBOutlet weak var lbTitulo: UILabel!
    @IBOutlet weak var imgPlatillo: UIImageView!
    @IBOutlet weak var btnAgregar: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        tvDescripcion.text = descripcion!
        lbTitulo.text = titulo!
        imgPlatillo.image = imagen!
        btnAgregar.setTitle("Agregar a mi pedido   $\(costo ?? "0").00", for: .normal)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func agregarPlatillo(_ sender: Any) {
        showAlert(title: "Aviso", message: "Este platillo se agregó a tu orden.")
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        currencyFormatter.locale = NSLocale.current
        let priceString = currencyFormatter.string(from: Double(costo!+".00")! as NSNumber)
        myProtocol?.agregarPlatillo(platillo: titulo!, precio: priceString!, codigo: codigo!)
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
 

}
