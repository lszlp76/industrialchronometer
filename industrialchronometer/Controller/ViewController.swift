//
//  ViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 31.01.2022.
//

import UIKit
import AVFoundation
import MediaPlayer



class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    let radioController: RadioButtonController = RadioButtonController()
    var m = 0 ,h = 0, lapNumber = 0, modul = 0.0 , milis = 0, counter  = 0, m_text = ""
    var max = 0.0, min = 0.0, ave = 0.0,cycPerMinute = 0.0, cycPerHour = 0.0
    var observationTime : String = " "
    var timeUnit = ""
    var volumeValue : Float = 0.0
    var startTime = Date()
    var stopTime : Date!
    var laps = [Laps]()
    var pauseLap = false
    var activateOneHun = false
    var screenSaver = false
    
    var sendingLapToCSVD = Laps.init(hour: 0, minute: 0, second: 0, msec: 0,lapnote: "",lapSay: 0)
    
    
    var lapsVal = LapsVal.init(cycleTime: [])//lapsVal LapsVal içinde float bir dizi olacak
    
    var timer = Timer()
    
    var isPlaying = false , isPaused = false
    var titleButton = "Start"
    let dataTransfer = TransferService.sharedInstance
    var numberOfLap = 0 // laplistesinde lap numarasını göstermek için lazım
    var totalTimeArrayForLapList : [String] = [] // laplistede total time görünmesi için
    var lapListLapNumberValue : [Int] = []    // laplistesinde lap numarasını göstermek için lazım
    var csvString  = ""
    let userDefault = UserDefaults.standard
    
    
    var  mscd : Int = 0
    var scd : Int = 0
    var mn : Int = 0
    var hr : Int = 0
    
    private var audioLevel : Float!
    
    @IBOutlet weak var lapListTableView: UITableView!
    
    
   // @IBOutlet weak var btnHndrMin: UIButton!
   // @IBOutlet weak var btnSecond: UIButton!
    
    @IBOutlet weak var secUnitLabel: UILabel!
 //   @IBOutlet weak var cMinUnitLabel: UILabel!
    @IBOutlet weak var aveCycTimeLabel: UILabel!
    
   
    @IBOutlet weak var maxCycTimeLabel: UILabel!
    @IBOutlet weak var minCycTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetTimer: UIButton!
    // @IBOutlet weak var outputText: UITextView!
    
    @IBOutlet weak var observationTimer: UILabel!
    @IBOutlet weak var cycPerMinuteLabel: UILabel!
    
    @IBOutlet weak var cycPerHourLabel: UILabel!
    @IBOutlet weak var lapButton: UIButton!
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBAction func btnSecondClicked(_ sender: UIButton) {
        /*
        modul = 100.0
        milis = 60
        timeUnit = "Sec."
        radioController.buttonArrayUpdated(buttonSelected: sender )*/
    }
    
    @IBAction func btnHdrtMinClicked(_ sender: UIButton) {
     /*   modul = 60.0
        milis = 100
        timeUnit =  "Cmin."
        radioController.buttonArrayUpdated(buttonSelected: sender )*/
        
        
    }
     
    
    @IBAction func saveToFile(_ sender: Any) {
        if laps.count != 0 {
            csvString = sendingLapToCSVD.CreateCSV(startTime: startTime,
                                                                    timeUnit: timeUnit,
                                                                    lapsVal: lapsVal.cycleTime,
                                                                    lapToString: laps ,
                                                                    milis: Float(milis),
                                                                    maximumCycleTime: (String( format: "%.2f",max )) ,
                                                                    minimumCycleTime: (String( format: "%.2f",min )) ,
                                                                    averageCycleTime: (String( format: "%.2f",ave )) ,
                                                                    totalStudyTime : observationTime,
                                                                    totalCycleTime :  totalTimeArrayForLapList[0],
                                                                    cyclePerMinute: String( format: "%.2f",(cycPerMinute) ),
                                                                    cyclePerHour : String( format: "%.2f",(cycPerHour) ))
                             
                             
                             // file Name enter
                             let fileNameAlert = UIAlertController (title: "Save Datas", message: "", preferredStyle: .alert)
            //Message fontu
            fileNameAlert.setValue(NSAttributedString(string: fileNameAlert.message!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital", size: 22.0 ),
                 NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                            
                ]), forKey: "attributedMessage")
                                                                                            
             //Title fonut
            fileNameAlert.setValue(NSAttributedString(string: fileNameAlert.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital-Bold", size: 25.0),
                 NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                ]), forKey: "attributedTitle")
            
          
                             fileNameAlert.addTextField { (textField) in
                                 textField.placeholder = "Your file name..."
                             }
                             
                             fileNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak fileNameAlert] (_) in
                                 guard let textField = fileNameAlert?.textFields?[0],
                                       let fileName = textField.text
                                        
                                         
                                         
                                         
                                 else {return}
                                 if (fileName.isEmpty){
                                     return
                                 }
                                 else {
                                     TransferService.sharedInstance.saveTo(name: fileName, csvString: self.csvString)
                                 }
                                 
                                 
                                 
                             }))
                             
                             fileNameAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                             
                             self.present(fileNameAlert, animated: true, completion: nil)
                             
                             }
        else {
            let noLapAlert = UIAlertController(title: " ⚠️ Laps not exist", message: "You have to catch one lap at least", preferredStyle: .alert)
            noLapAlert.setValue(UIImage(named: "cmin"), forKey: "image")
            noLapAlert.setValue(NSAttributedString(string: noLapAlert.title!, attributes: [NSAttributedString.Key.font : UIFont(name: "DS-Digital-Bold", size: 25.0) as Any,
                                                                                           NSAttributedString.Key.foregroundColor : UIColor(named: "Color")!   ]                         ), forKey: "attributedTitle")
            noLapAlert.setValue(NSAttributedString(string: noLapAlert.message!, attributes: [NSAttributedString.Key.font : UIFont(name: "DS-Digital", size: 22.0)!,
                                                                                             NSAttributedString.Key.foregroundColor : UIColor(named: "Color") as Any   ]                         ), forKey: "attributedMessage")
            
            noLapAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            
            
            self.present(noLapAlert,animated: true,completion: nil)
        }
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
     
       
    }
    /*
     * this part for volume key controls
     * listenVolumeButton is to observe one of volume keys pressed ,then it changes volume level
     * observalue volume key pressed assign method
     * MPVolumeView extension to set new value of volume level
     */
   
    func listenVolumeButton() {
        // close volume slider
        let volumeView = MPVolumeView(frame: .zero)
            volumeView.clipsToBounds = true
            view.addSubview(volumeView)
        
        let audioSession = AVAudioSession.sharedInstance()
        do
        {
            try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
            audioLevel = audioSession.outputVolume
        }
        catch {
            print("Error \(error)")
        }
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "outputVolume"{
            let audioSession = AVAudioSession.sharedInstance()
            
            if audioSession.outputVolume > audioLevel {
                
                    startTimer(UIButton.self)
              
            }
            if audioSession.outputVolume < audioLevel {
                if (isPlaying){
                takeLap((Any).self)
                }
                
            }
            
            audioLevel = audioSession.outputVolume
            print(" ses seviyesi--> \(audioLevel)")
            if audioSession.outputVolume > 0.9375{
                MPVolumeView.setVolume(0.9375)
                print("volume maxi")
                print(audioLevel)
                audioLevel = 0.9375
            }
            if audioSession.outputVolume < 0.0625 {
                MPVolumeView.setVolume(0.9375)

                print("volume mini")
                print(audioLevel)
                audioLevel = 0.9375

            }
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.lapListTableView.backgroundColor = UIColor.s
        listenVolumeButton()
        self.view.backgroundColor = UIColor.systemBackground
        
        print("cmin seçili mi \(String(describing: userDefault.getValueForSwitch(keyName: "CminUnit")))")
        if (userDefault.getValueForSwitch(keyName: "CminUnit") == true) {
            modul = 60.0
            milis = 100
            timeUnit = "Cmin."
            secUnitLabel.text = "Cminute"
            secUnitLabel.backgroundColor = UIColor.systemBackground
            TransferService.sharedInstance.modul = Int(modul)
            TransferService.sharedInstance.milis = milis
        }
        else if (userDefault.getValueForSwitch(keyName: "SecondUnit") == true) {
           
           
            
            modul = 100.0
            milis = 60
            timeUnit = "Sec."
            secUnitLabel.text = "Second"
            secUnitLabel.backgroundColor = UIColor.systemBackground
            TransferService.sharedInstance.modul = Int(modul)
            TransferService.sharedInstance.milis = milis
        }
        else
        {
            
            secUnitLabel.backgroundColor = .red
            secUnitLabel.text = "NO Unit"
        }
            
        print("saniye seçili mi \(String(describing: userDefault.getValueForSwitch(keyName: "SecondUnit")))")
        /*
         Notificationu takip ediyor.Geldikçe selector fonksiyonunu tetikliyor
         */
        let notificationCenter : NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.pauseLapOnOff), name: .pauseLapOff , object: nil)
       
        notificationCenter.addObserver(self, selector: #selector((self.screenSaverOnOff)), name: .screenSaverOff, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.TimeUnitSelect), name: .timeUnitSelection, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.ActivateOneHunderth), name: .activateOneHunderth, object: nil)
        
        
        timeLabel.textColor = UIColor(named: "Color")
        
        aveCycTimeLabel.textColor = UIColor(named : "Color")
        minCycTimeLabel.textColor = UIColor(named : "Color")
        maxCycTimeLabel.textColor = UIColor(named : "Color")
        aveCycTimeLabel.textColor = UIColor(named : "Color")
        
        /*
         pause Lap control
         
         *******/
      
        
        //******
        timeLabel.text = "00:00:00"
       
        startButton.titleLabel?.font = UIFont(name: "DS-Digital", size: 17.0)
        resetTimer.isEnabled = false
        resetTimer.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        resetTimer.titleLabel?.font = UIFont(name: "DS-Digital", size: 17.0)
        lapButton.isEnabled = false
    
        lapButton.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        lapButton.titleLabel!.font = UIFont(name: "DS-Digital", size: 17.0)
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        saveButton.titleLabel?.font = UIFont(name: "DS-Digital", size: 17.0)
        timeLabel.adjustsFontSizeToFitWidth = true
//        radioController.buttonsArray = [btnSecond,btnHndrMin]
        
      //  btnSecond.titleLabel?.font = UIFont(name: "DS-Digital", size: 17.0)
      //  btnHndrMin.titleLabel?.font =  UIFont(name: "DS-Digital", size: 17.0)
       
        secUnitLabel.font = UIFont(name: "DS-Digital", size: 25.0)
        secUnitLabel.textColor = UIColor(named: "Color")
        //cMinUnitLabel.font = UIFont(name: "DS-Digital", size: 12.0)
        cycPerHourLabel.layer.borderWidth = 1
        cycPerHourLabel.layer.cornerRadius = 10
        cycPerHourLabel.layer.borderColor = UIColor.red.cgColor
        cycPerHourLabel.textColor = UIColor(named: "Color")
        
        cycPerMinuteLabel.layer.borderWidth = 1
        cycPerMinuteLabel.layer.cornerRadius = 10
        cycPerMinuteLabel.layer.borderColor = UIColor.red.cgColor
        cycPerMinuteLabel.textColor = UIColor(named: "Color")
        
        observationTimer.layer.borderWidth = 1
        observationTimer.layer.cornerRadius = 10
        observationTimer.layer.borderColor = UIColor.red.cgColor
        observationTimer.textColor = UIColor(named: "Color")
        
        minCycTimeLabel.layer.borderWidth = 1
        maxCycTimeLabel.layer.borderWidth = 1
        aveCycTimeLabel.layer.borderWidth = 1
        minCycTimeLabel.layer.cornerRadius = 10
        maxCycTimeLabel.layer.cornerRadius = 10
        aveCycTimeLabel.layer.cornerRadius = 10
        minCycTimeLabel.layer.borderColor = UIColor.red.cgColor
        maxCycTimeLabel.layer.borderColor = UIColor.red.cgColor
        aveCycTimeLabel.layer.borderColor = UIColor.red.cgColor
        
        
        // ilk açıldığında default olarak seçilen buton
        //      radioController.defaultButton = btnSecond
       
          lapListTableView.delegate = self
        lapListTableView.dataSource = self
        
    }
   
    @objc func TimeUnitSelect(){
        if userDefault.getValueForSwitch(keyName: "SecondUnit") == false {  // saniye SEÇİLİ DEĞİL İSE
            print("Saniye açıldı")
            userDefault.setValueForSwitch(value: true, keyName: "SecondUnit") //saniyeyi açtı
            userDefault.setValueForSwitch(value: false, keyName: "CminUnit")//cmin kapattı
         
            modul = 100.0
            milis = 60
            timeUnit = "Sec."
            secUnitLabel.text = "Sec."
            secUnitLabel.backgroundColor = UIColor.systemBackground
           
            
        }
        else { // saniye Seçili ise
            print("Saniye Kapatıldı")
            userDefault.setValueForSwitch(value: false, keyName: "SecondUnit")//saniyeyi kapattı
            userDefault.setValueForSwitch(value: true, keyName: "CminUnit") //cmin açtı
            modul = 60.0
            milis = 100
            timeUnit = "Cmin."
            secUnitLabel.text = "Cmin."
            secUnitLabel.backgroundColor = UIColor.systemBackground
            
        }
            
    }
    @objc func screenSaverOnOff() {
        if userDefault.getValueForSwitch(keyName: "ScreenSaver") == false {
            
            UIApplication.shared.isIdleTimerDisabled = false
            print("screenSaver is active")
            userDefault.setValueForSwitch(value: true, keyName: "ScreenSaver")
            
        }
        else {
            
            print("screensaver is disabled")
            UIApplication.shared.isIdleTimerDisabled = true
            userDefault.setValueForSwitch(value: false, keyName: "ScreenSaver")
            
        }
    }
    @objc func pauseLapOnOff () {
     
        if userDefault.getValueForSwitch(keyName: "PauseLap") == false {
            pauseLap = true
        print( "pauseLap is ON")
            userDefault.setValueForSwitch(value: true, keyName: "PauseLap")
           
        }else {
            pauseLap = false
            print( "pauseLap is Off")
            userDefault.setValueForSwitch(value: false, keyName: "PauseLap")
        }
    }
    @objc func ActivateOneHunderth(){
        if userDefault.getValueForSwitch(keyName: "ActivateOneHunderth") == false {
            activateOneHun = true
        print( "100 luk on")
            userDefault.setValueForSwitch(value: true, keyName: "ActivateOneHunderth")
           
        }else {
            activateOneHun = false
            print( "Activate1/100 Off")
            userDefault.setValueForSwitch(value: false, keyName: "ActivateOneHunderth")
        }
    }
    /**
     Lap tuşuna basıldıkça timer üzerindeki değeri alacak.
     */
    @IBAction func takeLap(_ sender: Any) {
        
        
        m_text = "" //lapnote almak için her seferinde 0 laman gerekir
        var delta , delta0 , delta1  : Float
        delta = 0
        delta0 = 0
        delta1 = 0
        let lap = Laps(hour: h, minute: m, second: counter, msec: mscd,lapnote: m_text,lapSay: lapNumber+1)
        
        if lapNumber > 0 {
            
            
            delta1 = (Float(lap.hh)/60 + Float(lap.mm) + Float(lap.ss)/Float(milis) )
            delta0 = ( Float(laps[lapNumber-1].hh/60) + Float(laps[lapNumber-1].mm) + Float(laps[lapNumber-1].ss)/Float(milis))
            
            delta = (delta1-delta0 )
            
            laps.append(lap)
            
            lapsVal.cycleTime.append(delta) // iki lap arasındaki farkı cycletime dizisine atıyor
        }
        
        else {
            //let lap = Laps(hour: h, minute: m, second: counter, msec: mscd,lapnote: m_text,lapSay: lapNumber+1)
            laps.append(lap)
            delta = (Float(laps[0].hh/60) + Float(laps[0].mm) + Float(laps[0].ss)/Float(milis))
            
            
            lapsVal.cycleTime.append(delta) // iki lap arasındaki farkı cycletime dizisine atıyor
            
            
        }
        
        max =  Double((lapsVal.GetMaximumOfLaps(laps: lapsVal.cycleTime) ) * (Float(milis)))
        
        min =  Double((lapsVal.GetMinimumOfLaps(laps: lapsVal.cycleTime)) * (Float(milis)))
        ave = Double(( lapsVal.GetMeanOfLaps(laps: lapsVal.cycleTime) ) * (Float(milis)))
        minCycTimeLabel.text = "\(String( format: "%.2f",min )) \(timeUnit)"
        maxCycTimeLabel.text = "\(String( format: "%.2f",max )) \(timeUnit)"
        aveCycTimeLabel.text = "\(String( format: "%.2f",ave )) \(timeUnit)"
        
        cycPerMinute = Double(lapsVal.CalculateCycleTimePerMinute(laps: lapsVal.cycleTime))
        TransferService.sharedInstance.cycPerMinute = cycPerMinute
        
        cycPerHour = Double(lapsVal.CalculateCycleTimePerHour(laps: lapsVal.cycleTime))
        
        TransferService.sharedInstance.cycPerHour = cycPerHour
        cycPerMinuteLabel.text = String( format: "%.2f",(cycPerMinute) )
        cycPerHourLabel.text = String( format: "%.2f",(cycPerHour) )
        
        
        //**** to be change
        /*
         outputText.text = "\t\t\(lapNumber + 1) \t\t\t \((lap.LapToString(laps: laps[lapNumber]))  ) \t\t \(String (format: "%.2f",(lapsVal.cycleTime[lapNumber] * Float( milis)))) \(timeUnit) \n\n " + outputText.text!
         */
        dataTransfer.timeUnitToTransfer = timeUnit
        dataTransfer.lapDataToTransfer.append(lapsVal.cycleTime[lapNumber] * Float(milis))
        
        // burası laplisttableview da sondan basa doğru yazdırmak için
        // lapları sondan başa yazdırmak burada olmaz. o zaman grafikler ters çıkar.
        lapListLapNumberValue.insert(lapNumber + 1, at: 0) // lap numarası
        totalTimeArrayForLapList.insert(lap.LapToString(laps: laps[lapNumber]), at: 0) // total ölçüm zamanı
        
        
        
        
        
        lapNumber += 1
        
        lapListTableView.reloadData()
    }
    
    
    
    
    @IBAction func resetTimer(_ sender: Any) {
        
        
        
        
        //alert yaratma
        let resetAlert = UIAlertController (title:"Clear All Data", message: "Would you like to reset your study ?", preferredStyle: .alert)
        
        //Message fontu
        resetAlert.setValue(NSAttributedString(string: resetAlert.message!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital", size: 22.0 ),
             NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                        
            ]), forKey: "attributedMessage")
                                                                                        
         //Title fonut
        resetAlert.setValue(NSAttributedString(string: resetAlert.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital-Bold", size: 25.0),
             NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                        
            ]), forKey: "attributedTitle")
                                                              
        
        
