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
        return AVAudioSession.sharedInstance().outputVolume
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
    private var eventSink: FlutterEventSink?
    private let volumeKey: String = "outputVolume"
    private var outputVolumeObservation: NSKeyValueObservation?


    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        registerVolumeObserver()
        eventSink?(AVAudioSession.sharedInstance().outputVolume)

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
        outputVolumeObservation = AVAudioSession.sharedInstance().observe(\.outputVolume) { audioSession, _ in
            self.eventSink?(audioSession.outputVolume);
        }
    }

    private func removeVolumeObserver() {
        outputVolumeObservation = nil
        try! AVAudioSession.sharedInstance().setActive(false)
    }
}
