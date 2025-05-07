//
//  AVFoundationViewModel.swift
//  CoreMLSound
//
//  Created by Gabriel Sabaini on 25/04/25.
//

import AVFoundation

/// Classe que trata das funções do AVFoundation
class AVFoundationViewModel {
    
    /// Função que pede permissão ao dispositivo para usar o microfone
    ///
    /// A função é static para não precisar instanciar a classe para usar ela
    static func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                // Permission granted
                print("permision granted")
            } else {
                // Handle permission denied
            }
        }
    }
}