//        let attributedText = NSMutableAttributedString.init(string: "Would you like to reset your study ?")
//
//        let range = NSRange(location: 0, length: attributedText.length)
//
//
//        attributedText.addAttribute(NSAttributedString.Key.kern, value: 1, range: range)
//        attributedText.setAttributes([NSMutableAttributedString.Key.font: UIFont(name: "DS-Digital", size: 12.0)], range: range)
      //  attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "DS-Digital", size: 20.0)!, range: range)
     
      
        //butonları ekleme
       
        
       
        let actionReset = UIAlertAction(title: "Reset", style: .default,handler: {
            UIAlertAction in
            
            self.resetConfig()
                                           
        })
         
        let actionCancel = UIAlertAction(title: "Cancel",style: .cancel
                                         ,handler: nil)
        
     // actionReset.setValue(actionResetTitle, forKey: "title")
        
          resetAlert.addAction(actionReset)
        
        resetAlert.addAction(actionCancel)
        
        self.present(resetAlert,animated: true,completion: nil)
        
   let  actionResetTitle = NSAttributedString(string: actionReset.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital", size: 22.0 ),
                                                                                       NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                      
                                                                                      ])
        let  actionCancelTitle = NSAttributedString(string: actionCancel.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital", size: 22.0 ),
                                                                                            NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                           
                                                                                           ])
    
        guard let label = (actionReset.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
                   label.attributedText = actionResetTitle
            
        guard let label = (actionCancel.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
                   label.attributedText = actionCancelTitle
            
     
        
        
           
        /*
         silinecekler
         laps.
         lapsVal.cycleTime.
         */
        
    }
    func resetConfig(){
        NotificationCenter.default.post(name: Notification.Name("ResetTimer") ,

    object: nil)

        self.startButton.isEnabled = true
        
        TimerStartControl.timerStartControl.timerStarted = false
        
        //self.radioController.buttonsArray[0].isEnabled = true
       // self.radioController.buttonsArray[1].isEnabled = true
        self.timer.invalidate()
        self.isPlaying = false
        self.isPaused = false
        self.counter = 0
        self.h = 0
        self.m = 0
        self.mscd = 0
        self.scd = 0
        self.mn = 0
        self.hr = 0
        
        self.timeLabel.text = "00:00:00"
        self.maxCycTimeLabel.text = ""
        self.minCycTimeLabel.text = ""
        self.aveCycTimeLabel.text = ""
        self.cycPerHourLabel.text = ""
        self.cycPerMinuteLabel.text = ""
        self.observationTimer.text = ""
       // self.milis = 0
       // self.modul = 0
        self.totalTimeArrayForLapList.removeAll()
        self.laps.removeAll()
        self.lapsVal.cycleTime.removeAll()
        self.lapNumber = 0
        //self.radioController.selectedButton?.isSelected = false
        // self.stopTime = nil
        self.startTime = Date()
        self.isPlaying = false
        self.startButton.setTitle("Start", for: .normal)
        self.dataTransfer.lapDataToTransfer.removeAll()
        self.lapListTableView.reloadData()
        self.saveButton.isEnabled = false
        self.saveButton.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        self.resetTimer.isEnabled = false
        self.resetTimer.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        
        
   
    
    
    
    }
    func PauseTimer() {
      
        
        if (pauseLap)  // kullanıcı bunu true/false yapabilr. true olursa durdurunca lap alır.
        // default olarak false ayarlı
        {takeLap((Any).self)
            
        }
        
        timer.invalidate()
        startButton.titleLabel?.font = UIFont(name: "DS-Digital", size: 17.0)
        startButton.setTitle("Continue", for: .normal)
        
        stopTime = lapsVal.setMomentTime()
        print(stopTime!)
        titleButton = "Start"
        observationTime = lapsVal.getObservationTime(start: startTime, end: stopTime)
        observationTimer.text = observationTime
        isPaused = true
       
        
    }
    
    @IBAction func startTimer(_ sender: Any) {
        
        if (modul > 0 ){
            isPlaying = true
            
            switch (titleButton){
                
                /*
                 BUtton larda veya elemanlarda font ları değiştirmek için
                 style : default olarak  ayarlaman lazım
                 main storyboard üzerinde
                 */
            case ("Start"):
                TimerStartControl.timerStartControl.timerStarted = true
                startButton.setTitle("Pause", for: .normal)
                startButton.titleLabel?.font = UIFont(name: "DS-Digital", size: 17.0)
             
               
                titleButton = "Pause"
                
                isPaused = false
                
                timer = Timer.scheduledTimer(timeInterval: modul/10000, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
                
                if !(isPlaying) {
                    startTime = lapsVal.setMomentTime() // başladığı anın değeri
                    print(startTime)
                }
                
                
                lapButton.isEnabled = true
                lapButton.backgroundColor = UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
                resetTimer.isEnabled = false
                resetTimer.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
                saveButton.isEnabled = false
                saveButton.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
                
                if (modul == 60 ){
              //      radioController.buttonsArray[0].isEnabled = false
                  //  secUnitLabel.text = "Cminute"
                }else {
                //radioController.buttonsArray[1].isEnabled = false
                 //   secUnitLabel.text = "Second"
                }
                
                break
            case ("Pause"):
                lapButton.isEnabled = false
                lapButton.backgroundColor = UIColor(red : 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
                resetTimer.isEnabled = true
                resetTimer.backgroundColor = UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
                saveButton.isEnabled = true
                saveButton.backgroundColor  = UIColor(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
                isPlaying = false
                PauseTimer()
                break
                
            default: break
                
            }
        }
        else {
            
            
            
            let unitAlert = UIAlertController (title:"Time Unit",message: "Choose your time unit", preferredStyle: .alert)
            unitAlert.setValue(NSAttributedString(string: unitAlert.message!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital", size: 22.0 ),
                 NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                            
                ]), forKey: "attributedMessage")
            unitAlert.setValue(NSAttributedString(string: unitAlert.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital-Bold", size: 25.0 ),
                 NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                            
                ]), forKey: "attributedTitle")
            
            let chooseTimeUnit = UIAlertAction (title: "OK", style: .default,handler: { UIAlertAction in
                self.performSegue(withIdentifier: "toTimeUnitSelection", sender:nil);
                return
            })
            unitAlert.addAction(chooseTimeUnit)
            self.present(unitAlert,animated: true,completion: nil)
            
            let  actionTitle = NSAttributedString(string: chooseTimeUnit.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital", size: 22.0 ),
                                                                                                NSAttributedString.Key.foregroundColor :UIColor(named: "Color")
                                                                                               
                                                                                               ])
            guard let label = (chooseTimeUnit.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
                       label.attributedText = actionTitle
        }
    }
    /***
     bu fonksiyonda
     *  mscd : milisaniyenin alacağı değeri gösterir. saniye olarak 1/100 e ayarlanmıştır.
     100 mscd = 1 sn olacak şekilde ayarlı.
     * milis ise ,zaman birimi seçimine göre değişir. Eğere seçim saniye için milis 60 değerinde 0lanır.
     cmin ise 100 değerinde 0lanır.
     counter ile scd aynı amaçla kullanılmış. tekrar yapılmış. Silersen lap alırken hesaplar karışır.
     */
    @objc func UpdateTimer (){
        
        mscd += 1;
       
        if (mscd == 100){
            scd += 1
            counter += 1
            mscd = 0
        }
        else if (scd ==  (milis)){
            mn += 1
            scd = 0
            m += 1
            counter = 0
        }
        else if ( mn == 60){
            hr += 1
            mn = 0
            h += 1
            m = 0
        }
        
        /* HARFLERİN BİR KISMINI FARKLI KARAKTERDE YAZMAK*/
        let timerText = String(String(String(hr).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed()) + ":" + String(String(String(mn).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed()) + ":" + String(String(String(scd).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed()) +  "." + String(String(String(mscd).reversed()).padding(toLength: 2, withPad: " ", startingAt: 0).reversed())
        
        let slsText = NSMutableAttributedString.init(string: timerText)
        slsText.setAttributes([NSMutableAttributedString.Key.font: UIFont(name: "DS-Digital", size: 20.0)!], range: NSMakeRange(8,3))
        
        //timeLabel.text = (String ( format: "%02ld:%02ld:%02ld.%02ld" ,h,m,counter,mscd))
        timeLabel.attributedText =  slsText
        //timeLabel.text = (String ( format: "%02ld:%02ld:%02ld.%02ld" ,hr,mn,scd,mscd))
        /*
        counter += 1
        if ( counter > 0 && Int(counter)%Int(milis) == 0)
        {
            m += 1
            counter = 0
        }
        if ( m >= 60){
            h += 1
            m = 0
        }
        
       
        timeLabel.text = (String ( format: "%02ld:%02ld:%02ld" ,h,m,counter)) //String ( hh + ":" + mm + ":" + ss)
        */
    }
    
    func transferLapToChart (lapnumber : Int){
        
        _ = storyboard?.instantiateViewController(withIdentifier: "ChartUIViewController") as! ChartUIViewController
        
        
    }
    var dizi = [ "lklk","şlşlş","lşlş","llili"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  lapsVal.cycleTime.count
    }
    
    
    
    /*
     INPUT TEXT KISMI
     
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
      
       //alert dialog box yapısı
       let notetextAlert = UIAlertController(title:"Add notes for lap \(lapListLapNumberValue[indexPath.row])", message: "deneme \(indexPath.row)",preferredStyle: .alert)
       notetextAlert.addTextField{ [self]
           field in
           if (laps[self.lapNumber-indexPath.row-1].lapnote == "")
           {
               field.placeholder = "Your note here..."
               
               
           }else
           {field.text = laps[self.lapNumber-indexPath.row-1].lapnote}
           
          
           field.returnKeyType = .next
          // field.keyboardType = .default
       }
       
  // https://www.youtube.com/watch?v=xLWfJIYg2PM
       notetextAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: 
                                                {[weak notetextAlert](_) in
          
               let textFields = notetextAlert?.textFields![0]
           self.m_text = (textFields?.text)!
           self.laps[self.lapNumber-indexPath.row-1].lapnote = self.m_text
           print("Text field değeri --> \(self.m_text)")
           
          
       }))
           
      
       
       let noteCancel = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
       
       notetextAlert.addAction(noteCancel)
       self.present(notetextAlert,animated: true,completion: nil)
   }
    
    */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lapCell = self.lapListTableView.dequeueReusableCell(withIdentifier: "lapList", for: indexPath) as! LapLineViewControllerTableViewCell
        
        lapCell.cellDelegate = self
        lapCell.index = indexPath
        let reverseOrderedLaps : [Float] = Array(lapsVal.cycleTime.reversed())
        
        lapCell.lapValue.text = (String (format: "%.2f",(reverseOrderedLaps[indexPath.row] * Float( milis))))
        lapCell.lapLabel.text = String(lapListLapNumberValue[indexPath.row])
        lapCell.lapCycle.text = totalTimeArrayForLapList[indexPath.row]
        
        
        lapCell.lapValue.textColor =  UIColor(named : "Color")
        lapCell.lapLabel.textColor =  UIColor(named : "Color")
        lapCell.lapCycle.textColor =  UIColor(named : "Color")
        lapCell.AddNote.tintColor = UIColor(named : "Color")
       // lapCell.AddNote.tag = indexPath.row
        //lapCell.AddNote.addTarget(self, action: #selector(addNotes(sender: )), for: .touchUpInside)
        
       
        switch indexPath.row % 2 {
        case 0:
            lapCell.backgroundColor = UIColor(named: "ColorForLapTableView0")
        case 1:
            lapCell.backgroundColor = UIColor(named: "ColorForLapTableView1")
        default:
            lapCell.backgroundColor = .systemBlue
        }
        return lapCell
        
    }
    @objc func addNotes ( sender:UIButton){
        print("şimdi basıldı \(sender.tag)")
    }
   
    
    
}
extension ViewController : SupportedFeaturesForLapLine{
    func onAddLapNotes(index: Int) {
       // print ("Basılan satır no su için not \(index)")
        
        let notetextAlert = UIAlertController(title:"Add notes for lap \(lapListLapNumberValue[index])", message: "",preferredStyle: .alert)
        //Title fonut
        notetextAlert.setValue(NSAttributedString(string: notetextAlert.title!, attributes: [NSAttributedString.Key.font :UIFont(name: "DS-Digital-Bold", size: 25.0) as Any,
                                                                                            NSAttributedString.Key.foregroundColor :UIColor(named: "Color") as Any
           ]), forKey: "attributedTitle")
        notetextAlert.addTextField{ [self]
            field in
            if (laps[self.lapNumber-index-1].lapnote == "")
            {
                field.placeholder = "Your note here..."
                
                
            }else
            {field.text = laps[self.lapNumber-index-1].lapnote}
            
           
            field.returnKeyType = .next
           // field.keyboardType = .default
        }
        
   // https://www.youtube.com/watch?v=xLWfJIYg2PM
        notetextAlert.addAction(UIAlertAction(title: "Add", style: .default, handler:
                                                 {[weak notetextAlert](_) in
           
                let textFields = notetextAlert?.textFields![0]
            self.m_text = (textFields?.text)!
            self.laps[self.lapNumber-index-1].lapnote = self.m_text
            print("Text field değeri --> \(self.m_text)")
            
           
        }))
            
       
        
        let noteCancel = UIAlertAction(title: "Cancel", style: .cancel,handler: nil)
        
        notetextAlert.addAction(noteCancel)
        self.present(notetextAlert,animated: true,completion: nil)
        
    }
    
    
}
/*
 timeInterval değeri 1 ise 1 snde 1 artırır. 0.6 yaparsan cmin oluyor
 counter 1 artırırsan saniye veya saat formatına çevireblirsin
 */

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if let segu  = segue.destination as? ChartViewController {
//            segu.delegate = self
//            segu.deger = getKey()

