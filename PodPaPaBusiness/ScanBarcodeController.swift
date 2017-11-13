//
//  ScanViewController.swift
//  ZZYQRCodeSwift
//
//  Created by 张泽宇 on 2017/5/24.
//  Copyright © 2017年 zzy. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var sessionManager:AVCaptureSessionManager?
    var link: CADisplayLink?
    var torchState = false
    
    
    
    
    @IBOutlet weak var customerID: UILabel!
    
    @IBOutlet weak var spendAmounts: UITextField!{
        didSet {
            spendAmounts?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        }
    }
    
    @objc func doneButtonTappedForMyNumericTextField() {
        print("Done");
        spendAmounts.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        link = CADisplayLink(target: self, selector: #selector(scan))
        spendAmounts.keyboardType = UIKeyboardType.decimalPad
        
        sessionManager = AVCaptureSessionManager(captureType: .AVCaptureTypeBoth, scanRect: CGRect.null, success: { (type, result) in
            if let r = result, let t = type {
                //                self .showResult(result: t+":"+r)
                self.customerID.text = r
                self.spendAmounts.becomeFirstResponder()
            }
        })
//        sessionManager?.showPreViewLayerIn(view: preview)
        sessionManager?.isPlaySound = true
        
//        let item = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(openPhotoLib))
//        navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillAppear(_ animated: Bool) {
        link?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        sessionManager?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        link?.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
        sessionManager?.stop()
    }
    
    @objc func scan() {
//        scanTop.constant -= 1;
//        if (scanTop.constant <= -170) {
//            scanTop.constant = 170;
//        }
    }
    
    @IBAction func changeState(_ sender: UIButton) {
        torchState = !torchState
        let str = torchState ? "关闭闪光灯" : "开启闪光灯"
        sessionManager?.turnTorch(state: torchState)
        sender.setTitle(str, for: .normal)
    }
    
    
    func showResult(result: String) {
        let alert = UIAlertView(title: "扫描结果", message: result, delegate: nil, cancelButtonTitle: "确定")
        alert .show()
    }
    
    @objc func openPhotoLib() {
        AVCaptureSessionManager.checkAuthorizationStatusForPhotoLibrary(grant: { 
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }) { 
            let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
            })
            let con = UIAlertController(title: "权限未开启",
                                        message: "您未开启相册权限，点击确定跳转至系统设置开启",
                                        preferredStyle: UIAlertControllerStyle.alert)
            con.addAction(action)
            self.present(con, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        sessionManager?.start()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) { 
            self.sessionManager?.start()
            self.sessionManager?.scanPhoto(image: info["UIImagePickerControllerOriginalImage"] as! UIImage, success: { (str, str1) in
                if let result = str {
                    self.showResult(result: result)
                }else {
                    self.showResult(result: "未识别到二维码")
                }
            })
            
        }
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Aceptar", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.spendAmounts.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction()
    {
        self.spendAmounts.resignFirstResponder()
    }
}
