//
//  StreanAnalyses.swift
//  CoreMLSound
//
//  Created by Gabriel Sabaini on 26/04/25.
//

import CoreML
import AVFoundation
import SoundAnalysis

/// Stream Analyses consegue fazer análises em tempo real de aúdio com um model de CreateML
///
/// Essa classe começa uma stream de aúdio que é analisada pelo model de CreateML, a variável results traz o resultado da análise.
/// A Classe é Observable para atualizar as outras telas quando mudar minha variável
class StreamAnalyses: ObservableObject {
    var audioEngine: AVAudioEngine?
    var inputBus: AVAudioNodeBus?
    var inputFormat: AVAudioFormat?
    var streamAnalyzer: SNAudioStreamAnalyzer?
    var resultsObserver: ResultsObserver = ResultsObserver()
    @Published var results: String = ""
    
    init(audioEngine: AVAudioEngine? = nil, inputBus: AVAudioNodeBus? = nil, inputFormat: AVAudioFormat? = nil, streamAnalyzer: SNAudioStreamAnalyzer? = nil) {
        self.audioEngine = audioEngine
        self.inputBus = inputBus
        self.inputFormat = inputFormat
        self.streamAnalyzer = streamAnalyzer
    }
    
    /// Função que começa a recolher o aúdio em volta
    func startAudioEngine() {
        audioEngine = AVAudioEngine()
        inputBus = AVAudioNodeBus(1)
        inputFormat = audioEngine!.inputNode.inputFormat(forBus: inputBus!)
        
        do {
            try audioEngine!.start()
        } catch {
            print("unable to run an AudioEngine")
        }
    }
    
    /// Função que análisa o áudio que está sendo recolhido de acordo com o Modelo escolhido. Nessa função tem como trocar as características do input do áudio.
    func createStreamAnalyzer() {
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat!)
        let config = MLModelConfiguration()
        
        do {
            let classifySoundRequest = try SNClassifySoundRequest(mlModel: do_Over_1(configuration: config).model)
            try streamAnalyzer?.add(classifySoundRequest, withObserver: resultsObserver)
        } catch {
            
        }
        
        audioEngine!.inputNode.installTap(onBus: inputBus!,
                                          bufferSize: 8192,
                                          format: inputFormat,
                                          block: analyzeAudio(buffer:at:))
    }
    
    let analysisQueue = DispatchQueue(label: "com.example.AnalysisQueue")
    
    /// Função que é chamada para fazer a análise do áudio, essa função é chamada pela createStreamAnalyzer.
    ///
    ///- Parameters:
    /// - buffer: o buffer vindo do AVFoundation
    /// - quantity: tempo em que o áudio está acontecendo
    func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer!.analyze(buffer,
                                         atAudioFramePosition: time.sampleTime)
        }
        results = resultsObserver.resultado
    }
    
    /// Função que para a engine e para de capturar o áudio em volta
    func stopAudioEngine() {
        audioEngine!.stop()
    }
}

/// An observer that receives results from a classify sound request.
///
/// Traz de volta os resultados colocados no model
class ResultsObserver: NSObject, SNResultsObserving {
    
    //
    var resultado: String = ""
    
    /// Notifies the observer when a request generates a prediction.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Downcast the result to a classification result.
        guard let result = result as? SNClassificationResult else  { return }
        
        
        // Get the prediction with the highest confidence.
        guard let classification = result.classifications.first else { return }
        
        
        // Get the starting time.
        let timeInSeconds = result.timeRange.start.seconds
        
        
        // Convert the time to a human-readable string.
        let formattedTime = String(format: "%.2f", timeInSeconds)
        print("Analysis result for audio at time: \(formattedTime)")
        
        
        // Convert the confidence to a percentage string.
        let percent = classification.confidence * 100.0
        let percentString = String(format: "%.2f%%", percent)
        
        //
        resultado = classification.identifier
        
        // Print the classification's name (label) with its confidence.
        print("\(classification.identifier): \(percentString) confidence.\n")
    }
    
    /// Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \(error.localizedDescription)")
    }
    
    
    /// Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
