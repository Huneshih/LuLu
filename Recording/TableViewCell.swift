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
    
    var isPlaying = false
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        playOl.layer.cornerRadius = playOl.frame.width / 2
        playOl.clipsToBounds = true
        
    }
    
    
    @IBAction func playBtn(_ sender: Any) {
        
        if isPlaying == false {
            
            isPlaying = true
            
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
