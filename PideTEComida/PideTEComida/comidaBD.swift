//
//  comidaBD.swift
//  PideTEComida
//
//  Created by Aldo Reyna Gomez on 11/2/17.
//  Copyright © 2017 Aldo Reyna Gomez. All rights reserved.
//

import Foundation

class comidaBD {
    
    // Apuntador al objeto que representa la Base de Datos
    var baseDatos: OpaquePointer? = nil
    var id: String? = nil
    var comida: String? = nil
    var costo: Decimal? = nil

    func obtenerPath(_ salida: String) -> URL? {
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            return path.appendingPathComponent(salida)
        }
        return nil
    }

    func abrirBaseDatos() -> Bool {
        if let path = obtenerPath("baseDatos.txt") {
            if sqlite3_open(path.absoluteString, &baseDatos) == SQLITE_OK {
                return true
            }
            // Error
            print("Error al abrir la base de datos")
            sqlite3_close(baseDatos)
        }
        return false
    }

    func crearTabla() -> Bool {
        let sqlCreaTabla = "CREATE TABLE IF NOT EXISTS COMIDAS" + "(ID_GOOGLE TEXT PRIMARY KEY, COMIDA TEXT, COSTO DECIMAL)"
        var error: UnsafeMutablePointer<Int8>? = nil
        
        if sqlite3_exec(baseDatos, sqlCreaTabla, nil, nil, &error) == SQLITE_OK {
            return true
        }
        else {
            sqlite3_close(baseDatos)
            let msg = String.init(cString: error!)
            print("Error: \(msg)")
            return false
        }
    }

    func insertarDatos() {
        print(id!)
        print(comida!)
        print(costo!)
        let sqlInserta = "INSERT INTO COMIDAS VALUES(\(id!) ,\(comida!), \(costo!))"
        var error: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(baseDatos, sqlInserta, nil, nil, &error) != SQLITE_OK {
            print("Error al insertar o actualizar datos")
        }
    }

    func borrarRegistro(_ sender: Any) {
        let query = "DELETE FROM COMIDAS WHERE ID_GOOGLE = \(id ?? "")"
        var error: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(baseDatos, query, nil, nil, &error) == SQLITE_OK {
            print("Registro borrado")
        }
        else{
            print("Error al borrar: \(id ?? "")")
        }
    }
}

