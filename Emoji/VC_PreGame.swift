//
//  VC_PreGame.swift
//  Emoji
//
//  Created by Erdem Arslan on 17.08.2018.
//  Copyright © 2018 Erdem Arslan. All rights reserved.
//

import UIKit
import CoreData

class VC_PreGame: UIViewController {

    
    @IBOutlet weak var imageBack: UIImageView!
    @IBOutlet weak var imageLevel1: UIImageView!
    @IBOutlet weak var imageLevel2: UIImageView!
    @IBOutlet weak var imageLevel3: UIImageView!
    @IBOutlet weak var imageLevel4: UIImageView!
    @IBOutlet weak var imageLevel5: UIImageView!
    @IBOutlet weak var imageLevel6: UIImageView!
    @IBOutlet weak var imageLevel7: UIImageView!
    @IBOutlet weak var imageLevel8: UIImageView!
    @IBOutlet weak var imageLevel9: UIImageView!
    @IBOutlet weak var imageLevel10: UIImageView!
    @IBOutlet weak var imageLevel11: UIImageView!
    @IBOutlet weak var imageLevel12: UIImageView!
    
    var numCrowns : Int = 0

    // 13 adet oyuna başlama resmini içinde tutar
    var imageList : Array = [UIImageView]()
    
    // 13 adet UITapGestureRecognizer ı içinde tutar
    var tapGestureList : Array = [UITapGestureRecognizer]()
    
    // Veritabanından gelen verileri içinde tutar
    var db_idArray : Array = [Int]()
    var db_NameArray : Array = [String]()
    var db_isOpenedArray : Array = [Bool]()
    var db_numCrownsArray : Array = [Int]()
    var db_requiredCrownsArray : Array = [Int]()
    var db_timeArray : Array = [Int]()
    var db_maxMoveArray : Array = [Int]()
    
    
    var lastClickedTag : Int = 0
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Resimleri imageList değişkenimize atalım 0 back image - diğerleri ise level image
        imageList.append(imageBack)
        imageList.append(imageLevel1)
        imageList.append(imageLevel2)
        imageList.append(imageLevel3)
        imageList.append(imageLevel4)
        imageList.append(imageLevel5)
        imageList.append(imageLevel6)
        imageList.append(imageLevel7)
        imageList.append(imageLevel8)
        imageList.append(imageLevel9)
        imageList.append(imageLevel10)
        imageList.append(imageLevel11)
        imageList.append(imageLevel12)
        
        // Tap gesture leri resimlere ekle
        addTapGesturesToImages()
        
        // veri tabanımızdan level durumlarını alalım
        getLevelsFromDB()
        
