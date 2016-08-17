//
//  FrontCameraController.swift
//  uCam
//
//  Created by Alex Kazorian on 6/14/16.
//  Copyright © 2016 Alex Kazorian. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import Material

class FrontCameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var captureSession : AVCaptureSession?
        var stillImageOutput : AVCaptureStillImageOutput?
        var previewLayer : AVCaptureVideoPreviewLayer?
        var image : UIImage?
        @IBOutlet var capturedImage: UIImageView!
        var cameraButton = UIButton(type: UIButtonType.Custom)
        var exitCaptureImageButton : FabButton = FabButton(frame: CGRectMake(12, 12, 48, 48))
        var saveButton : FabButton = FabButton()
        
        
        @IBOutlet var cameraView: UIView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.capturedImage.hidden = true
            
            self.cameraButton.clipsToBounds = true
            self.cameraButton.layer.cornerRadius = 72/2.0
            self.cameraButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.cameraButton.layer.borderWidth = 4.0
            self.cameraButton.addTarget(self, action: #selector(CameraController.cameraButton(_:)) , forControlEvents: .TouchUpInside)
            self.cameraButton.adjustsImageWhenHighlighted = false
            
            self.view.addSubview(self.cameraButton)
            
            self.cameraButton.snp_makeConstraints{ (make) -> Void in
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
        
        var frontCamera : AVCaptureDevice!
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = AVCaptureSessionPresetInputPriority
            
            var error : NSError?
            
            do {
                var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
                
                for device in videoDevices {
                    let device = device as! AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.Front {
                        self.frontCamera = device
                        break
                    }
                }
                
                let input = try AVCaptureDeviceInput(device: frontCamera)
                
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
        
        
        func didPressTakePhoto() {
            
            if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                    (sampleBuffer, error) in
                    
                    if sampleBuffer != nil {
                        
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let dataProvider  = CGDataProviderCreateWithCFData(imageData)
                        let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault)
                        self.image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
                        self.capturedImage.image = self.image
                        self.capturedImage.hidden = false
                        self.presentCaptureView()
                    }
                })
            }
        }
        
        func presentCaptureView() {
            prepareCloseButton()
            prepareCameraButtonImage()
            prepareSaveButton()
        }
        
        
        private func prepareCloseButton() {
            let img: UIImage? = MaterialIcon.cm.close
            exitCaptureImageButton.setImage(img, forState: .Normal)
            exitCaptureImageButton.setImage(img, forState: .Highlighted)
            exitCaptureImageButton.tintColor = MaterialColor.lightBlue.darken2
            exitCaptureImageButton.backgroundColor = MaterialColor.white.colorWithAlphaComponent(0.5)
            exitCaptureImageButton.borderWidth = 1
            exitCaptureImageButton.borderColor = MaterialColor.lightBlue.darken2
            exitCaptureImageButton.hidden = false
            exitCaptureImageButton.addTarget(self, action: #selector(CameraController.didPressCloseButton(_:)), forControlEvents: .TouchUpInside)
            
            self.view.addSubview(exitCaptureImageButton)
        }
        
        private func prepareCameraButtonImage() {
            self.cameraButton.setBackgroundImage(self.image, forState: .Normal)
        }
        
        private func prepareSaveButton() {
            let img: UIImage? = MaterialIcon.cm.check
            saveButton.setImage(img, forState: .Normal)
            saveButton.setImage(img, forState: .Highlighted)
            saveButton.tintColor = MaterialColor.lightBlue.darken2
            saveButton.backgroundColor = MaterialColor.white.colorWithAlphaComponent(0.5)
            saveButton.borderWidth = 1
            saveButton.borderColor = MaterialColor.lightBlue.darken2
            saveButton.hidden = false
            saveButton.addTarget(self, action: #selector(CameraController.didPressSaveButton(_:)), forControlEvents: .TouchUpInside)
            self.view.addSubview(saveButton)
            
            saveButton.snp_makeConstraints{ (make) -> Void in
                make.height.equalTo(48)
                make.width.equalTo(48)
                
                make.bottom.equalTo(self.view.snp_bottom).offset(-36)
                make.right.equalTo(self.view.snp_right).offset(-20)
            }
        }
        
        func didPressCloseButton(sender: IconButton!) {
            capturedImage.hidden = true
            saveButton.hidden = true
            exitCaptureImageButton.hidden = true
            self.cameraButton.setBackgroundImage(nil, forState: .Normal)
        }
        
        func didPressSaveButton(sender: IconButton!) {
            UIImageWriteToSavedPhotosAlbum(self.image!, nil, nil, nil)
            capturedImage.hidden = true
            saveButton.hidden = true
            exitCaptureImageButton.hidden = true
            self.cameraButton.setBackgroundImage(nil, forState: .Normal)
        }
        
        func cameraButton(sender: UIButton!) {
            
            if self.capturedImage.hidden != false {
                captureSession?.startRunning()
                didPressTakePhoto()
            }
            
        }
    
    @IBAction func didPanEdgeLeft(sender: AnyObject) {
        self.performSegueWithIdentifier("toBackCamera", sender: self)
    }
}
