//
//  VoicePreset.swift
//  VoiceChanger
//
//  Created by Atik Hasan on 8/22/25.
//

import UIKit
import AVFoundation

enum VoiceEffect {
    case Girl, Baby, Woman, Boy, Man, OldMan, Nervous, Dizzy, Drunk, Robot, Robot2, Echo, Alien, Music, Sheep
}

struct VoicePreset {
    var pitch: Float?
    var rate: Float?
    var reverb: (preset: AVAudioUnitReverbPreset, mix: Float)?
    var delay: (time: Double, feedback: Float, mix: Float)?
    var distortionPreset: AVAudioUnitDistortionPreset?
    var eqHighPass: Float?
    var eqLowPass: Float?
}
