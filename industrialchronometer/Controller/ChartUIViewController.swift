//
//  ChartUIViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 15.01.2023.
//

import UIKit
import Charts
import TinyConstraints


class ChartUIViewController: UIViewController {

    lazy  var lineChartView : LineChartView = {
          let chartView = LineChartView()
          chartView.backgroundColor = .systemBackground
          return chartView
      }()
    @IBOutlet weak var minLbl: UILabel!
    
    @IBOutlet weak var cyclePerMinuteLbl: UILabel!
    @IBOutlet weak var aveLbl: UILabel!
    @IBOutlet weak var maxLbl: UILabel!
    //var  lineChartView = LineChartView()
    @IBOutlet weak var cyclePerHourLbl: UILabel!
    
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var lapsVal = LapsVal.init(cycleTime: [])
     override func viewWillAppear(_ animated: Bool) {
          NotificationCenter.default.addObserver(self, selector: #selector(functionName), name: Notification.Name("ResetTimer"), object: nil)
        
         setData()
      
        
          
      }
      override func viewDidLoad() {
          super.viewDidLoad()
          
         minLbl.layer.borderWidth = 1
          minLbl.layer.cornerRadius = 10
          minLbl.layer.borderColor = UIColor.red.cgColor
          minLbl.textColor = UIColor(named: "Color")

          maxLbl.layer.borderWidth = 1
           maxLbl.layer.cornerRadius = 10
           maxLbl.layer.borderColor = UIColor.red.cgColor
           maxLbl.textColor = UIColor(named: "Color")

          aveLbl.layer.borderWidth = 1
           aveLbl.layer.cornerRadius = 10
           aveLbl.layer.borderColor = UIColor.red.cgColor
           aveLbl.textColor = UIColor(named: "Color")
          
          cyclePerHourLbl.layer.borderWidth = 1
           cyclePerHourLbl.layer.cornerRadius = 10
           cyclePerHourLbl.layer.borderColor = UIColor.red.cgColor
           cyclePerHourLbl.textColor = UIColor(named: "Color")

          cyclePerMinuteLbl.layer.borderWidth = 1
           cyclePerMinuteLbl.layer.cornerRadius = 10
           cyclePerMinuteLbl.layer.borderColor = UIColor.red.cgColor
           cyclePerMinuteLbl.textColor = UIColor(named: "Color")

          
          lineChartView = LineChartView(frame: CGRect(x:0,y:0,width: view.frame.size.width,height: view.frame.size.width))
          
        
       
          
         containerView.addSubview(lineChartView)
         // lineChartView.backgroundColor = UIColor.systemGroupedBackground
         //lineChartView.center = containerView.center
         // UIColor(cgColor: CGColor.init(red: 255/255, green: 235/255, blue: 238/255, alpha: 1))
  //
      lineChartView.edgesToSuperview()
  //
      //lineChartView.centerInSuperview()
  //        lineChartView.width(to: self.view)
  //        lineChartView.heightToWidth(of: self.view)
          
      }
      @objc func functionName (notification: NSNotification){
         
        // lineChartView.clearValues()
//          lineChartView.leftAxis.removeAllLimitLines()
//          lineChartView.setNeedsDisplay()
          minLbl.text = ""
          maxLbl.text = ""
          aveLbl.text = ""
          cyclePerHourLbl.text = ""
          cyclePerMinuteLbl.text = ""
          lapsVal.cycleTime.removeAll()
          TransferService.sharedInstance.cycPerMinute = 0.0
          TransferService.sharedInstance.cycPerHour = 0.0
         
      
      }
      
    
      
      
      func setData(){
      
          
          
          var tmax, tmin, tave : ChartLimitLine
          
         
          var unitFromChrono : String
          unitFromChrono = TransferService.sharedInstance.timeUnitToTransfer
          let dataFromChrono = TransferService.sharedInstance.lapDataToTransfer
         
          
     
          cyclePerHourLbl.text = String( format: "%.2f",TransferService.sharedInstance.cycPerHour )
          cyclePerMinuteLbl.text = String( format: "%.2f",TransferService.sharedInstance.cycPerMinute)
             
          if  (dataFromChrono.count != 0)
          {
              var YValues = [ChartDataEntry]() // = [ChartDataEntry(x: 0.0, y: 0.0)]//
              var x = 0.0
              var sumData = 0.0
              
            print("değer \(dataFromChrono)")
             
           
              
              while Int(x) < dataFromChrono.count {
                  YValues.append(ChartDataEntry (x: x+1, y: Double(dataFromChrono[Int(x)])))
                  
                  sumData += Double(dataFromChrono[Int(x)])
                 
                  x += 1
              }
              let meanData = ( (sumData) / Double((dataFromChrono.count)) )  //ilk data 0.0 olduğu için
              let set1 = LineChartDataSet (entries: YValues)
              let data = LineChartData(dataSet: set1)
              data.setValueFont(UIFont(name: "DS-Digital", size: 12.0)!)
              set1.valueFont = UIFont(name: "DS-Digital", size: 12.0)!
              
              
             
            
              tmax = ChartLimitLine (limit: Double(dataFromChrono.max()!), label: " Max.Cyc Time \(String( format: "%.2f",Double(dataFromChrono.max()!) )) \(unitFromChrono)")
              tmin = ChartLimitLine (limit: Double(dataFromChrono.min()!),label: "Min.Cyc Time \(String( format: "%.2f",Double(dataFromChrono.min()!) )) \(unitFromChrono)")
              tave = ChartLimitLine(limit: Double(meanData) ,label: "Mean Cycle Time \(String( format: "%.2f",Double(meanData) )) \(unitFromChrono)")
              
              tmax.valueFont = UIFont(name: "DS-Digital", size: 12.0)!
              tmin.valueFont = UIFont(name: "DS-Digital", size: 12.0)!
              tave.valueFont = UIFont(name: "DS-Digital", size: 12.0)!
              tmax.lineWidth = 2.0
              tmin.lineWidth = 2.0
              tave.lineWidth = 2.0
              tave.lineColor = UIColor.green
              tmax.lineColor = UIColor.red
              tmin.lineColor = UIColor.red
              
              maxLbl.text = String( format: "%.2f",Double(dataFromChrono.max()!) ) + " " + unitFromChrono
              minLbl.text = String( format: "%.2f",Double(dataFromChrono.min()!) ) + " " + unitFromChrono
              aveLbl.text = String( format: "%.2f",Double(meanData) ) + " " + unitFromChrono
              
              
              let yAxis = lineChartView.leftAxis
              yAxis.removeAllLimitLines()
              yAxis.addLimitLine(tmax)
              yAxis.addLimitLine(tmin)
              yAxis.addLimitLine(tave)
              yAxis.drawLimitLinesBehindDataEnabled = true
              yAxis.labelFont = UIFont(name: "DS-Digital", size: 12.0)!
              
              
              let yAxisRight = lineChartView.rightAxis
              yAxisRight.labelFont = UIFont(name: "DS-Digital", size: 12.0)!
              let xAxis = lineChartView.xAxis
              xAxis.granularity = 1
              xAxis.drawAxisLineEnabled = true
              xAxis.drawLabelsEnabled = true
              
              lineChartView.data = data
              
              
          }
          
      }
      
      
      

}
