//
//  CustomCameraController.swift
//  HelpCambio
//
//  Created by André Alves on 17/09/18.
//  Copyright © 2018 André Alves. All rights reserved.
//

import AVFoundation
import UIKit

class CustomCameraController: NSObject {

  var captureSession: AVCaptureSession?
  var frontCamera: AVCaptureDevice?
  var rearCamera: AVCaptureDevice?
  
  var currentCameraPosition: CameraPosition?
  var frontCameraInput: AVCaptureDeviceInput?
  var rearCameraInput: AVCaptureDeviceInput?
  
  var photoOutput: AVCapturePhotoOutput?
  var movieOutput: AVCaptureMovieFileOutput?
  
  var previewLayer: AVCaptureVideoPreviewLayer?
  
  
  var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
  
  var movieCaptureCompletionBlock: ((URL?, UIImage?, Error?) -> Void)?
  
  enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
  }
  
  public enum CameraPosition {
    case front
    case rear
  }
  
  private var capturedFrame: UIImage?
  
  func displayPreview(on view: UIView) throws {
    guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
    
    self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    self.previewLayer?.connection?.videoOrientation = .portrait
    
    view.layer.insertSublayer(self.previewLayer!, at: 0)
    self.previewLayer?.frame = view.frame
  }
  
  private func videoFileLocation() -> URL? {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileURL =  documentsPath?.appendingPathComponent("onboarding.mov")
    if let fileURL = fileURL {
      try? FileManager.default.removeItem(at: fileURL)
    }
    return fileURL
  }
  
  func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
    guard let captureSession = self.captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
    
    let settings = AVCapturePhotoSettings()
    
    self.photoOutput?.capturePhoto(with: settings, delegate: self)
    self.photoCaptureCompletionBlock = completion
  }
  
  
  func captureVideo(completion: @escaping (URL?, UIImage?, Error?) -> Void) {
    guard let captureSession = self.captureSession, captureSession.isRunning else {
      completion(nil, nil, CameraControllerError.captureSessionIsMissing)
      return }
    if let fileURL = self.videoFileLocation() {
      self.movieOutput?.startRecording(to: fileURL, recordingDelegate: self)
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
        self.captureFrame()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        self.stopRecording()
      }
      self.movieCaptureCompletionBlock = completion
    }
  }
  
  @objc func stopRecording() {
    self.movieOutput?.stopRecording()
  }
  
  @objc func captureFrame() {
    self.captureImage { (image, error) in
      if error == nil {
        print("success")
        self.capturedFrame = image
      }
    }
  }
  
  func prepare(completionHandler: @escaping (Error?) -> Void) {
    
    func createCaptureSession() {
      self.captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
      let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
      let cameras = session.devices
      if cameras.isEmpty {
        throw CameraControllerError.noCamerasAvailable
      }
      
      for camera in cameras {
        if camera.position == .front {
          self.frontCamera = camera
        }
        
        if camera.position == .back {
          self.rearCamera = camera
          
          try camera.lockForConfiguration()
          camera.focusMode = .continuousAutoFocus
          camera.unlockForConfiguration()
        }
      }
    }
    
    func configureDeviceInputs() throws {
      guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
      
      if let rearCamera = self.rearCamera {
        self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
       
        if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
       
        self.currentCameraPosition = .rear
      }
       
      else  if let frontCamera = self.frontCamera {
        self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
        if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
        else { throw CameraControllerError.inputsAreInvalid }
        
        self.currentCameraPosition = .front
      }
        
      else { throw CameraControllerError.noCamerasAvailable }
    }
    
    func configurePhotoOutput() throws {
      guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
      
      self.photoOutput = AVCapturePhotoOutput()
      self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
      
      if captureSession.canAddOutput(self.photoOutput ?? AVCapturePhotoOutput()) {
        captureSession.addOutput(self.photoOutput ?? AVCapturePhotoOutput())
      }
      
      captureSession.startRunning()
    }
    
    func configureMovieOutput() throws {
      
      guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
      self.movieOutput = AVCaptureMovieFileOutput()
      if captureSession.canAddOutput(self.movieOutput ?? AVCaptureMovieFileOutput()) {
        captureSession.addOutput(self.movieOutput ?? AVCaptureMovieFileOutput())
      }
      
      captureSession.startRunning()
    }
    
    DispatchQueue(label: "prepare").async {
      do {
        createCaptureSession()
        try configureCaptureDevices()
        try configureDeviceInputs()
        try configurePhotoOutput()
        try configureMovieOutput()
      }
        
      catch {
        DispatchQueue.main.async {
          completionHandler(error)
        }
        
        return
      }
      
      DispatchQueue.main.async {
        completionHandler(nil)
      }
    }
  }
}

extension CustomCameraController: AVCapturePhotoCaptureDelegate {
  
  
  public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                      resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
    if let error = error {
      self.photoCaptureCompletionBlock?(nil, error)
    } else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
      let image = UIImage(data: data) {
      
      self.photoCaptureCompletionBlock?(image, nil)
    } else {
      self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
    }
  }
}

extension CustomCameraController: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    if error == nil {
      UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
      self.movieCaptureCompletionBlock?(outputFileURL, capturedFrame, nil)
    } else {
      self.movieCaptureCompletionBlock?(nil, nil, CameraControllerError.unknown)
    }
  }
}
