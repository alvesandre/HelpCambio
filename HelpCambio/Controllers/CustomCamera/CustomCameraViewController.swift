//
//  CustomCameraViewController.swift
//  HelpCambio
//
//  Created by André Alves on 17/09/18.
//  Copyright © 2018 André Alves. All rights reserved.
//

import UIKit
import AVKit

class CustomCameraViewController: UIViewController {
  
  // MARK: IBOutlets
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
  
  // MARK: Private properties
  private var cameraController: CustomCameraController?
  private var speechSynthesizer: AVSpeechSynthesizer?
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureNavBar()
    self.configureCameraController()
    self.configureSpeechSynthesizer()
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
  }
  
  // MARK: Private methods
  
  private func configureNavBar() {
    self.title = Constants.strings.findNoteTitle.rawValue
    let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.5803921569, blue: 0.03137254902, alpha: 0.7024647887)
  }
  
  private func configureSpeechSynthesizer() {
    self.speechSynthesizer = AVSpeechSynthesizer()
    self.speechSynthesizer?.accessibilityLanguage = Constants.kLanguage
    self.speechSynthesizer?.delegate = self
  }
  
  private func configureCameraController() {
    self.cameraController = CustomCameraController()
    self.cameraController?.prepare {(error) in
      if let error = error {
        print(error)
        self.speechSynthesizer?.speak(AVSpeechUtterance(string: Constants.strings.msgError.rawValue))
      }
      try? self.cameraController?.displayPreview(on: self.cameraView)
    }
  }
  
  private func showLoading(show: Bool) {
    if show {
      self.view.isUserInteractionEnabled = false
      self.speechSynthesizer?.speak(AVSpeechUtterance(string: Constants.strings.msgWait.rawValue))
      self.tapGestureRecognizer.isEnabled = false
      self.activityIndicator.startAnimating()
    } else {
      self.activityIndicator.stopAnimating()
      self.tapGestureRecognizer.isEnabled = true
      self.view.isUserInteractionEnabled = true
    }
  }
  
  // MARK: IBActions
  
  @IBAction func didTappedOnView(_ sender: Any) {
    self.showLoading(show: true)
  }
  
  // MARK: Navigation
  
  private func navigate(image: UIImage?, viewController: VerifyMoneyNoteViewController)
  {
    viewController.previewImage = image
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: Extensions

extension CustomCameraViewController: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    if utterance.speechString == Constants.strings.msgWait.rawValue {
      self.cameraController?.captureImage(completion: { (image, error) in
        self.showLoading(show: false)
        if error == nil {
          self.navigate(image: image, viewController: VerifyMoneyNoteViewController())
        } else {
          self.speechSynthesizer?.speak(AVSpeechUtterance(string: Constants.strings.msgError.rawValue))
        }
      })
    }
  }
  
}



