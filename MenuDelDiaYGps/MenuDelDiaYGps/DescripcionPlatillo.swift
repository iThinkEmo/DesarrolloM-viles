//
//  OpcionesExtraPlatillo.swift
//  MenuDelDiaYGps
//
//  Created by Irving on 10/23/17.
//  Copyright © 2017 Artheus Proyect. All rights reserved.
//

import UIKit

class DescripcionPlatillo: UIViewController {

    let extras = ["Agua del día  + $15", "Queso extra +$5"]
    
    
    
    @IBOutlet weak var Extras: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
