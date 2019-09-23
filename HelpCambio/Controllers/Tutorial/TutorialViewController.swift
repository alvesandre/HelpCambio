//
//  TutorialViewController.swift
//  HelpCambio
//
//  Created by André Alves on 24/11/18.
//  Copyright © 2018 André Alves. All rights reserved.
//

import UIKit
import AVKit

class TutorialViewController: UIViewController {
  
  // MARK: IBOutlets
  
  @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
  
  // MARK: Private Properties
  
  private var speechSynthetizer: AVSpeechSynthesizer?
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.tapGestureRecognizer.isEnabled = false
    self.configureSpeechSynthetizer()
  }
  // MARK: IBActions
  
  @IBAction func didTapOnView(_ sender: Any) {
    UserDefaults.standard.set(true, forKey: Constants.kIsNotFirstTime)
    self.navigateToCustomCameraVC()
  }
  
  // MARK: Private Methods
  
  private func configureSpeechSynthetizer() {
    self.speechSynthetizer = AVSpeechSynthesizer()
    self.speechSynthetizer?.delegate = self
    self.speechSynthetizer?.accessibilityLanguage = Constants.kLanguage
    self.speechSynthetizer?.speak(AVSpeechUtterance(string: Constants.strings.msgWelcome.rawValue))
  }
  
  private func navigateToCustomCameraVC() {
    self.navigationController?.setViewControllers([CustomCameraViewController()], animated: true)
  }
  
}

// MARK: Extensions

extension TutorialViewController: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    var stringToSpeech: String?
    switch utterance.speechString {
    case Constants.strings.msgWelcome.rawValue:
      stringToSpeech = Constants.strings.msgTutorial.rawValue
    case Constants.strings.msgTutorial.rawValue:
      stringToSpeech = Constants.strings.msgFirstStep.rawValue
    case Constants.strings.msgFirstStep.rawValue:
      stringToSpeech = Constants.strings.msgSecondStep.rawValue
    case Constants.strings.msgSecondStep.rawValue:
      stringToSpeech = Constants.strings.msgFinish.rawValue
    default:
      break
    }
    if let stringToSpeech = stringToSpeech {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        synthesizer.speak(AVSpeechUtterance(string: stringToSpeech))
      }
    } else {
      self.tapGestureRecognizer.isEnabled = true
    }
  }
}
