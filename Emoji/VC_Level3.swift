//
//  VC_Level3.swift
//  Emoji
//
//  Created by Erdem Arslan on 19.08.2018.
//  Copyright © 2018 Erdem Arslan. All rights reserved.
//

import UIKit

class VC_Level3: UIViewController {

    @IBOutlet weak var txtLevelName: UILabel!
    @IBOutlet weak var txtTime: UILabel!
    
    @IBOutlet weak var img0: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img5: UIImageView!
    @IBOutlet weak var img6: UIImageView!
    @IBOutlet weak var img7: UIImageView!
    
    
    
    // bunları dışarıdan değiştireceğiz
    var levelID : Int = 0
    var levelName : String = ""
    var gameTime : Int = 0
    var levelscoreMultiple : Double = 0.0
    var levelMaxMove : Int = 0
    
    // Sayfa içi değişkenlerimiz
    var timeToEnd : Int = 0
    var imageList : Array = [UIImageView]()
    var numImages : Int = 0
    var randomImagesList : Dictionary<Int, Int> = [Int : Int]()
    var timer : Timer = Timer()
    var isGameEnd : Bool = false
    var closedImages : Array = [Int]()
    var matchingImages : Array = [Int]()
    var closeOpenedImages : Bool = false
    var numUnsuccessMove : Int = 0
    
    var maxPoint : Int = 0
    var currentPoint : Int = 0
    
    // açılışta çalışır!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bilgileri dolduralım
        txtLevelName.text = levelName
        
        timeToEnd = gameTime
        writeTimeToUILabel()
        
        imageList.append(img0)
        imageList.append(img1)
        imageList.append(img2)
        imageList.append(img3)
        imageList.append(img4)
        imageList.append(img5)
        imageList.append(img6)
        imageList.append(img7)
        
        // toplam resim sayısı
        numImages = imageList.count
        
        // Tap Gesturesleri resimlere ekle
        addTapGesturesToImages()
        
        // Rasgele resim bulalım ve bunları rasgele yerleştirelim
        generateGameImages()
        
