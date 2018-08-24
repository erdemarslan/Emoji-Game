//
//  ViewController.swift
//  Emoji
//
//  Created by Erdem Arslan on 16.08.2018.
//  Copyright © 2018 Erdem Arslan. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var btnHighScore: UIButton!
    
    // Timer Ekleyelim - Anasayfada resimleri döndürebilmek için
    var timer = Timer()
    var counter : Int = 0
    
    // High Score Ekleyelim
    var highScore : Int = 0
    
    // Oyun ayarları
    var levelStatus : [ Int : [String : Int] ] = [:]
    
    // Sayfa yüklendiğinde yapılacaklar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        timer = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(loopImages), userInfo: nil, repeats: true)
        
        // Veri tabanını ilk defa kuralım!
        if UserDefaults.standard.object(forKey: "isDatabaseOptimised") as? Bool == nil || UserDefaults.standard.object(forKey: "isDatabaseOptimised") as? Bool == false {
            // aha da kurulum yapılmamış
            firstRun()
            print("first run çalıştı")
        }
        
        // Veritabanından taç sayısını çek - fonksiyon sayıyı highScore a atar
        getNumCrowns()
        
        btnHighScore.setTitle(String(highScore), for: UIControlState.normal)
        
    }
    
    
    func  getNumCrowns() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Levels")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result : NSManagedObject in results as! [NSManagedObject] {
                    if let numCrown = result.value(forKey: "numCrowns") as? Int {
                        highScore += numCrown
                    }
                }
            }
        } catch {
            print("getNumCrowns verileri çekilemedi...")
        }
    }
    
    // Yeni bir oyun başlat
    @IBAction func btnNewGame(_ sender: Any) {
        
        performSegue(withIdentifier: "segue_Main2PreGame", sender: nil)
        
    }
    
    // Yüksek skoru sil
    @IBAction func btnClearHighScores(_ sender: Any) {
        
        // Alert view controller oluştur
        let alert = UIAlertController(title: "Emin misiniz?", message: "Oyununu tamamen sıfırlamak istediğinizden emin misiniz?", preferredStyle: UIAlertControllerStyle.alert)
        
        // alert için buton oluştur
        let evetButton = UIAlertAction(title: "Evet", style: UIAlertActionStyle.default) { (UIAlertAction) in
            
            // Burada verileri sıfırla!
            self.resetLevels()
            
            self.highScore = 0
            self.btnHighScore.setTitle(String(self.highScore), for: UIControlState.normal)
        }
        
        // alert için buton oluştur
        let hayirButton = UIAlertAction(title: "Hayır", style: UIAlertActionStyle.cancel, handler: nil)
        
        // butonları alert e ekle
        alert.addAction(hayirButton)
        alert.addAction(evetButton)
        
        // alerti göster
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetLevels() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Levels")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                var i = 1
                for result : NSManagedObject in results as! [NSManagedObject] {
                    
                    if i == 1 {
                        result.setValue(true, forKey: "isOpened")
                    } else {
                        result.setValue(false, forKey: "isOpened")
                    }
                    
                    result.setValue(0, forKey: "numCrowns")
                    
                    i += 1
                }
                
                do {
                    try context.save()
                } catch {
                    print("reseleme işleminde kayıt yapılamadı!")
                }
            }
            
            
        } catch {
            print("resetLevels veriler fetch edilemedi!")
        }
    }
    
    // Bizi oylayın
    @IBAction func btnRateUs(_ sender: Any) {
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // kendi metodumuzu kullanacağız!
            let appleID = "1433902405"
            let appStoreLink = "https://itunes.apple.com/app/id\(appleID)?action=write-review"
            UIApplication.shared.open(URL(string: appStoreLink)!, options: [:], completionHandler: nil)
        }
        
    }
    
    // Hakkında kısmı
    @IBAction func btnAbout(_ sender: Any) {
        
        performSegue(withIdentifier: "segue_Main2About", sender: nil)
    }

    
    // Resimleri animasyonlu bir biçimde döndürür...
    @objc func loopImages() {
        let mod = counter % 10
        UIView.transition(with: imageLogo,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: { self.imageLogo.image = UIImage(named: "\(mod).png") },
                          completion: nil)
        counter = counter + 1
    }
    
    
    func firstRun() {
        // Core Data veritabanı işlemleri
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        var i = 1
        while i < 13 {
            
            let yeniKayit = NSEntityDescription.insertNewObject(forEntityName: "Levels", into: context)
            
            yeniKayit.setValue(i, forKey: "id")
    
            if i == 1 {
                yeniKayit.setValue(true, forKey: "isOpened")
            } else {
                yeniKayit.setValue(false, forKey: "isOpened")
            }
            
            yeniKayit.setValue(0, forKey: "numCrowns")
            yeniKayit.setValue("Level \(i)", forKey: "name")
            
            if i == 1 {
                yeniKayit.setValue(0, forKey: "requiredCrowns")
                yeniKayit.setValue(10, forKey: "time")
                yeniKayit.setValue(6, forKey: "maxMove")
            }
            if i == 2 {
                yeniKayit.setValue(1, forKey: "requiredCrowns")
                yeniKayit.setValue(15, forKey: "time")
                yeniKayit.setValue(12, forKey: "maxMove")
            }
            if i == 3 {
                yeniKayit.setValue(4, forKey: "requiredCrowns")
                yeniKayit.setValue(20, forKey: "time")
                yeniKayit.setValue(16, forKey: "maxMove")
            }
            if i == 4 {
                yeniKayit.setValue(7, forKey: "requiredCrowns")
                yeniKayit.setValue(30, forKey: "time")
                yeniKayit.setValue(24, forKey: "maxMove")
            }
            if i == 5 {
                yeniKayit.setValue(8, forKey: "requiredCrowns")
                yeniKayit.setValue(40, forKey: "time")
                yeniKayit.setValue(35, forKey: "maxMove")
            }
            if i == 6 {
                yeniKayit.setValue(11, forKey: "requiredCrowns")
                yeniKayit.setValue(35, forKey: "time")
                yeniKayit.setValue(32, forKey: "maxMove")
            }
            if i == 7 {
                yeniKayit.setValue(14, forKey: "requiredCrowns")
                yeniKayit.setValue(60, forKey: "time")
                yeniKayit.setValue(45, forKey: "maxMove")
            }
            if i == 8 {
                yeniKayit.setValue(15, forKey: "requiredCrowns")
                yeniKayit.setValue(55, forKey: "time")
                yeniKayit.setValue(40, forKey: "maxMove")
            }
            if i == 9 {
                yeniKayit.setValue(18, forKey: "requiredCrowns")
                yeniKayit.setValue(90, forKey: "time")
                yeniKayit.setValue(55, forKey: "maxMove")
            }
            if i == 10 {
                yeniKayit.setValue(21, forKey: "requiredCrowns")
                yeniKayit.setValue(80, forKey: "time")
                yeniKayit.setValue(50, forKey: "maxMove")
            }
            if i == 11 {
                yeniKayit.setValue(24, forKey: "requiredCrowns")
                yeniKayit.setValue(120, forKey: "time")
                yeniKayit.setValue(65, forKey: "maxMove")
            }
            if i == 12 {
                yeniKayit.setValue(26, forKey: "requiredCrowns")
                yeniKayit.setValue(100, forKey: "time")
                yeniKayit.setValue(60, forKey: "maxMove")
            }
            
            do {
                try context.save()
                print("kaydedilen id \(i)")
            } catch {
                print("kayit hatasi - döngü no: \(i)")
            }
            i = i + 1
        }
        
        var words = [String]()
        var authors = [String]()
        // Sözler
        words.append("Dostun üzüntüsüne acı duyabilirsin. Bu kolaydır; ama dostun başarısına sempati duyabilmek, sağlam bir karakter gerektirir.")
        authors.append("Oscar Wilde")
        
        words.append("Dürüstlük pahalı bir mülktür ucuz insanlarda bulunmaz.")
        authors.append("Honore de Balzac")
        
        words.append("İyiliğinize inanılmasını istiyorsanız ondan hiç bahsetmeyiniz.")
        authors.append("Honore de Balzac")
        
        words.append("Acı duyabiliyorsan canlısın, başkalarının acısını duyuyorsan insansın.")
        authors.append("Lev Tolstoy")
        
        words.append("Tomurcuk derdinde olmayan ağaç odundur.")
        authors.append("Necip Fazıl Kısakürek")
        
        
        words.append("İyi olmak kolaydır zor olan adil olmaktır.")
        authors.append("Victor Hugo")
        
        words.append("Hayattaki en büyük zafer hiçbir zaman düşmemekte değil her düştüğünde ayağa kalkmakta yatar.")
        authors.append("Nelson Mandela")
        
        words.append("Akıllı adam aklını kullanır. Daha akıllı adam başkalarının da aklını kullanır. ")
        authors.append("George Bernard Shaw")
        
        words.append("Bilmediğini bilmek en iyisidir. Bilmeyip de bildiğini sanmak tehlikeli bir hastalıktır.")
        authors.append("Lao Tzu")
        
        words.append("Ey başkalarının acısıyla kaygılanmayan sana insan demek yakışık almaz.")
        authors.append("Sadi Şirazi")
        
        
        i = 0
        while i < words.count {
            let newWords = NSEntityDescription.insertNewObject(forEntityName: "PrettyWords", into: context)
            newWords.setValue(i, forKey: "id")
            newWords.setValue(authors[i], forKey: "author")
            newWords.setValue(words[i], forKey: "words")
            
            do {
                try context.save()
                print("kaydedilen words id \(i)")
            } catch {
                print("kayit hatasi - döngü no: \(i)")
            }
            
            i += 1
        }

        UserDefaults.standard.set(true, forKey: "isDatabaseOptimised")
        UserDefaults.standard.synchronize()
    }

}

