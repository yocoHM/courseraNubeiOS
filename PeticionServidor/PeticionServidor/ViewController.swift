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
  @IBOutlet weak var resultadoTextView: UITextView!
  
  @IBAction func textFieldDoneEditing(sender:UITextField){
    sender.resignFirstResponder()
    asincrono(isbnTextField.text)
  }
  
  func asincrono(ISBN:String?){
    
    if (ISBN != "") {
      let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(ISBN!)"
      let url = NSURL(string: urls)
      let session = NSURLSession.sharedSession()
      
      let bloque = { (datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
        
        if (error == nil){
          let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
          //esta parte del dispatch al main queue es para que se pueda modificar el textView
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.resultadoTextView.text = texto! as String
          })
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

