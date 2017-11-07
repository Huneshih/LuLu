//
//  AudioManager.swift
//  Recording
//
//  Created by Hong Shih on 2017/10/28.
//  Copyright © 2017年 Hune. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    
    static let shared = AudioManager()
    
    private override init() {
        
    }
    
    
    var isPlaying = false
    
    var player = AVAudioPlayer()
    
    // 初始畫錄音器
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    override func awakeFromNib() {
        // 以下有可能會出錯，所以需要 try
        do {
            // 設定模式： AVAudioSessionCategoryPlayAndRecord  -->  播放與錄音
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
        } catch {
            // 發生錯誤時回報
            print("error")
        }
    }
    
    
    
    func play(fileName: String) {
        

        
        guard let url = URL.init(string: DataManager.sharedInstance().getFilePath(filename: fileName)!) else {
            return
        }
        
        if isPlaying == false {
            
            isPlaying = true
            
        } else {
            
            NotificationCenter.default.post(name: NSNotification.Name("otherCellPlay"), object: nil)
            
        }
        
        do {
            try player = AVAudioPlayer(contentsOf: url)
        } catch let err {
            print(err.localizedDescription)
        }
        
        player.delegate = self
        
        player.play()
    }
    
    
    func stopPlay() {
        isPlaying = false
        player.stop()
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        NotificationCenter.default.post(name: NSNotification.Name("playOver"), object: nil)
    }
}
