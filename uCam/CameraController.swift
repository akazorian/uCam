//
//  ViewController.swift
//  uCam
//
//  Created by Alex Kazorian on 6/7/16.
//  Copyright © 2016 Alex Kazorian. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var image : UIImage?
    
    
    @IBOutlet var cameraView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: UIButtonType.Custom)
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 72/2.0
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.45)
        button.layer.borderWidth = 4.0
        button.addTarget(self, action: #selector(CameraController.cameraButton(_:)) , forControlEvents: .TouchDown)
        
        self.view.addSubview(button)
        
        button.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(72)
            make.height.equalTo(72)
        
            make.bottom.equalTo(self.view.snp_bottom).offset(-20)
            make.centerX.equalTo(self.view.snp_centerX)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if (error == nil && captureSession?.canAddInput(input) != nil) {
                captureSession?.addInput(input)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                
                if (captureSession?.canAddOutput(stillImageOutput) != nil) {
                    captureSession?.addOutput(stillImageOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    captureSession?.startRunning()
                }
            }
            
        } catch { }
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func didPressTakePhoto() {
        
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider  = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentPerceptual)
                    
                    self.image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                }
                
                
            })
        }
        
        
    }

    func cameraButton(sender: UIButton!) {
        captureSession?.startRunning()
        didPressTakePhoto()
    }
}

