//
//  DataManager.swift
//  Recording
//
//  Created by Hong Shih on 2017/8/18.
//  Copyright © 2017年 Hune. All rights reserved.
//

import Foundation
import UIKit

class DataManager {
    
    // 單例物件
    
    private static var _sharedDataManager: DataManager?
    
    static func sharedInstance() -> DataManager {
        
        _sharedDataManager = DataManager()
        _sharedDataManager?.prepareData()
        
        return _sharedDataManager!
    }

    private init() {
        
    }
    
    
    
    
    var filePath: String?
    var fileName: [String]?
    
    
    func prepareData() {
        
        filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        
        do {
            try fileName = FileManager.default.contentsOfDirectory(atPath: filePath!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        if let dsIndex = fileName?.index(of: ".DS_Store") {
            fileName?.remove(at: dsIndex)
        }
        
        
    }
    
    // 檔案數量
    func fileCount() -> Int {
        guard fileName != nil else {
            return 0
        }
        return (fileName?.count)!
    }
    
    // 取出指定檔案名稱
    func getFileName(index: Int) -> String? {
        
        guard index >= 0 || index < (fileName?.count)! else {
            return nil
        }
        
        return fileName![index]
    }
    
    // 取出指定檔案路徑
    func getFilePath(filename: String) -> String? {
        
        guard fileName?.index(of: filename) != nil else {
            return nil
        }
        
        return filePath! + "/" + filename
    }
    
    func getFileUrlWithIndex(index: Int) -> String? {
        
        guard let fn = fileName?[index] else {
            return nil
        }
        
        return filePath! + "/" + fn
    }
    
    
    
    func delFile(fileIndex: Int) {
        do {
            try FileManager.default.removeItem(atPath: filePath! + "/" + (fileName?[fileIndex])!)
            prepareData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    static func refreshSelf() {
        _sharedDataManager?.prepareData()
    }
    
    
    
    
}
