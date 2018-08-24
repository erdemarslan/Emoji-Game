//
//  VC_EndGame.swift
//  Emoji
//
//  Created by Erdem Arslan on 20.08.2018.
//  Copyright © 2018 Erdem Arslan. All rights reserved.
//

import UIKit
import CoreData

class VC_EndGame: UIViewController {

    @IBOutlet weak var txtEndTitle: UILabel!
    @IBOutlet weak var imgEnd: UIImageView!
    @IBOutlet weak var txtPrettyWord: UITextView!
    @IBOutlet weak var txtPrettyWordAuthor: UILabel!
    @IBOutlet weak var imgCrown: UIImageView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnMainMenu: UIButton!
    @IBOutlet weak var txtUserScore: UILabel!
    @IBOutlet weak var txtMaxScore: UILabel!
    @IBOutlet weak var pBar: UIProgressView!
    
    
    
    var gameId : Int = 0
    var endTitle : String = ""
    var endImage : String = ""
    var numCrown : Int = 0
    var crownImage : String = ""
    
    var maxPoint : Int = 0
    var userPoint : Int = 0
    
    let context : NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var numAllCrowns : Int = 0
    var levelCrownsList : Array = [Int]()
    var requiredCrownList : Array = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Görsel öğeleri yerleştir
        txtEndTitle.text = endTitle
        imgEnd.image = UIImage(named: endImage)
        imgCrown.image = UIImage(named: crownImage)
        
        txtMaxScore.text = String(maxPoint)
        txtUserScore.text = String(userPoint)
        
        let yuzde : Float = Float(userPoint) * 100 / Float(maxPoint) / 100
        
        print("yuzde : \(yuzde)")
        
        pBar.progress = yuzde
        
        // veritabanından özlü söz çek ve yaz
        getPrettyWord()
        
        // veritabanına yıldızı yaz
        addCrownToThisLevel()
        
        // eğer yeni level gerekli mi?
        checkNewLevelAvailable()
        
    }
    
    func checkNewLevelAvailable() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Levels")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                levelCrownsList.append(0)
                requiredCrownList.append(0)
                
                for result : NSManagedObject in results as! [NSManagedObject] {
                    
                    if let numCrowns = result.value(forKey: "numCrowns") as? Int {
                        levelCrownsList.append(numCrowns)
                        numAllCrowns += numCrowns
                    }
                    
                    if let requiredCrowns = result.value(forKey: "requiredCrowns") as? Int {
                        requiredCrownList.append(requiredCrowns)
                    }
                }
            }
            
        } catch {
            print("Levels çekilemedi - checknewlevelavailable")
        }
        
        // açılması gereken level varsa aç!
        self.unlockNewLevel()
        
        print(levelCrownsList)
        print(requiredCrownList)
        print(numAllCrowns)
        
        
    }
    
    func unlockNewLevel() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Levels")
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        var i = 1
        
        while i < requiredCrownList.count {
            
            if numAllCrowns >= requiredCrownList[i] {
                
                request.predicate = NSPredicate(format: "id = %D", i)
                
                do {
                    let result = try context.fetch(request)
                    
                    if result.count > 0 {
                        let level : Levels = result.first as! Levels
                        level.setValue(true, forKey: "isOpened")
                        
                        do {
                            try context.save()
                        } catch {
                            print("eleman güncellenemedi!")
                        }
                    }
                    
                } catch {
                    print("i")
                }
            }
            
            i += 1
        }
    }
    
    func addCrownToThisLevel() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Levels")
        request.predicate = NSPredicate(format: "id = %D", gameId)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                let level : Levels = result.first as! Levels
                
                let crown : Int = Int(level.numCrowns)
                // taç sayısı var olandan daha büyükse güncelle sadece!
                if numCrown > crown {
                    level.setValue(numCrown, forKey: "numCrowns")
                    
                    do {
                        try context.save()
                        print("güncelleme başarılı")
                    } catch {
                        print("güncelleme başarı değil")
                    }
                }
            }
        } catch {
            print("crown eklemede veri alınamadı")
        }
    }
    
    func getPrettyWord() {
        
        //let context =
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PrettyWords")
        
        var count = 0
        do {
            count = try context.count(for: request)
        } catch {
            print("sayma hatası")
            count = 0
        }
        
        print("count: \(count)")
        
        if count > 0 {
            let randomNumber = Int(arc4random_uniform(UInt32(count)))
            
            print("rasgele sayi \(randomNumber)")
            request.predicate = NSPredicate(format: "id = %D", randomNumber) // burada rasgele sayı bulmamız lazım! :(
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    
                    // Ahan da tek kayıt getirme!
                    let prettywords : PrettyWords = results.first as! PrettyWords
                    txtPrettyWord.text = prettywords.words!
                    txtPrettyWordAuthor.text = prettywords.author!
                    
                } else {
                    txtPrettyWord.text = "Tomurcuk derdinde olmayan ağaç odundur."
                    txtPrettyWordAuthor.text = "Necip Fazıl Kısakürek"
                    print("results 0 geldi")
                }
            } catch {
                print("güzel söz çekilemedi!")
                txtPrettyWord.text = "Tomurcuk derdinde olmayan ağaç odundur."
                txtPrettyWordAuthor.text = "Necip Fazıl Kısakürek"
            }
        }
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        performSegue(withIdentifier: "segue_End2PreGame", sender: nil)
    }
    
    @IBAction func btnMainMenuClicked(_ sender: Any) {
        performSegue(withIdentifier: "segue_End2Main", sender: nil)
    }
    

}
