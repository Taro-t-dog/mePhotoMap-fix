//
//  ViewController.swift
//  mePhotoMap
//
//  Created by 瀬川太朗 on 2022/05/22.
//

import UIKit
import MapKit
import CoreLocationUI
import RealmSwift
//import SwiftUI
class ViewController: UIViewController , CLLocationManagerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,MKMapViewDelegate{
    let realm = try! Realm()
    @IBOutlet var contentView: UIView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var locationButton: UIButton!
    let dt = Date()
    let dateFormatter = DateFormatter()
    var dateString:String = ""
    var photoInfoArray : [PhotoInfo] = []
    var selectedPhotoInfo:PhotoInfo?
    var selectedErase: PhotoInfo?
  
    
    
    
    var locationManager:CLLocationManager!
    
    
    var didStartUpdatingLocation = false
    var searchMapItems:[MKMapItem] = []
    var currentLocation:CLLocation!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.imageView?.contentMode = .scaleAspectFill
        locationButton.layer.cornerRadius = 8.0
        cameraButton.contentHorizontalAlignment = .fill
        cameraButton.contentVerticalAlignment = .fill
        locationButton.imageView?.contentMode = .scaleToFill
        locationButton.contentVerticalAlignment = .fill
        locationButton.contentHorizontalAlignment = .fill
        
        self.mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //        createLocationButton()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        initLocation()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        showPins()
        
        print(selectedErase)
        
    }
    
    //    private func createLocationButton() {
    //        let button = CLLocationButton(frame: CGRect(x:0,
    //                                                    y:0,
    //                                                    width:self.view.frame.width/12,
    //                                                    height:40))
    //        button.layer.cornerRadius = 8.0
    //
    //        button.icon = .arrowFilled
    //        button.center  = CGPoint(x: view.center.x + 100, y: view.center.y + 300)
    //        button.cornerRadius = 20.0
    //        self.view.addSubview(button)
    //        button.addTarget(self, action: #selector(requestCurrentLocation), for: .touchUpInside)
    //
    //
    //    }
    @IBAction func requestCurrentLocation() {
        self.locationManager.startUpdatingLocation()
    }
    private func initLocation() {
        if !CLLocationManager.locationServicesEnabled() {
            print("NO location service")
            return
        }
        switch CLLocationManager.authorizationStatus(){
        case.notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
            
        case .restricted,.denied:
            showPermissionAlert()
            
        case .authorizedAlways,.authorizedWhenInUse:
            if !didStartUpdatingLocation{
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        @unknown default:
            break
        }
        
        
    }
    private func showPermissionAlert(){
        let alert = UIAlertController(title: "位置情報の取得",
                                      message: "設定アプリから位置情報の使用を許可してください",
                                      preferredStyle: .alert)
        let goToSetting = UIAlertAction(title: "設定アプリを開く", style: .default) { _ in
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingUrl){
                UIApplication.shared.open(settingUrl,completionHandler: nil)
            }
            
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel){ (_) in
            self.dismiss(animated: true,completion: nil)
            
        }
        alert.addAction(goToSetting)
        
        alert.addAction(cancelAction)
        
        self.present(alert,animated: true,completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if !didStartUpdatingLocation{
                didStartUpdatingLocation = true
                locationManager.startUpdatingLocation()
            }
        }else if status == .restricted || status == .denied {
            showPermissionAlert()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's")
    }
    
    private func updateMap(){
        
        print("Location:\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)")
        let now = Date()
        let delta = now.timeIntervalSince(currentLocation.timestamp)
        print("This location was obtained \(delta)second ago")
        if delta > 70{
            print("too old")
            return
        }
        
        let horizontalRegionInaMeters: Double = 5000
        let width = self.mapView.frame.width
        let height = self.mapView.frame.height
        let verticalRegionInMeters = Double(height / width * CGFloat(horizontalRegionInaMeters))
        
        let region:MKCoordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                                           latitudinalMeters:  verticalRegionInMeters,
                                                           longitudinalMeters: horizontalRegionInaMeters)
        mapView.setRegion(region, animated: true)
        
    }
    
    private func showPins(){
        mapView.removeAnnotations(mapView.annotations)
        photoInfoArray = Array(realm.objects(PhotoInfo.self))
        
        
        
        for photoInfo in photoInfoArray {
            let longtitude = photoInfo.longtitude
            let latitude = photoInfo.latitude
            
            guard let longtitude = longtitude as? CLLocationDegrees , let  latitude = latitude as? CLLocationDegrees  else  {return}
            
            let  annotation = PhotoInfoAnnotation(photoInfo: photoInfo)
            
            annotation.coordinate = CLLocationCoordinate2DMake (latitude,longtitude)
            
            
            
            
            mapView.addAnnotation(annotation)
            
            
            
            
            
        }
        
        
        
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation  as? PhotoInfoAnnotation {
            selectedPhotoInfo = annotation.photoInfo
            //            let createdAt = selectedPhotoInfo?.createdAt
            //            let longtitude = selectedPhotoInfo?.longtitude
            //            let latitude = selectedPhotoInfo?.latitude
            //            let imageFileName = selectedPhotoInfo?.imageFileName
            //
            
            
            performSegue(withIdentifier: "ToInfo", sender:nil)
        }
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToInfo" {
            //            let data: (date: String , lat:CLLocationDegrees , log: CLLocationDegrees , imFileName: String ) = sender as? (String, CLLocationDegrees, CLLocationDegrees, String),
            
            let nextView = segue.destination  as? InfoViewController
            
            nextView?.recievedLatitude = selectedPhotoInfo!.latitude
            nextView?.recievedLongitude = selectedPhotoInfo!.longtitude
            //            nextView.photoInfo.createdAt =
            //            nextView.photoInfo.longtitude = data.log
            //            nextView.photoInfo.latitude = data.lat
            //            nextView.photoInfo.imageFileName = data.imFileName
        }
    }
    
    
    
    
    func presentPickerController(sourceType:UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            self.present(picker,animated: true,completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return picker.dismiss(animated: true) }
        let photoInfo = PhotoInfo()
        let imageURLStr =   saveImage(image: image)
        photoInfo.imageFileName = imageURLStr
        photoInfo.createdAt = dateString
        photoInfo.latitude = currentLocation.coordinate.latitude
        photoInfo.longtitude = currentLocation.coordinate.longitude
        print(photoInfo.createdAt)
        print( photoInfo.imageFileName)
        print( photoInfo.latitude)
        print( photoInfo.longtitude)
        
        try!realm.write({
            realm.add(photoInfo)
        })
        
        picker.dismiss(animated: true)
        
        print( realm.objects(PhotoInfo.self))
        
        
    }
    func dateGet() -> String{
        
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: Date())
        print(dateString)
        
        
        
        
        print(dateFormatter.string(from: dt))
        return dateString
    }
    
    
    @IBAction func onTappedCameraButton(_ sender: Any) {
        presentPickerController(sourceType: .camera)
        updateMap()
        _ =  dateGet()
        
        
        
    }
    
    //    func saveLocationLatitude() {
    //        guard let  nowLatitude = currentLocation.coordinate.latitude else {return}
    //        let photoInfo = PhotoInfo()
    //        photoInfo.latitude = nowLatitude
    //        try! realm.write({
    //            realm.add(photoInfo)
    //        })
    //
    //
    //
    //    }
    //    func saveLocationLongitude() {
    //
    //    }
    //
    //
    
    
    func saveImage(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        do {
            let fileName = UUID().uuidString + ".jpeg" // ファイル名を決定(UUIDは、ユニークなID)
            let imageURL = getImageURL(fileName: fileName) // 保存先のURLをゲット
            try imageData.write(to: imageURL) // imageURLに画像を書き込む
            return fileName
        } catch {
            print("Failed to save the image:", error)
            return nil
        }
    }
    func getImageURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    
    
