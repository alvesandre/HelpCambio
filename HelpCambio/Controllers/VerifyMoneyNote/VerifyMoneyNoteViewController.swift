//
//  VerifyMoneyNoteViewController.swift
//  HelpCambio
//
//  Created by André Alves on 17/09/18.
//  Copyright © 2018 André Alves. All rights reserved.
//

import UIKit
import Vision
import AVKit

class VerifyMoneyNoteViewController: UIViewController {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var moneyNoteImageView: UIImageView!
  
  // MARK: Public properties
  
  var previewImage: UIImage?
  
  // MARK: Private properties
  
  private var notesClassifierModel: VNCoreMLModel?
  private var speechSynthesizer: AVSpeechSynthesizer?
  
  // MARK: Lifecycle
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.title = Constants.strings.verifyNoteTitle.rawValue
    self.configureModel()
    self.configureSpeechSynthesizer()
    self.configureImageView()
  }
  
  // MARK: Private methods
  
  @objc private func pressBack(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func configureImageView() {
    if let previewImage = self.previewImage {
      self.moneyNoteImageView.image = previewImage
      self.verifyNote()
    }
  }
  
  private func configureModel() {
    self.notesClassifierModel = try? VNCoreMLModel(for: NotesClassifierModel().model)
  }
  
  private func configureSpeechSynthesizer() {
    self.speechSynthesizer = AVSpeechSynthesizer()
    self.speechSynthesizer?.accessibilityLanguage = Constants.kLanguage
  }
  
  private func getNoteNumber(identifier: String) -> Int {
    switch identifier {
    case Constants.notesKeys.not_a_real_note.rawValue:
      return 0
    case Constants.notesKeys.note_two.rawValue:
      return 2
    case Constants.notesKeys.note_five.rawValue:
      return 5
    case Constants.notesKeys.note_ten.rawValue:
      return 10
    case Constants.notesKeys.note_twenty.rawValue:
      return 20
    case Constants.notesKeys.note_fifty.rawValue:
      return 50
    case Constants.notesKeys.note_one_hundred.rawValue:
      return 100
    default:
      return 0
    }
  }
  
  private func verifyNote() {
    if let notesClassifierModel = self.notesClassifierModel,
      let previewImage = self.previewImage, let ciImage = CIImage(image: previewImage) {
      let request = VNCoreMLRequest(model: notesClassifierModel) { (request, error) in
        guard let results = request.results as? [VNClassificationObservation],
          let topResult = results.first else {
          self.speechSynthesizer?.speak(AVSpeechUtterance(string: Constants.strings.msgError.rawValue))
          return
        }
        let noteNumber = self.getNoteNumber(identifier: topResult.identifier)
        print(results)
        if noteNumber > 0 {
          self.speechSynthesizer?.speak(AVSpeechUtterance(string: Constants.strings.msgNote.rawValue.replacingOccurrences(of: "%@", with: String(noteNumber))))
        } else {
          self.speechSynthesizer?.speak(AVSpeechUtterance(string: Constants.strings.msgNoneNote.rawValue))
        }
      }
      let handler = VNImageRequestHandler(ciImage: ciImage)
      try? handler.perform([request])
    }
  }
  
}

