//
//  Constants.swift
//  HelpCambio
//
//  Created by André Alves on 24/11/18.
//  Copyright © 2018 André Alves. All rights reserved.
//

import Foundation

public enum Constants{
  public static let kLanguage: String = "pt-BR"
  public static let kIsNotFirstTime: String = "IsNotFirstTime"
  public enum strings: String {
    case findNoteTitle = "Buscar cédula monetária"
    case verifyNoteTitle = "Verificar cédula monetária"
    case msgWelcome = "Bem vindo ao Help Câmbio, o aplicativo ideal para auxiliar deficientes visuais a identificarem cédulas monetárias."
    case msgTutorial = "Para começar, ensinaremos como utilizar o dispositivo através de um áudio-tutorial."
    case msgFirstStep = "Primeiro posicione o dispositivo para que a câmera consiga capturar a nota."
    case msgSecondStep = "Feito isso, toque na tela 3 vezes e o aplicativo te informará qual nota é."
    case msgFinish = "Toque na tela para iniciar."
    case msgWait = "Aguarde..."
    case msgError = "Ocorreu um erro inesperado. Tente novamente"
    case msgNote = "Provavelmente é uma nota de %@ reais."
    case msgNoneNote = "Provavelmente não é uma nota de real."
  }
  
  public enum notesKeys: String {
    case not_a_real_note = "nao_nota_de_real"
    case note_two = "nota_de_2"
    case note_five = "nota_de_5"
    case note_ten = "nota_de_10"
    case note_twenty = "nota_de_20"
    case note_fifty = "nota_de_50"
    case note_one_hundred = "nota_de_100"
  }
}

