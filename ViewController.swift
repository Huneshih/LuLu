//
//  ViewController.swift
//  Recording
//
//  Created by Hong Shih on 2017/8/12.
//  Copyright © 2017年 Hune. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var startRecordOL: UIButton!
    @IBOutlet weak var playOL: UIButton!
    @IBOutlet weak var saveOL: UIButton!
    @IBOutlet weak var delOL: UIButton!
    
    
    
    // 設置一個錄音器
    var recorder: AVAudioRecorder?
    // 設置一個播放器
    var player: AVAudioPlayer?
    // 錄音器參數
    // NSNumber(value:)
    let recordSetting: [String: Any] = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // 儲存格式
                                         AVNumberOfChannelsKey: 2, // 單聲道或雙聲道
                                         AVSampleRateKey: 44100.0, // 採樣率
                                         AVLinearPCMBitDepthKey: 16, // 位元數
                                         AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // 品質
                                        ]

    // 錄音計時器，循環監測音量大小
    var volumeTimer:Timer!
    // 音檔儲存路徑
    var aacPath: String?
    
    // 最大音量
    var volumeMax: Float?
    
    
    
    var dateNumber = DateFormatter()
    
    // 設定儲存檔案
    var filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    
    // 存取當前檔案用
    var currentFile: String?
    
    
    
    // 播放後產生的暫停鍵
    let pausePlayBTN = UIButton()
    
    // 錄音後產生的暫停鍵
    let pauseRecordBTN = UIButton()
    
    // 以播放的時間，用於暫停後再播放
    var pauseTimeByPlay: TimeInterval?
    
    // 判斷是否正在錄音
    var isRecording = false
    
    // 判斷是否為暫停錄音
    var isPauseRecord = false
    
    // 判斷是否正在播放
    var isPlaying = false
    
    
    let bg = UIView()
    
    // 初始畫錄音器
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
//        print(FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!)
        
        // Do any additional setup after loading the view.
        
        
        // 以下有可能會出錯，所以需要 try
        do {
            // 設定模式： AVAudioSessionCategoryPlayAndRecord  -->  播放與錄音
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
        } catch {
            // 發生錯誤時回報
            print("error")
        }
        
        
        dateNumber.dateFormat = "YYYYMMddhhmmss"
        
        
        // 將按鍵轉為圓形
        round(UIBtn: startRecordOL)
        setBtnImage(UIbtn: startRecordOL, imageName: "mic")
        
        round(UIBtn: playOL)
        setBtnImage(UIbtn: playOL, imageName: "playArrow")
        
        round(UIBtn: saveOL)
        setBtnImage(UIbtn: saveOL, imageName: "save")
        
        round(UIBtn: delOL)
        setBtnImage(UIbtn: delOL, imageName: "del")
        
        
        setBtnImage(UIbtn: pausePlayBTN, imageName: "pause")
        setBtnImage(UIbtn: pauseRecordBTN, imageName: "pause")
        
        
        pausePlayBTN.addTarget(self, action: #selector(pausePlay), for: .touchUpInside)
        pauseRecordBTN.addTarget(self, action: #selector(pauseRecord), for: .touchUpInside)
        
        
        
        
        saveOL.frame = CGRect(x: view.frame.midX - 37.5, y: view.frame.midY - 37.5, width: 75, height: 75)
        delOL.frame = CGRect(x: view.frame.midX - 37.5, y: view.frame.midY - 37.5, width: 75, height: 75)
        playOL.frame = CGRect(x: view.frame.midX - 37.5, y: view.frame.midY - 37.5, width: 75, height: 75)
        view.bringSubview(toFront: startRecordOL)
    }
    
    
    
    
    // 將按鍵轉為圓形
    func round(UIBtn: UIButton) {
        UIBtn.layer.cornerRadius = UIBtn.frame.width / 2
        UIBtn.clipsToBounds = true
    }
    
    // 設定按鈕 icon
    func setBtnImage(UIbtn: UIButton, imageName: String) {
        UIbtn.setImage(UIImage(named: "\(imageName).png"), for: .normal)
    }
    

    
    
    // 開始錄音按鍵
    @IBAction func startRecordBtn(_ sender: Any) {
        
        
        if isRecording == false {

            setBtnImage(UIbtn: startRecordOL, imageName: "stop")
            
            if isPauseRecord == false {
                do {
                    // 設定路徑
                    let date = Date()
                    currentFile = filePath! + "/record\(dateNumber.string(from: date)).m4a"
                    let url = URL(fileURLWithPath: currentFile! )
                    
                    // 將錄音器初始話設定，帶進儲存路徑與錄音格式設定
                    recorder = try AVAudioRecorder(url: url, settings: recordSetting)
                    
                    // 啟動錄音器
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                // 判斷是否已初始話錄音器
                if recorder != nil {
                    // 開啟音訊偵測
                    recorder?.isMeteringEnabled = true
                    // 準備錄音器
                    recorder?.prepareToRecord()
                    // 開始錄製
                    recorder?.record()
                    
                    isRecording = true
                    
                    // 使用計時器，不斷執行音波動畫
                    volumeTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(soundWave), userInfo: nil, repeats: true);
                    
                }
                
                
                
                
                pauseRecordBTN.frame = CGRect(x: startRecordOL.frame.midX - 25, y: startRecordOL.frame.midY - 25, width: 50, height: 50)
                pauseRecordBTN.backgroundColor = UIColor(red: 208 / 255, green: 201 / 255, blue: 229 / 255, alpha: 1.0)
                
                
                round(UIBtn: pauseRecordBTN)
                
                view.insertSubview(pauseRecordBTN, belowSubview: startRecordOL)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    
                    self.pauseRecordBTN.frame = CGRect(x: self.view.frame.midX + 45, y: self.view.frame.midY + 32, width: 50, height: 50)
                    
                    self.delOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY + 68.5, width: 75, height: 75)
                    
                    self.playOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
                    
                }) { (_) in
                    return
                }

            } else {
                
                isRecording = true
                isPauseRecord = false
                recorder?.record()
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    
                    self.saveOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
                    
                }, completion: { (_) in
                    return
                })
                
            }
            
            
        } else {
            
            isRecording = false
            isPauseRecord = false
            
            // 停止錄音
            volumeTimer.invalidate()
            recorder?.stop()
            recorder = nil
            volumeTimer = nil
            
            setBtnImage(UIbtn: startRecordOL, imageName: "mic")
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { 
                
                self.pauseRecordBTN.frame = CGRect(x: self.startRecordOL.frame.midX - 25, y: self.startRecordOL.frame.midY - 25, width: 50, height: 50)
                
                self.saveOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
                
                self.playOL.frame = CGRect(x: self.view.frame.midX - 127, y: self.view.frame.midY - 109, width: 75, height: 75)
                
            }, completion: { (_) in
                self.pauseRecordBTN.removeFromSuperview()
            })
            
            
            
            
        }
        
        
    }
    
    
    
    
    // 播放按鍵
    @IBAction func playBtn(_ sender: Any) {
        
        
        if isPlaying == true {
            
           stopPlay()
            
        } else {
            
            isPlaying = true
            
            if pauseTimeByPlay == nil {
                
                do {
                    let url = URL(fileURLWithPath: currentFile!)
                    try player = AVAudioPlayer(contentsOf: url)
                } catch let err {
                    print(err.localizedDescription)
                }
                
                guard player != nil else {
                    print("player error")
                    return
                }
                player?.delegate = self
                player?.play()
                
                // 按下播放鍵後，生成一個暫停的按鍵
                pausePlayBTN.frame = CGRect(x: playOL.frame.midX - 25, y: playOL.frame.midY - 25, width: 50, height: 50)
                pausePlayBTN.backgroundColor = UIColor(red: 208 / 255, green: 201 / 255, blue: 229 / 255, alpha: 1.0)
                
                
                round(UIBtn: pausePlayBTN)
                view.bringSubview(toFront: playOL)
                
                view.insertSubview(pausePlayBTN, belowSubview: playOL)
                
                bg.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.maxX, height: view.frame.maxY)
                bg.backgroundColor = UIColor(red: 160 / 255, green: 190 / 255, blue: 200 / 255, alpha: 1)
                bg.alpha = 0
                
                
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    
                    self.view.insertSubview(self.bg, belowSubview: self.pausePlayBTN)
                    self.bg.alpha = 0.9
                    
                    self.pausePlayBTN.frame = CGRect(x: self.playOL.frame.minX, y: self.playOL.frame.maxY + 25, width: 50, height: 50)
                    
                }) { (_) in
                    return
                }
                
            } else {
                
                player?.play(atTime: pauseTimeByPlay!)
                pauseTimeByPlay = nil
                
            }
            
            
            setBtnImage(UIbtn: playOL, imageName: "stop")
        }
    }
    
    func stopPlay() {
        isPlaying = false
        
        player?.stop()
        
        setBtnImage(UIbtn: playOL, imageName: "playArrow")
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.bg.alpha = 0
            
            self.pausePlayBTN.frame = CGRect(x: self.playOL.frame.midX - 25, y: self.playOL.frame.midY - 25, width: 50, height: 50)
            
        }) { (_) in
            
            self.view.insertSubview(self.playOL, at: 0)
            
            self.bg.removeFromSuperview()
            
            self.pausePlayBTN.removeFromSuperview()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlay()
    }
    
    
    
    @IBAction func saveBtn(_ sender: Any) {
        
        isRecording = false
        isPauseRecord = false
        
        // 停止錄音
        volumeTimer.invalidate()
        recorder?.stop()
        recorder = nil
        volumeTimer = nil
        
        setBtnImage(UIbtn: startRecordOL, imageName: "mic")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.pauseRecordBTN.frame = CGRect(x: self.startRecordOL.frame.midX - 25, y: self.startRecordOL.frame.midY - 25, width: 50, height: 50)
            
            self.saveOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
            
            self.playOL.frame = CGRect(x: self.view.frame.midX - 127, y: self.view.frame.midY - 109, width: 75, height: 75)
            
        }, completion: { (_) in
            self.pauseRecordBTN.removeFromSuperview()
        })
        
        
    }
    
    
    
    @IBAction func delBtn(_ sender: Any) {
        
        isPlaying = false
        isRecording = false
        
        player?.stop()
        recorder?.stop()
        
        do {
            try FileManager.default.removeItem(atPath: currentFile!)
            currentFile = nil
        } catch let error {
            print(error.localizedDescription)
        }
        
        setBtnImage(UIbtn: startRecordOL, imageName: "mic")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.playOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
            
            self.delOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
            
            self.saveOL.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
            
            self.pausePlayBTN.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
            
            self.pauseRecordBTN.frame = CGRect(x: self.view.frame.midX - 37.5, y: self.view.frame.midY - 37.5, width: 75, height: 75)
            
        }, completion: { (_) in
            self.pausePlayBTN.removeFromSuperview()
            self.pauseRecordBTN.removeFromSuperview()
        })
    }
    
    
    
    
    
    // 暫停錄音
    func pauseRecord() {
        
        recorder?.pause()
        isPauseRecord = true
        isRecording = false
        setBtnImage(UIbtn: startRecordOL, imageName: "mic")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { 
            
            self.saveOL.frame = CGRect(x: self.view.frame.midX + 52, y: self.view.frame.midY - 109, width: 75, height: 75)
            
        }) { (_) in
            return
        }
    }
    
    
    // 暫停播放
    func pausePlay() {
        
        isPlaying = false
        
        player?.pause()
        pauseTimeByPlay = player?.deviceCurrentTime
        setBtnImage(UIbtn: playOL, imageName: "playArrow")
    }
    
    
    
    func volumeTimingUpdate() {
        recorder?.updateMeters()  // 執行 AVAudioRecorder 的方法，更新音量數
        volumeMax = recorder?.peakPower(forChannel: 0) // 取得最大音量
        

    }
    
  
    
    // 聲波隨音量大小改變
    func soundWave() {
        volumeTimingUpdate()
        if let maxVolume = volumeMax {
            let lowPassResult:Double = pow(Double(50), Double(0.05*maxVolume)) * 200 + 100
            let viewSize = view.frame.size
            let wave = UIView()
            
            wave.frame = CGRect(x: (Double(viewSize.width) / 2 - lowPassResult / 2), y: (Double(viewSize.height) / 2 - lowPassResult / 2), width: lowPassResult, height: lowPassResult)
            
            wave.layer.cornerRadius = wave.frame.size.width / 2
            wave.clipsToBounds = true
            wave.layer.borderColor = UIColor( red: 161 / 255, green: 235 / 255, blue: 209 / 255, alpha: 0.1 ).cgColor
            wave.layer.borderWidth = 3

            view.insertSubview(wave, at: 0)
            
            // UIView.animate 為 UIView 的類別方法
            // withDuration 為動畫秒數
            // delay 為延遲時間
            // .curveEaseOut 似乎為動畫曲線
            UIView.animate(withDuration: 3, delay: 0, options: .curveEaseOut, animations: {
                
                // 可設為動畫之屬性有限，故選用不透明度作為變化
                wave.alpha = 0
                
            }) { (_) in
                // 此處為動畫結束後執行。
                // 將 UIView 移除
                wave.removeFromSuperview()
            }
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
