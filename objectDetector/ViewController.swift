//
//  ViewController.swift
//  objectDetector
//
//  Created by Vishaal Bommena on 12/22/17.
//  Copyright © 2017 Vishaal Bommena. All rights reserved.
//

import UIKit
import AVKit
import Vision
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let captureSession =  AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return  }
        guard let input = try? AVCaptureDeviceInput(device:  captureDevice) else {return }
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewLayer =  AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Camera was able to capture a frame" )
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer ) else {return  }
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err ) in
            if((err) != nil){
                print("Error: ", err as Any)
            }
            print(finishedReq.results as Any)
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return  }
            guard let firstObservation = results.first else {return  }
            
            print(firstObservation.identifier, firstObservation.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

