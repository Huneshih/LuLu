//
//  TableViewCell.swift
//  Recording
//
//  Created by Hong Shih on 2017/8/21.
//  Copyright © 2017年 Hune. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    @IBOutlet weak var playOl: UIButton!
    @IBOutlet weak var uploadOl: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    let audioManager = AudioManager.shared
    
//    var fileName = "123"
    
    var isPlaying = false
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        fileName = fileNameLabel.text!
        
//        print("cell 的 fileName: \(fileName)")
        
        playOl.layer.cornerRadius = playOl.frame.width / 2
        playOl.clipsToBounds = true
        // Initialization code
        
    }
    
    
    @IBAction func playBtn(_ sender: Any) {
        
        if isPlaying == false {
            
            
            
            isPlaying = true
            
//            NotificationCenter.default.post(name: NSNotification.Name("play"), object: nil, userInfo: ["playName":"\(fileNameLabel.text!)"])
            
            playOl.setImage(UIImage(named: "stop.png"), for: .normal)
            
            audioManager.play(fileName: fileNameLabel.text!)
            
            NotificationCenter.default.addObserver(self, selector: #selector(playingStop), name: NSNotification.Name("playOver"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playingStop), name: NSNotification.Name("otherCellPlay"), object: nil)
            
        } else {
            
            cellStopPlay()
        }
        
    }
    
    @objc func playingStop() {
        
        if isPlaying == true {
            isPlaying = false
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("playOver"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("otherCellPlay"), object: nil)
            playOl.setImage(UIImage(named: "playArrow.png"), for: .normal)
        }
    }
    
    func cellStopPlay() {
        if isPlaying == true {
            isPlaying = false
            
//            NotificationCenter.default.post(name: NSNotification.Name("stopPlayByCell"), object: nil)
//
            audioManager.stopPlay()
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("playOver"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("otherCellPlay"), object: nil)
            playOl.setImage(UIImage(named: "playArrow.png"), for: .normal)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