        // Oyunu başlaT
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerTickTock), userInfo: nil, repeats: true)
        
        
        
        
    }
    
    // oyunu bitirir!
    func gameEnd() {
        // hadi oyunu bitirelim
        
        // her ihtimale karşı timer ı durduralım
        timer.invalidate()
        
        // segue yi çalıştıralım
        performSegue(withIdentifier: "segue_EndLevel", sender: nil)
    }
    
    // segue yi çalıştırmadan önce yapılması gerekenleri yapar!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_EndLevel" {
            let destinationVC = segue.destination as! VC_EndGame
            let crown = calculateCrown()
            destinationVC.gameId = levelID
            destinationVC.numCrown = crown
            
            destinationVC.maxPoint = maxPoint
            destinationVC.userPoint = currentPoint
            
            if crown == 0 {
                destinationVC.endTitle = "Berbat"
                destinationVC.endImage = "end_omg.png"
                destinationVC.crownImage = "no_crown.png"
            } else if crown == 1 {
                destinationVC.endTitle = "İdare eder"
                destinationVC.endImage = "end_notbad.png"
                destinationVC.crownImage = "one_crown.png"
            } else if crown == 2 {
                destinationVC.endTitle = "Güzel"
                destinationVC.endImage = "end_good.png"
                destinationVC.crownImage = "two_crown.png"
            } else if crown == 3 {
                destinationVC.endTitle = "Süpersin"
                destinationVC.endImage = "end_super.png"
                destinationVC.crownImage = "three_crown.png"
            }
        }
    }
    
    // Dokanılan resmi açar!
    @objc func openImage(_ sender : UIGestureRecognizer) {
        // oyun bitmiş ise işlem yapma!
        if isGameEnd {
            return
        }
        
        // resmin etiketini al
        let tag : Int = (sender.view?.tag)!
        
        print(tag)
        
        // Açık resimler kapatılacaksa bunu yap!
        if closeOpenedImages {
            self.imageList[matchingImages[0]].image = UIImage(named: "question.png")
            self.imageList[matchingImages[1]].image = UIImage(named: "question.png")
            matchingImages.removeAll()
            closeOpenedImages = false
        }
        
        // kapalı bir resme dokunulmuşsa işlem yapma bunu buraya yazmamızın sebebi kapatılacak resim varsa kapatılsın diye
        if closedImages.contains(tag) {
            return
        }
        
        // eşleşme sayısı 2 den az ise bunları sakla ve eşleştirmeye çalış
        if !matchingImages.contains(tag) && matchingImages.count < 2 {
            matchingImages.append(tag)
            self.imageList[tag].image = UIImage(named: "\(randomImagesList[tag] ?? tag).png")
        }
        
        // eşleşme sayısı 2 ise eşleşmeleri kontrol et
        if matchingImages.count == 2 {
            if randomImagesList[matchingImages[0]] == randomImagesList[matchingImages[1]] {
                // resimler eşleşti!
                // skor hesapla
                // bu resimleri kapat! ve resimleri kapaliResimler dizisine kaydet! - kapanan resimlerden taprecognizer ı kaldır!
                self.imageList[matchingImages[0]].image = UIImage(named: "bos.png")
                self.imageList[matchingImages[1]].image = UIImage(named: "bos.png")
                closedImages.append(matchingImages[0])
                closedImages.append(matchingImages[1])
                // tüm eşleşmeleri sil
                matchingImages.removeAll()
                closeOpenedImages = false
            } else {
                // tüm açık resimlerin kapanması için bir tıklama daha bekle!
                numUnsuccessMove += 1
                closeOpenedImages = true
            }
        }
        
        // test için şimdilik - olur da aynı anda 3 veya daha fazla resme dokunulursa. ne olur ne olmaz
        if matchingImages.count > 2 {
            print("anam çok dokandılar lan...")
        }
        
        // kapalı resim sayısı toplam resim sayısına eşit ise, yani oyun bitmiş ise
        if closedImages.count == numImages {
            // Oyun bitti
            // bir sonraki sahneye geç!
            // belirli bir puanın üzerindeyse bir sonraki levele geç
            // değilse oyunu bitir!
            timer.invalidate()
            isGameEnd = true
            print("oyun bitti")
            gameEnd()
        }
    }
    
    // zamanlayıcı fonksiyon
    @objc func timerTickTock() {
        timeToEnd -= 1
        writeTimeToUILabel()
        
        if timeToEnd == 0 {
            timer.invalidate()
            isGameEnd = true
            print("zaman bitti")
            gameEnd()
        }
    }
    
    // kaç tane taç kazandık onu söyler!
    func calculateCrown() -> Int {
        // max puan hesaplayalım hadi
        maxPoint = ((10 * numImages) + (levelMaxMove)) * gameTime
        // şu andaki puanı hesaplayalım
        currentPoint = ((10 * numImages) + (levelMaxMove - numUnsuccessMove)) * timeToEnd
        // max puanının çeyreğini alalım
        let quarter = Int(maxPoint / 4)
        // Taç değişkeni
        var crown = 0
        
        // eğer puanımız çeyrekten az ise 0 taç - çeyrek yarım arası 1 taç, yarım yarımdan büyük arası 2 taç - yarımdan büyükse 3 taç
        if currentPoint <= quarter {
            crown = 0
        } else if currentPoint > quarter && currentPoint <= quarter * 2 {
            crown = 1
        } else if currentPoint > quarter * 2 && currentPoint <= quarter * 3 {
            crown = 2
        } else {
            crown = 3
        }
        
        return crown
    }
    
    // rasgele resimleri seçer ve bunların yerleşimlerini ayarlar!
    func generateGameImages() {
        var randomImages = [Int]()
        var numberLocation = [Int]()
        
        var i = 0
        while i < numImages / 2 {
            var devam = false
            while !devam {
                let randomNumber =  Int(arc4random_uniform(19))
                if !randomImages.contains(randomNumber) {
                    randomImages.append(randomNumber)
                    randomImages.append(randomNumber)
                    devam = true
                }
            }
            i += 1
        }
        
        // bunların nasıl yerleşeceğini belirleyelim
        i = 0
        while i < numImages {
            var devam = false
            while !devam {
                let randomNumber =  Int(arc4random_uniform(UInt32(numImages)))
                if !numberLocation.contains(randomNumber) {
                    numberLocation.append(randomNumber)
                    devam = true
                }
            }
            i += 1
        }
        
        i = 0
        while i < numImages {
            randomImagesList[numberLocation[i]] = randomImages[i]
            i += 1
        }
    }
    
    // resimlere dokunma hareketi verir
    func addTapGesturesToImages() {
        var i = 0
        
        while i < imageList.count {
            self.imageList[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VC_Level1.openImage(_:))))
            self.imageList[i].isUserInteractionEnabled = true
            i += 1
        }
    }
    
    // zaman değişkenini label a yazar
    func writeTimeToUILabel() {
        
        let minute = Int(timeToEnd / 60)
        let second = Int(timeToEnd % 60)
        
        var minText = String(minute)
        var secText = String(second)
        
        if minute < 10 {
            minText = "0\(minute)"
        }
        
        if second < 10 {
            secText = "0\(second)"
        }
        
        txtTime.text = "\(minText):\(secText)"
    }

}
