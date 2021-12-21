//
//  RemoteViewController.swift
//  WifiRemote
//
//  Created by Chang Yaramothu on 12/15/21.
//

import UIKit

class RemoteViewController : UIViewController {
    
    var client: UDPClient?
    var mouseStart: CGPoint?
    var mousePos: CGPoint?
    var mouseSpeed: CGFloat = 5
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    let sem = NSCondition()
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        client?.connectionFailedCallback = disconnect
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
    
    @IBAction func cursorSpeedChange(_ sender: UISlider) {
        mouseSpeed = CGFloat(sender.value)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if(sender.state == .ended)
        {
            if(sender.numberOfTouches == 1)
            {
                client!.sendUDP("Left Click")

            }
            else
            {
                client!.sendUDP("Right Click")

            }
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        var diff: CGPoint
        switch (sender.state)
        {
        case UIPanGestureRecognizer.State.began:
            mouseStart = sender.location(in: MousePad)
            
            if(sender.numberOfTouches == 1)
            {
                DispatchQueue.global().async {
                    while(self.panRecognizer.state != .ended)
                    {
                        guard let pos = self.mousePos else {
                            //usleep(10000)
                            continue
                        }
                        let out = pos.norm().scale(mult: self.mouseSpeed).toString()
                        self.client!.sendUDP(out)
                        usleep(10000)
                    }
                }
            }
            
            return
            
        case UIPanGestureRecognizer.State.ended:
            mousePos = nil
            return
        default:
            if (sender.numberOfTouches == 2)
            {
                let vel = sender.velocity(in: MousePad)
                let cur = sender.location(in: MousePad)
                if((cur-mouseStart!).magSqrd() > 80)
                {
                    mouseStart = cur
                    if(vel.y<0)
                    {
                        client?.sendUDP("\\/")
                    }
                    else
                    {
                        client?.sendUDP("/\\")
                    }
                }
            }
            else
            {
                guard let pos = mouseStart else {
                    return
                }
                mousePos = sender.location(in: MousePad) - pos
            }
        }
    }
    
    
    @IBAction func handleButtonClick(_ sender: UIButton) {
        var outmsg = ""
        if sender.titleLabel?.text != nil
        {
            outmsg += sender.titleLabel!.text!
        }
        client!.sendUDP(outmsg)
    }
    
    @IBAction func handleDisconnect(_ sender: Any) {
        disconnect()
    }
    
    @IBAction func returnandle(_ sender: UITextField) {
        client!.sendUDP("RET")
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        var msg = ""
        if(sender.text! == "")
        {
            msg += "BACK"
        }
        else
        {
            msg += "KEY: " + (sender.text?.last.map(String.init))!
        }
        sender.text = " "
        client!.sendUDP(msg)
    }
    
    func disconnect()
    {
        DispatchQueue.main.async {
            self.client = nil
            self.dismiss(animated: true, completion: nil)
        }
    }
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x/rhs, y: lhs.y/rhs)
}

extension CGPoint {
    func norm() -> CGPoint
    {
        let denom = (x*x + y*y).squareRoot()
        return CGPoint(x: self.x/denom,y:self.y/denom)
    }
    
    func magSqrd() -> Float
    {
        return Float(self.x*self.x + self.y*self.y)
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
