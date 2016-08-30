//
//  ViewController.swift
//  PeticionServidor
//
//  Created by Yoco Hernández on 28/08/16.
//  Copyright © 2016 Yoco. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var isbnTextField: UITextField!
  @IBOutlet weak var autorLabel: UILabel!
  @IBOutlet weak var tituloLabel: UILabel!
  @IBOutlet weak var portadaImageView: UIImageView!
  
  @IBAction func textFieldDoneEditing(sender:UITextField){
    sender.resignFirstResponder()
    //9780963097002
    //9788437604947
    //9780787955496 
    //9783161484100
    //9780246121004
    //9785949621530
    asincrono(isbnTextField.text)
  }
  
  
  func asincrono(ISBN:String?){
    
    if (ISBN != "") {
      let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(ISBN!)"
      let url = NSURL(string: urls)
      let session = NSURLSession.sharedSession()
      
      let bloque = { (datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
        
        if (error == nil){
          
          do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dico1 = json as! NSDictionary
            
            if let diccionario = dico1["ISBN:\(ISBN!)"] {
              let dico2 = diccionario as! NSDictionary
              let arreglo1 = dico2["authors"] as! NSArray
              let dico3 = arreglo1[0] as! NSDictionary
              let autor = dico3["name"] as! NSString as String
              let titulo = dico2["title"] as! NSString as String
              
              if let imagenes = dico2["cover"] {
                let dico4 = imagenes as! NSDictionary
                let urlPortada = dico4["medium"] as! NSString as String
                
                let url = NSURL(string: urlPortada)
                let datos = NSData(contentsOfURL: url!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                  self.portadaImageView.image = UIImage(data: datos!)
                })
                
              }
              else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                  self.portadaImageView.image = nil
                })
              }
              
              //esta parte del dispatch al main queue es para que se puedan modificar las labels
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.autorLabel.text = autor
                self.tituloLabel.text = titulo
              })
              
            }
            else {
              dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertController(title: "¡Ups!", message: "El libro que buscaste no se encuentra en openlibrary.org", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ni modo", style: .Default, handler: { (action) -> Void in
                  
                  self.dismissViewControllerAnimated(true, completion: nil)
                  
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
              })
            }
            
          }//cierre del do
          catch _ {
            
          }
          
          
        }
        else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: "Hubo un error", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
              
              self.dismissViewControllerAnimated(true, completion: nil)
              
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
          })
          
        }
        
      }//cierre del bloque
      
      let dt = session.dataTaskWithURL(url!, completionHandler: bloque)
      dt.resume()
    }
    else {
      let alert = UIAlertController(title: "¡Ups!", message: "Por favor introduce un ISBN", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
      }))
      
      self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
  }//cierre de asincrono


  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    isbnTextField.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

