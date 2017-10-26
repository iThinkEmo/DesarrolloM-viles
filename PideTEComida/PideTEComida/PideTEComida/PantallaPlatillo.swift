//
//  PantallaPlatillo.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 10/26/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import UIKit

class PantallaPlatillo: UIViewController {
    
    public var titulo: String = "____"
    public var descripcion: String = "____"
    
    @IBOutlet weak var lbPlatillo: UILabel!
    @IBOutlet weak var tfDesc: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        lbPlatillo.text = titulo
        tfDesc.text = descripcion
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