//    @IBAction func firstViewiewSegue(segue: UIStoryboardSegue) {
//       
//
//    }
    
//    func removeAnnotation() {
//        guard let selectedErase = selectedErase  else  {return}
//        let selected = Array(realm.objects(PhotoInfo.self)).filter{$0.latitude == selectedErase.latitude && $0.longtitude == selectedErase.longtitude}.first
//        if let selected = selected {
//            let  annotation = PhotoInfoAnnotation(photoInfo:selected )
//            mapView.removeAnnotation(annotation)
//        }
//
//    }
    
    
    
    
    
    
    
    
}
extension ViewController  {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])  {
        guard let location = locations.first else {return  }
        locationManager.stopUpdatingLocation()
        currentLocation = location
        var region: MKCoordinateRegion = mapView.region
        region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        mapView.setRegion(region, animated: true)
        
        
    }
    
    
}
//extension ViewController {



//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//           //アノテーションビューを作成する。
//           let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
//
//           //吹き出しを表示可能に。
//           pinView.canShowCallout = true
//
//           let button = UIButton()
//           button.frame = CGRect(x:0,y:0,width:40,height:40)
//           button.setTitle("OK", for: .normal)
//           button.setTitleColor(UIColor.white, for: .normal)
//           button.backgroundColor = UIColor.blue
//           button.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
//           //右側にボタンを追加
//           pinView.rightCalloutAccessoryView = button
//           return pinView
//       }
//
//       //OKボタン押下時の処理
//    @objc func sendLocation(){
//        performSegue(withIdentifier: "ToInfo", sender: nil)
//
//      }
//
//}




