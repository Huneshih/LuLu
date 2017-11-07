//
//  TableViewController.swift
//  Recording
//
//  Created by Hong Shih on 2017/8/21.
//  Copyright © 2017年 Hune. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewController: UITableViewController, AVAudioPlayerDelegate {
    
    var player = AVAudioPlayer()
    
    var isPlaying = false
    
    var playName = String()
    
    // 初始畫錄音器
    let session: AVAudioSession = AVAudioSession.sharedInstance()

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = UIColor(red: 200 / 255, green: 240 / 255, blue: 255 / 255, alpha: 1)
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(play(ntfc:)), name: NSNotification.Name("play"), object: nil)
        
        
        
        
        
        // 以下有可能會出錯，所以需要 try
        do {
            // 設定模式： AVAudioSessionCategoryPlayAndRecord  -->  播放與錄音
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
        } catch {
            // 發生錯誤時回報
            print("error")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.sharedInstance().fileCount()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        cell.fileNameLabel.text = DataManager.sharedInstance().getFileName(index: indexPath.row)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.uploadOl.tag = 1000 + indexPath.row
        
        cell.uploadOl.addTarget(self, action: #selector(presentAirDrop(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func presentAirDrop(_ sender: UIButton) {
        
        let fileIndex = sender.tag - 1000
        guard let filePath = DataManager.sharedInstance().getFileUrlWithIndex(index: fileIndex) else {
            return
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        
        let url = [fileURL]
        
        let uploadController = UIActivityViewController(activityItems: url, applicationActivities: nil)
//        uploadController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.message, UIActivityType.mail, UIActivityType.postToFacebook, UIActivityType.postToTwitter]
        
        present(uploadController, animated: true, completion: nil)
        
        
        
    }
    
    
    
//    @objc func play(ntfc: Notification) {
//
//        print("TVC 收到播放通知")
//
//        guard ntfc.userInfo?["playName"] != nil else {
//            return
//        }
//
//        playName = ntfc.userInfo!["playName"] as! String
//
//        guard let url = URL.init(string: DataManager.sharedInstance().getFilePath(filename: playName)!) else {
//            return
//        }
//
//        if isPlaying == false {
//            do {
//                try player = AVAudioPlayer(contentsOf: url)
//            } catch let err {
//                print(err.localizedDescription)
//            }
//
//            isPlaying = true
//
//            player.delegate = self
//
//            player.play()
//
//            NotificationCenter.default.addObserver(self, selector: #selector(stopPlay), name: NSNotification.Name("stopPlayByCell"), object: nil)
//
//        } else {
//
//            NotificationCenter.default.post(name: NSNotification.Name("otherCellPlay"), object: nil)
//
//            do {
//                try player = AVAudioPlayer(contentsOf: url)
//            } catch let err {
//                print(err.localizedDescription)
//            }
//
//            player.delegate = self
//
//            player.play()
//
//        }
//    }
//
//
//    @objc func stopPlay() {
//        isPlaying = false
//        player.stop()
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("stopPlayByCell"), object: nil)
//    }
//
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        isPlaying = false
//        NotificationCenter.default.post(name: NSNotification.Name("playOver"), object: nil)
//    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.sharedInstance().delFile(fileIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        guard playName != "" else {
            print("in Nil.")
            return
        }
        print(playName)
    }
    
    
}
