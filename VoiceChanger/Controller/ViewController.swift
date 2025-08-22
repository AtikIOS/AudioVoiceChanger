//
//  ViewController.swift
//  VoiceChanger
//
//  Created by Atik Hasan on 8/22/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioUrl : URL?
    var audioFile: AVAudioFile?
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var selectedVoiceEffect: VoiceEffect = .Girl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadAudio()
    }
    
    @IBAction func btnVoiceEffectTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            selectedVoiceEffect = .Girl
        case 1:
            selectedVoiceEffect = .Baby
        case 2:
            selectedVoiceEffect = .Woman
        case 3:
            selectedVoiceEffect = .Boy
        case 4:
            selectedVoiceEffect = .Man
        case 5:
            selectedVoiceEffect = .OldMan
        case 6:
            selectedVoiceEffect = .Nervous
        case 7:
            selectedVoiceEffect = .Dizzy
        case 8:
            selectedVoiceEffect = .Drunk
        case 9:
            selectedVoiceEffect = .Robot
        case 10:
            selectedVoiceEffect = .Robot2
        case 11:
            selectedVoiceEffect = .Echo
        case 12:
            selectedVoiceEffect = .Alien
        case 13:
            selectedVoiceEffect = .Music
        case 14:
            selectedVoiceEffect = .Sheep
        default:
            break
        }
        self.applyVoiceEffect(self.selectedVoiceEffect)
    }
    
    func setupUI(){
        guard let url = Bundle.main.url(forResource: "SB", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        self.audioUrl = url
    }
    
    func loadAudio() {
        guard let url = audioUrl else { return }
        do {
            self.audioFile = try AVAudioFile(forReading: url)
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    func presetForEffect(_ effect: VoiceEffect) -> VoicePreset {
        switch effect {
        case .Girl: return VoicePreset(pitch: 400, rate: 1.1, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Baby: return VoicePreset(pitch: 800, rate: 1.2, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Woman: return VoicePreset(pitch: 300, rate: 1.0, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Boy: return VoicePreset(pitch: 200, rate: 1.0, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Man: return VoicePreset(pitch: -200, rate: 1.0, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .OldMan: return VoicePreset(pitch: -300, rate: 0.9, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Nervous: return VoicePreset(pitch: 400, rate: 1.5, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Dizzy: return VoicePreset(pitch: 200, rate: 0.7, reverb: (.cathedral, 60), delay: (0.3, 50, 40), distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Drunk: return VoicePreset(pitch: -100, rate: 0.8, reverb: (.largeRoom, 40), delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Robot: return VoicePreset(pitch: nil, rate: 1.0, reverb: nil, delay: nil, distortionPreset: .speechCosmicInterference, eqHighPass: nil, eqLowPass: nil)
        case .Robot2: return VoicePreset(pitch: nil, rate: 1.0, reverb: nil, delay: nil, distortionPreset: .speechRadioTower, eqHighPass: nil, eqLowPass: nil)
        case .Echo: return VoicePreset(pitch: nil, rate: 1.0, reverb: nil, delay: (0.4, 40, 50), distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        case .Alien: return VoicePreset(pitch: -600, rate: 0.9, reverb: (.plate, 50), delay: nil, distortionPreset: .multiEcho2, eqHighPass: nil, eqLowPass: nil)
        case .Music: return VoicePreset(pitch: nil, rate: 1.0, reverb: (.mediumHall, 50), delay: nil, distortionPreset: nil, eqHighPass: 200, eqLowPass: 8000)
        case .Sheep: return VoicePreset(pitch: 700, rate: 1.3, reverb: nil, delay: nil, distortionPreset: nil, eqHighPass: nil, eqLowPass: nil)
        }
    }
    
    /// Apply effect and play
    func applyVoiceEffect(_ effect: VoiceEffect) {
        guard let audioFile = self.audioFile else { return }
        
        // reset engine
        engine.stop()
        engine.reset()
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        engine.attach(player)
        
        let preset = presetForEffect(effect)
        var lastNode: AVAudioNode = player
        
        // Pitch & rate
        if preset.pitch != nil || preset.rate != nil {
            let pitchNode = AVAudioUnitTimePitch()
            if let p = preset.pitch { pitchNode.pitch = p }
            if let r = preset.rate { pitchNode.rate = r }
            engine.attach(pitchNode)
            engine.connect(lastNode, to: pitchNode, format: audioFile.processingFormat)
            lastNode = pitchNode
        }
        
        // Reverb
        if let reverbSet = preset.reverb {
            let reverbNode = AVAudioUnitReverb()
            reverbNode.loadFactoryPreset(reverbSet.preset)
            reverbNode.wetDryMix = reverbSet.mix
            engine.attach(reverbNode)
            engine.connect(lastNode, to: reverbNode, format: audioFile.processingFormat)
            lastNode = reverbNode
        }
        
        // Delay
        if let delaySet = preset.delay {
            let delayNode = AVAudioUnitDelay()
            delayNode.delayTime = delaySet.time
            delayNode.feedback = delaySet.feedback
            delayNode.wetDryMix = delaySet.mix
            engine.attach(delayNode)
            engine.connect(lastNode, to: delayNode, format: audioFile.processingFormat)
            lastNode = delayNode
        }
        
        // Distortion
        if let distPreset = preset.distortionPreset {
            let distortionNode = AVAudioUnitDistortion()
            distortionNode.loadFactoryPreset(distPreset)
            distortionNode.wetDryMix = 50
            engine.attach(distortionNode)
            engine.connect(lastNode, to: distortionNode, format: audioFile.processingFormat)
            lastNode = distortionNode
        }
        
        // EQ
        if preset.eqHighPass != nil || preset.eqLowPass != nil {
            let eqNode = AVAudioUnitEQ(numberOfBands: 2)
            if let hp = preset.eqHighPass {
                let band = eqNode.bands[0]
                band.filterType = .highPass
                band.frequency = hp
                band.bypass = false
            }
            if let lp = preset.eqLowPass {
                let band = eqNode.bands[1]
                band.filterType = .lowPass
                band.frequency = lp
                band.bypass = false
            }
            engine.attach(eqNode)
            engine.connect(lastNode, to: eqNode, format: audioFile.processingFormat)
            lastNode = eqNode
        }
        
        // Final connect to output
        engine.connect(lastNode, to: engine.mainMixerNode, format: audioFile.processingFormat)
        
        do {
            try engine.start()
            player.scheduleFile(audioFile, at: nil)
            player.play()
        } catch {
            print("Error starting engine: \(error)")
        }
    }
}

