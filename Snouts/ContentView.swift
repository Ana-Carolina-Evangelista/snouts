//
//  ContentView.swift
//  CoreMLSound
//
//  Created by Gabriel Sabaini on 25/04/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    //instancia da Classe de Stream e variáveis auxiliares da view
    @ObservedObject var streamAnalyzes: StreamAnalyses = StreamAnalyses()
    
    @State var resultado: String = ""
    @State var numImage: Int = 0
    
    //Variaveis booleanas
    @State var usando: Bool = false
    @State var fadeInOut: Bool = false
    
    //Listas de imagens de cachorros e gatos
    @State var dogList: [String] = ["dog1","dog2","dog3","dog4","dog5","dog6","dog7","dog8","dog9","dog10","dog11"]
    @State var catList: [Image] = [Image("cat1"),Image("cat2"),Image("cat3"),Image("cat4"),Image("cat5"),Image("cat6"),Image("cat7"),Image("cat8"),Image("cat9"),Image("cat10")]
    
    var body: some View {
        
        
        VStack {
            
            Text(resultado)
            
            Spacer()
            
            //if que exibe a imagem do fado do animal, com efeito de fadeIn
            if resultado == "Dogs_train" {
                Image(dogList[numImage])
                    .resizable()
                    .frame(width:250, height: 250)
                    .onAppear() {
                        withAnimation(Animation.easeInOut(duration:1.5).repeatCount(1)){
                            fadeInOut.toggle()
                        }
                    }.opacity(fadeInOut ? 0 : 1)
                
            }
            
            else if resultado == "Cats_train"{
                catList[numImage]
                    .resizable()
                    .frame(width: 250, height:250)
                    .onAppear() {
                        withAnimation(Animation.easeInOut(duration:1.5).repeatCount(1)){
                            fadeInOut.toggle()
                        }
                    }.opacity(fadeInOut ? 0 : 1)
            }
            
            Spacer()
            
            //Botão que começa a usar o modelo
            Button {
                
                // Se já estiver usando ele para de usar
                if usando {
                    Task {
                        streamAnalyzes.stopAudioEngine()
                    }
                    usando = false
                    resultado = ""
                    
                } else {
                    
                    //inicia a Engine de áudio e começa a analisar o som
                    Task {
                        streamAnalyzes.startAudioEngine()
                        streamAnalyzes.createStreamAnalyzer()
                    }
                    usando = true
                    resultado = ""
                }
            } label: {
                
                //if para mudar o label do botão
                if usando {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.yellow)
                        Image(systemName: "pause.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    
                    .frame(width: 100, height: 100)
                    
                } else {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.yellow)
                        Image(systemName: "mic.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .frame(width: 100, height: 100)
                }
            }
            
            Text("Bark or Meow")
                .padding()
            
        }
        .onAppear {
            
            //pede permissão para usar o microfone quando abre a view
            AVFoundationViewModel.requestRecordPermission()
        }
        .onChange(of: streamAnalyzes.results) { newValue in
            
            //quando muda o resultado de análise ele tanbém muda o resultado da variável auxiliar
            resultado = streamAnalyzes.results
            
            //gerar numero aleatorio para ser usado como index da lista de imagens
            numImage = Int.random(in: 0...9)
            
            //toggle para que o efeito de fadeIn seja fixo e n altere para fadeOut
            fadeInOut.toggle()
        }
    }
}

#Preview {
    ContentView()
}

