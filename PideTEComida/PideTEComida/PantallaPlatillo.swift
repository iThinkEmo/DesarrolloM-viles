//
//  PantallaPlatillo.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/30/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import UIKit

class PantallaPlatillo: UIViewController, UINavigationControllerDelegate {
    
    var descripcion : String?
    var titulo : String?
    var codigo : String?
    var costo  : String?
    var imagen : UIImage?
    
    // Variables para el Objeto y Arreglo JSON
    var jsonObj = [String: Any]()
    var jsonArr = [String]()

    @IBOutlet weak var tfDescripcion: UITextView!
    @IBOutlet weak var lbTitulo: UILabel!
    @IBOutlet weak var imgPlatillo: UIImageView!
    @IBOutlet weak var btnAgregar: UIButton!
    
    // Variable que hace regerencia al modelo
    let modeloBD = comidaBD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        tfDescripcion.text = descripcion!
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
        let alert = UIAlertController(title: "  ", message: "Este platillo se agregó a tu orden.", preferredStyle: .alert)
        let accept = UIAlertAction(title: "Continuar", style: .default){
            (alerta) in print("cerrar")}
        alert.addAction(accept)
        present(alert, animated: true, completion: nil)
        /*modeloBD.abrirBaseDatos()
        modeloBD.crearTabla()
        modeloBD.id = codigo
        modeloBD.comida = titulo
        modeloBD.costo = 14
        modeloBD.insertarDatos()*/
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if (parent == nil) {
            print("Back Button Pressed x2!")
            let menu = parent as? PantallaMenu
            menu?.jsonArr.append(titulo!)
            print(menu?.jsonArr)
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        if (parent == nil) {
            print("Back Button Pressed!")
            
        }
    }
 

}