        // bunları her bir level için ayarlayalım!
        setLevelsImages()
        
    }
    
    @objc func openGame(_ sender : UIGestureRecognizer) {
        lastClickedTag = 0
        
        let tag = (sender.view?.tag)!
        
        print(tag)
        lastClickedTag = tag
        
        // Oyun açılmamışsa uyarı göster
        if !db_isOpenedArray[tag] {
            let alert = UIAlertController(title: db_NameArray[tag], message: "Bu bölümü oynayabilmek için \(db_requiredCrownsArray[tag]) tane tacınızın olması gerekiyor ama sizde \(numCrowns) tane var. Lütfen biraz daha taç toplayın.", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
            alert.addAction(okButton)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            // segue_PreGame2Level1 gibi seguelere yönlendirdir!
            if tag == 1 {
                performSegue(withIdentifier: "segue_PreGame2Level1", sender: nil)
            }
            if tag == 2 {
                performSegue(withIdentifier: "segue_PreGame2Level2", sender: nil)
            }
            if tag == 3 {
                performSegue(withIdentifier: "segue_PreGame2Level3", sender: nil)
            }
            if tag == 4 {
                performSegue(withIdentifier: "segue_PreGame2Level4", sender: nil)
            }
            if tag == 5 {
                performSegue(withIdentifier: "segue_PreGame2Level5_6", sender: nil)
            }
            if tag == 6 {
                performSegue(withIdentifier: "segue_PreGame2Level5_6", sender: nil)
            }
            if tag == 7 {
                performSegue(withIdentifier: "segue_PreGame2Level7_8", sender: nil)
            }
            if tag == 8 {
                performSegue(withIdentifier: "segue_PreGame2Level7_8", sender: nil)
            }
            if tag == 9 {
                performSegue(withIdentifier: "segue_PreGame2Level9_10", sender: nil)
            }
            if tag == 10 {
                performSegue(withIdentifier: "segue_PreGame2Level9_10", sender: nil)
            }
            if tag == 11 {
                performSegue(withIdentifier: "segue_PreGame2Level11_12", sender: nil)
            }
            if tag == 12 {
                performSegue(withIdentifier: "segue_PreGame2Level11_12", sender: nil)
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_PreGame2Level1" {
            let vc = segue.destination as! VC_Level1
            vc.levelID = 1
            vc.levelName = self.db_NameArray[1]
            vc.gameTime = self.db_timeArray[1]
            vc.levelMaxMove = self.db_maxMoveArray[1]
        }
        
        if segue.identifier == "segue_PreGame2Level2" {
            let vc = segue.destination as! VC_Level2
            vc.levelID = 2
            vc.levelName = self.db_NameArray[2]
            vc.gameTime = self.db_timeArray[2]
            vc.levelMaxMove = self.db_maxMoveArray[2]
        }
        
        if segue.identifier == "segue_PreGame2Level3" {
            let vc = segue.destination as! VC_Level3
            vc.levelID = 3
            vc.levelName = self.db_NameArray[3]
            vc.gameTime = self.db_timeArray[3]
            vc.levelMaxMove = self.db_maxMoveArray[3]
        }
        
        if segue.identifier == "segue_PreGame2Level4" {
            let vc = segue.destination as! VC_Level4
            vc.levelID = 4
            vc.levelName = self.db_NameArray[4]
            vc.gameTime = self.db_timeArray[4]
            vc.levelMaxMove = self.db_maxMoveArray[4]
        }
        
        if segue.identifier == "segue_PreGame2Level5_6" && lastClickedTag == 5 {
            let vc = segue.destination as! VC_Level5_6
            vc.levelID = 5
            vc.levelName = self.db_NameArray[5]
            vc.gameTime = self.db_timeArray[5]
            vc.levelMaxMove = self.db_maxMoveArray[5]
        }
        
        if segue.identifier == "segue_PreGame2Level5_6" && lastClickedTag == 6 {
            let vc = segue.destination as! VC_Level5_6
            vc.levelID = 6
            vc.levelName = self.db_NameArray[6]
            vc.gameTime = self.db_timeArray[6]
            vc.levelMaxMove = self.db_maxMoveArray[6]
        }
        
        if segue.identifier == "segue_PreGame2Level7_8" && lastClickedTag == 7 {
            let vc = segue.destination as! VC_Level7_8
            vc.levelID = 7
            vc.levelName = self.db_NameArray[7]
            vc.gameTime = self.db_timeArray[7]
            vc.levelMaxMove = self.db_maxMoveArray[7]
        }
        
        if segue.identifier == "segue_PreGame2Level7_8" && lastClickedTag == 8 {
            let vc = segue.destination as! VC_Level7_8
            vc.levelID = 8
            vc.levelName = self.db_NameArray[8]
            vc.gameTime = self.db_timeArray[8]
            vc.levelMaxMove = self.db_maxMoveArray[8]
        }
        
        if segue.identifier == "segue_PreGame2Level9_10" && lastClickedTag == 9 {
            let vc = segue.destination as! VC_Level9_10
            vc.levelID = 9
            vc.levelName = self.db_NameArray[9]
            vc.gameTime = self.db_timeArray[9]
            vc.levelMaxMove = self.db_maxMoveArray[9]
        }
        
        if segue.identifier == "segue_PreGame2Level9_10" && lastClickedTag == 10 {
            let vc = segue.destination as! VC_Level9_10
            vc.levelID = 10
            vc.levelName = self.db_NameArray[10]
            vc.gameTime = self.db_timeArray[10]
            vc.levelMaxMove = self.db_maxMoveArray[10]
        }
        
        if segue.identifier == "segue_PreGame2Level11_12" && lastClickedTag == 11 {
            let vc = segue.destination as! VC_Level11_12
            vc.levelID = 11
            vc.levelName = self.db_NameArray[11]
            vc.gameTime = self.db_timeArray[11]
            vc.levelMaxMove = self.db_maxMoveArray[11]
        }
        
        if segue.identifier == "segue_PreGame2Level11_12" && lastClickedTag == 12 {
            let vc = segue.destination as! VC_Level11_12
            vc.levelID = 12
            vc.levelName = self.db_NameArray[12]
            vc.gameTime = self.db_timeArray[12]
            vc.levelMaxMove = self.db_maxMoveArray[12]
        }
    }
    
    func setLevelsImages() {
        var i = 1
        while i < db_idArray.count {
            
            // Önce resimleri ayarlayalım
            if db_isOpenedArray[i] == true {
                if db_numCrownsArray[i] == 0 {
                    self.imageList[i].image = UIImage(named: "game_bad.png")
                }
                if db_numCrownsArray[i] == 1 {
                    self.imageList[i].image = UIImage(named: "game_poor.png")
                }
                if db_numCrownsArray[i] == 2 {
                    self.imageList[i].image = UIImage(named: "game_good.png")
                }
                if db_numCrownsArray[i] == 3 {
                    self.imageList[i].image = UIImage(named: "game_best.png")
                }
            } else {
                self.imageList[i].image = UIImage(named: "game_locked.png")
            }
            
            // toplam yıldız sayısını ekle
            numCrowns += self.db_numCrownsArray[i]
            
            i += 1
        }
    }
    
    func addTapGesturesToImages() {
        // resimlerimizin her biri için bir tap gesture yapalım ve tapGestureList değişkenimize atayalım
        var i = 0
        while i < 13 {
            
            if i == 0 {
                self.tapGestureList.append(UITapGestureRecognizer(target: self, action: #selector(VC_PreGame.goBack)))
            } else {
                self.tapGestureList.append(UITapGestureRecognizer(target: self, action: #selector(VC_PreGame.openGame(_:))))
            }
            i = i + 1
        }
        
        // her bir tapGesture elemanımızı resimlerimize atalım
        i = 0
        while i < 13 {
            self.imageList[i].addGestureRecognizer(self.tapGestureList[i])
            i = i + 1
        }
    }
    
    func getLevelsFromDB() {
        
        db_idArray.removeAll(keepingCapacity: false)
        db_NameArray.removeAll(keepingCapacity: false)
        db_isOpenedArray.removeAll(keepingCapacity: false)
        db_numCrownsArray.removeAll(keepingCapacity: false)
        db_requiredCrownsArray.removeAll(keepingCapacity: false)
        db_timeArray.removeAll(keepingCapacity: false)
        db_maxMoveArray.removeAll(keepingCapacity: false)
        
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Levels")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                self.db_idArray.append(0)
                self.db_NameArray.append("No Level")
                self.db_isOpenedArray.append(true)
                self.db_numCrownsArray.append(0)
                self.db_requiredCrownsArray.append(0)
                self.db_timeArray.append(0)
                self.db_maxMoveArray.append(0)
                
                
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? Int {
                        self.db_idArray.append(id)
                    }
                    
                    if let name = result.value(forKey: "name") as? String {
                        self.db_NameArray.append(name)
                    }
                    
                    if let isOpened = result.value(forKey: "isOpened") as? Bool {
                        self.db_isOpenedArray.append(isOpened)
                    }
                    
                    if let numCrowns = result.value(forKey: "numCrowns") as? Int {
                        self.db_numCrownsArray.append(numCrowns)
                    }
                    
                    if let requiredCrowns = result.value(forKey: "requiredCrowns") as? Int {
                        self.db_requiredCrownsArray.append(requiredCrowns)
                    }
                    
                    if let time = result.value(forKey: "time") as? Int {
                        self.db_timeArray.append(time)
                    }
                    
                    if let maxMove = result.value(forKey: "maxMove") as? Int {
                        self.db_maxMoveArray.append(maxMove)
                    }
                }
                
            }
        } catch {
            print("leveli db den çekerken hata")
        }
    }
    
    @objc func goBack() {
        performSegue(withIdentifier: "segue_PreGame2Main", sender: nil)
    }
    
    

}
