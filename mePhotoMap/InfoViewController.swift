//
//  InfoViewController.swift
//  mePhotoMap
//
//  Created by 瀬川太朗 on 2022/05/22.
//

import UIKit
import  MapKit
import RealmSwift
class InfoViewController: UIViewController {
    let realm = try! Realm()
    var photoInfo: PhotoInfo?
    var recievedLatitude: Double = 0.0
    var recievedLongitude: Double = 0.0
    
    @IBOutlet weak var haikei1UIView: UIView!
    
    @IBOutlet weak var haikei2UIView: UIView!
    @IBOutlet weak var gazou1ImageView: UIImageView!
    
    @IBOutlet weak var day1Label: UILabel!
    
    @IBOutlet weak var ad1Label: UILabel!
    @IBOutlet var shareView: UIView!
    @IBOutlet var trashView: UIView!
    
    
    @IBOutlet weak var lat1Label: UILabel!
    
    @IBOutlet weak var long1Label: UILabel!
    
    
    var zyusyoString:String = "T"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareView.layer.cornerRadius = 10.0
        trashView.layer.cornerRadius = 10.0
        haikei1UIView.layer.cornerRadius = haikei1UIView.frame.height * 0.1
        haikei2UIView.layer.cornerRadius = haikei2UIView.frame.height * 0.1
        //getInfoData()
//        haikei1ImageView.layer.cornerRadius = haikei1ImageView.frame.height * 0.1
        let selected = Array(realm.objects(PhotoInfo.self)).filter{$0.latitude == recievedLatitude && $0.longtitude == recievedLongitude}.first
        if let selected = selected {
            photoInfo = selected
            let lat = floor(selected.latitude*100)/100
            lat1Label.text = String(lat)
            let long = floor(selected.longtitude*100)/100
            long1Label.text = String(long)
            ad1Label.text = convert(latitude: selected.latitude, longtitude: selected.longtitude)
            day1Label.text = selected.createdAt
            getImage()
        }
        
    }
    
    func convert(latitude: CLLocationDegrees, longtitude: CLLocationDegrees) -> String? {
        guard let longtitude = photoInfo?.longtitude,
              let latitude = photoInfo?.latitude else { return nil }
        
        let geocorder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longtitude)
        
        geocorder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let placeMark = placeMarks?.first {
                print("###", placeMark.postalCode, placeMark.name)
                self.zyusyoString = """
                　　\(placeMark.postalCode ?? "検出不可")
                　　\(placeMark.administrativeArea ?? "検出不可")\(placeMark.locality ?? "検出不可")
                　　\(placeMark.thoroughfare ?? "検出不可")\(placeMark.subThoroughfare ?? "検出不可")
                """
                self.ad1Label.text = self.zyusyoString
            }
        }
        
        return zyusyoString
        
    }
    
    func getImage() {
        if let imageFileName = photoInfo?.imageFileName {
            let path = getImageURL(fileName: imageFileName).path // 画像のパスを取得
            if FileManager.default.fileExists(atPath: path) { // pathにファイルが存在しているかチェック
                if let imageData = UIImage(contentsOfFile: path) { // pathに保存されている画像を取得
                    gazou1ImageView.image = imageData
                } else {
                    print("##Failed to load the image. path = ", path)
                }
            } else {
                print("##Image file not found. path = ", path)
            }
        }
        
    }
    
    func getImageURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    @IBAction func onTapShare() {
        if gazou1ImageView.image != nil {
            let activityVC = UIActivityViewController(activityItems: [gazou1ImageView.image!,"#mePhotoMap"], applicationActivities: nil)
            self.present(activityVC,animated: true,completion: nil)
        }else{
            print("画像がありません")
        }
    }
    
    @IBAction func onTapDelete() {
        
        let selected = Array(realm.objects(PhotoInfo.self)).filter{$0.latitude == recievedLatitude && $0.longtitude == recievedLongitude}.first
        


        if let selected = selected {
            do{
                
                try realm.write{
                    realm.delete(selected)
                }
            }catch {
                print("Error \(error)")
            }
        }

        
           
            
            
        self.navigationController?.popViewController(animated: true)
            
            
            
            
        }
        
    }
    
    
    
    
    
    
    //        longtitudeLabel?.text = ("北\(photoInfo.longtitude)")
    //        latitudeLabel?.text = ("東\(photoInfo.latitude)")
    //        dateLabel?.text = photoInfo.createdAt
    // Do any additional setup after loading the view.
    
    
    
    
    
    
    




/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 
 */



