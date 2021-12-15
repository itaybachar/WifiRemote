//
//  ViewController.swift
//  WifiRemote
//
//

import UIKit
import Network

class MainViewController: UIViewController {

    //Main Screen
    @IBOutlet weak var HostnameField: UITextField!
    @IBOutlet weak var PortField: UITextField!
    @IBOutlet weak var ConnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    @IBAction func onConnect(_ sender: Any) {
        //Get Hostname
        let inHost = HostnameField.text!
        let inPort = Int(PortField.text!)
        
        if inHost.isEmpty || inPort == nil{
            print("Empty Field")
            return
        }
        
        let udpCon = UDPClient(host: inHost,port: inPort!)
        
        if(udpCon.connect() == 0)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RemoteScreen") as! RemoteViewController
            vc.client = udpCon
            self.present(vc, animated: true, completion: nil);
        }
    }
    

}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
