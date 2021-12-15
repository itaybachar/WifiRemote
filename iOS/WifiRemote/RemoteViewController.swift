//
//  RemoteViewController.swift
//  WifiRemote
//
//  Created by Chang Yaramothu on 12/15/21.
//

import UIKit

class RemoteViewController : UIViewController {
    
    var client: UDPClient?
    var startPosition: CGPoint?
    let mouseSpeed:CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }

    //Remote Screen
    @IBOutlet weak var MousePad: UIImageView!
    {
        didSet
        {
            MousePad.isUserInteractionEnabled=true
            MousePad.layer.cornerRadius=20
        }
    }
    
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        var diff: CGPoint
        switch (sender.state)
        {
        case UIPanGestureRecognizer.State.began:
            startPosition = sender.location(in: MousePad)
            return
        default:
            if(startPosition == nil)
            {
                return
            }
            diff = sender.location(in: MousePad) - startPosition!
        }
        var out = diff.norm().scale(mult: mouseSpeed).toString()
        out += ";"
        client!.sendUDP(out)
    }
    
    @IBAction func handleButtonClick(_ sender: UIButton) {
        var outmsg = ""
        if sender.titleLabel?.text != nil
        {
            outmsg += sender.titleLabel!.text! + ";"
        }
        client!.sendUDP(outmsg)
    }
    
    @IBAction func handleDisconnect(_ sender: Any) {
        disconnect()
    }
    
    @IBAction func returnandle(_ sender: UITextField) {
        client!.sendUDP("RET;")
    }
    @IBAction func valueChanged(_ sender: UITextField) {
        var msg = ""
        if(sender.text! == "")
        {
            msg += "BACK;"
        }
        else
        {
            msg += (sender.text?.last.map(String.init))! + ";"
        }
        sender.text = " "
        client!.sendUDP(msg)
    }
    func disconnect()
    {
        client = nil
        self.dismiss(animated: true, completion: nil)
    }
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

extension CGPoint {
    func norm() -> CGPoint
    {
        let denom = (x*x + y*y).squareRoot()
        return CGPoint(x: self.x/denom,y:self.y/denom)
    }
    
    func scale(mult: CGFloat) -> CGPoint
    {
        return CGPoint(x: self.x*mult,y:self.y*mult)
    }
    
    func toString() ->String
    {
        return String(format: "MV: %.2f,%.2f", x,y)
    }
}
