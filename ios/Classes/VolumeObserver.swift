//
//  VolumeObserver.swift
//  volume_controller
//
//  Created by Kurenai on 30/01/2021.
//

import Foundation
import AVFoundation
import MediaPlayer
import Flutter
import UIKit


public class VolumeObserver {
    public func getVolume() -> Float? {
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            return audioSession.outputVolume
        } catch let _ {
            return nil
        }
    }

    public func setVolume(volume:Float, showSystemUI: Bool) {
        let volumeView = MPVolumeView()
        if(!showSystemUI){
            volumeView.frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
            volumeView.showsVolumeSlider = false
            UIApplication.shared.delegate!.window!?.rootViewController!.view.addSubview(volumeView)
        }

        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
            volumeView.removeFromSuperview()
        }
    }
}

public class VolumeListener: NSObject, FlutterStreamHandler {
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var eventSink: FlutterEventSink?
    private let volumeKey: String = "outputVolume"
    private var outputVolumeObservation: NSKeyValueObservation?


    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        registerVolumeObserver()
        eventSink?(audioSession.outputVolume)

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        removeVolumeObserver()

        return nil
    }

    private func registerVolumeObserver() {
        audioSessionObserver()
    }

    @objc func audioSessionObserver(){
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch {
            print("Fail to set category: \(error)")
        }
        
        do {
            
            try audioSession.setActive(true)
            outputVolumeObservation = audioSession.observe(\.outputVolume) { audioSession, _ in
                self.eventSink?(audioSession.outputVolume);
            }
        } catch {
            print("Volume Controller Listener occurred error: \(error)")
        }
    }

    private func removeVolumeObserver() {
        outputVolumeObservation = nil
    }
}
