import UIKit
import AWSS3
import AWSCognito
import AVFoundation
import SnapKit
import MobileCoreServices
import Alamofire


class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //
    var imagePickers:UIImagePickerController?
    
    //전 화면에서 받은 데이터
    var noreceivedValueFromBeforeVC = ""
    var scopereceivedValueFromBeforeVC = ""
    var dancefilereceivedValueFromBeforeVC = ""
    var titlereceivedValueFromBeforeVC = ""
    var creatorreceivedValueFromBeforeVC = ""
    var textreceivedValueFromBeforeVC = ""
    var numberoflikereceivedValueFromBeforeVC = ""
    var checklikereceivedValueFromBeforeVC = ""
    var downloadedDatareceivedValueFromBeforeVC = ""
    
    //전역변수 설정
    var no: [String] = []
    var scope: [String] = []
    var title1: [String] = []
    var dancefile: [String]!
    var creator: [String] = []
    var text: [String] = []
    var numberoflike: [String] = []
    var checklike: [String] = []
    var downloadedData: [String]!
    
    //
    var topConstraint: Constraint?
    let videoPlayerView = UIView()
    var cameraRecordView = UIView()
    let pausePlayButton = UIButton()
    let videoSlider = UISlider()
    let currentTimeLabel = UILabel()
    let videoLengthLabel = UILabel()
    
    //
    var player: AVPlayer?
    var isPlaying = false
    var timer: Timer?
    
    //
    var contentUrl: URL!
    var s3Url: URL!
    
    //
    var cnt = 0
    var array : [String] = ["a","b","c","d","e","f","g","h"]
    var user_fname: [String] = []
    
    
    //
    enum Settings {
        static let screenW: CGFloat = 375
        static let playerHeight: CGFloat = Settings.screenW * (9/16)
        static let endpoint = URL(string: "http://download.appboomclap.co.kr/content/")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//---------------------------------------------------------------------------------------------------------------------------------------
//AWS 정보
//---------------------------------------------------------------------------------------------------------------------------------------
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APNortheast2, identityPoolId:"ap-northeast-2:a6ccac90-7176-487b-abc3-58185b668df0")
        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = NSURL(string: "https://s3.console.aws.amazon.com/s3/object/boomclap-ruyi") as URL?
//---------------------------------------------------------------------------------------------------------------------------------------
        
        
        
//---------------------------------------------------------------------------------------------------------------------------------------
//카메라 녹화
//---------------------------------------------------------------------------------------------------------------------------------------
        addImagePickerToContainerView()
//---------------------------------------------------------------------------------------------------------------------------------------
        
        
        
//---------------------------------------------------------------------------------------------------------------------------------------
//플레이 카운트다운
//---------------------------------------------------------------------------------------------------------------------------------------
        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
        videoPlayerView.backgroundColor = UIColor.black
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        view.addSubview(videoPlayerView)
        view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//화면 터치 이벤트(터치시 플레이버튼, 슬라이더, 비디오 시간,초가 사라짐)
//---------------------------------------------------------------------------------------------------------------------------------------
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        view.addGestureRecognizer(tapGesture)
//---------------------------------------------------------------------------------------------------------------------------------------
        //
        cameraRecordView.backgroundColor = UIColor.green
        cameraRecordView.isUserInteractionEnabled = true
        cameraRecordView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cameraRecordView)
        
        //
        cameraRecordView.snp.makeConstraints { (make) in
            make.trailing.equalTo(10)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(4)
            make.height.equalToSuperview().dividedBy(4)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-60)
        }

        pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        pausePlayButton.isUserInteractionEnabled = true
        pausePlayButton.translatesAutoresizingMaskIntoConstraints = false
        pausePlayButton.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        self.view.addSubview(pausePlayButton)
        
        //
        pausePlayButton.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalTo(200)
            self.topConstraint = make.centerY.equalTo(self.view).constraint
        }
        
        //
        self.imagePickers?.delegate = self
    }

    //
    open override var shouldAutorotate: Bool {
        return false
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVideoPlayer()
        resetTimer()
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    func setupVideoPlayer() {
        let url = Settings.endpoint.appendingPathComponent(dancefilereceivedValueFromBeforeVC).appendingPathExtension("mp4")
        print("비디오 주소: ", url)
        
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        
        playerLayer.videoGravity = .resizeAspect
        videoPlayerView.layer.addSublayer(playerLayer)
        player?.play()
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//비디오 값에 따라 슬라이더 설정
//---------------------------------------------------------------------------------------------------------------------------------------
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds) % 60)
            let minutesString = String(format: "%02d", Int(seconds) / 60)
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.didfinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)

            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
            }
        })
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            pausePlayButton.isHidden = false
            isPlaying = true
            
            if let duration = player?.currentItem?.asset.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = String(format: "%02d", Int(seconds) % 60)
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func handlePause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .selected)
            
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .selected)
        }
        isPlaying = !isPlaying
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//    @objc func closeButtonTapped(sender: UIButton) {
//        print("close button touch")
//
//        let alert = UIAlertController(title: "강좌를 종료하시겠습니까?", message: "종료하면 저장하지 않은채 종료됩니다.", preferredStyle: .alert)
//        let okaction = UIAlertAction(title: "예", style: UIAlertAction.Style.default){ (action: UIAlertAction) -> Void in
//            let vc = DancePlayViewController()
//            vc.modalPresentationStyle = .overFullScreen
//            self.dismiss(animated: true, completion: nil)
//            self.stopPlayer()
//        }
//
//        let noaction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.default){ (action: UIAlertAction) -> Void in
//
//        }
//
//        alert.addAction(okaction)
//        alert.addAction(noaction)
//
//        self.present(alert, animated: true)
//    }
//---------------------------------------------------------------------------------------------------------------------------------------
//    @objc func closeButtonTapped(sender: UIButton) {
//        let volumeView = MPVolumeView(frame: videoPlayerView.bounds)
//        videoPlayerView.addSubview(volumeView)
//    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func handleSliderChange(_ sender:UISlider) {
        print(videoSlider.value)
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                
            })
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//비디오 슬라이더가 끝났을 때 발생되는 이벤트
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func didfinishPlaying(note : NSNotification)  {
        pausePlayButton.setImage(UIImage(named: "play"), for: .normal)

        let alert = UIAlertController(title: "영상 정보를 업데이트 중입니다.", message: "잠시만 기다려 주세요.", preferredStyle: .alert)
        self.present(alert, animated: true, completion: {
            
            let _url = "http://ruyi-boomclap-elb-1137529646.ap-northeast-2.elb.amazonaws.com:8080/BoomClap/Main"
            let parameters: Parameters = [
                "user_id": UserDefaults.standard.string(forKey: "loginID")!,
                "content_no": self.noreceivedValueFromBeforeVC,
                "title": self.titlereceivedValueFromBeforeVC,
                "protocol": NetworkProtocol().UPLOAD_VID_REQ,
            ]
            print("parameters:", parameters)
            
            Alamofire.request(_url, method: .post, parameters: parameters).responseJSON { response in
                
                //Error Code
                let status = response.response!.statusCode
                print("STATUS\(status)")
                print("상태코드:", status)
                
                if response.result.value != nil {

                }

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    let utf8text = "\(utf8Text)"
                    for utf8text in utf8text.components(separatedBy: .newlines) {
                        self.array[self.cnt] = utf8text
                        self.cnt += 1
                    }
                    self.user_fname = self.array[2].split  {$0 == "#"}.map(String.init)
                    print("--------------요청 프로토콜 : 122--------------------------------")
                    print("요청 프로토콜:",NetworkProtocol().UPLOAD_VID_REQ)
                    print("요청결과: ", utf8Text)
                    print("유저파일: ",self.user_fname)
                    print("-------------------------------------------------------------")
                    
                    print("-------------------------------------------------------------")
                    print("c1:", self.user_fname)
                    print("-------------------------------------------------------------")
                    
                    let test = utf8Text.components(separatedBy: ["\r","\n"])
                    print("test:", test)
                    
                    print("--------------요청 프로토콜 : 122--------------------------------")
                    print("요청 프로토콜:",NetworkProtocol().UPLOAD_VID_REQ)
                    print("컨텐츠 번호:",self.noreceivedValueFromBeforeVC)
                    print("아이디:",UserDefaults.standard.string(forKey: "loginID")!)
                    print("제목:",self.titlereceivedValueFromBeforeVC)
                    print("-------------------------------------------------------------")
                }
            }

        })
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
            
            
            
            
            let alert = UIAlertController(title: "영상을 서버에 업로드 중입니다.", message: "잠시만 기다려 주세요.", preferredStyle: .alert)
            self.imagePickers?.stopVideoCapture()
            
            self.present(alert, animated: true, completion: nil)
            
            let when = DispatchTime.now() + 10
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
                
                
                
                
                let alert = UIAlertController(title: "영상 썸네일을 생성중입니다.", message: "잠시만 기다려 주세요.", preferredStyle: .alert)
                self.present(alert, animated: true, completion: {
                    
                    
                    
                    //
                    let _url2 = "http://www.appboomclap.co.kr:8080/BoomClap/Grade"
                    let parameters2: Parameters = [
                        "user_no": UserDefaults.standard.string(forKey: "userno")!,
                        "user_file": "\(self.user_fname[0])",
                        "content_name": self.dancefilereceivedValueFromBeforeVC,
                        "protocol": NetworkProtocol().CREATE_VID_THUMBNAIL_REQ,
                    ]
                    print("컨텐츠 파라미터 : ", parameters2)
                    
                    Alamofire.request(_url2, method: .post, parameters: parameters2).responseJSON { response in
                        if response.result.value != nil {
                            
                        }
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            print("--------------요청 프로토콜 : 128-------------------------------")
                            print("요청 프로토콜:",NetworkProtocol().CREATE_VID_THUMBNAIL_REQ)
                            print("요청결과: ", utf8Text)
                            print("요청결과: \(utf8Text)")
                            print("-------------------------------------------------------------")
                            
                            let utf8text = "\(utf8Text)"
                            print(utf8text)
                            var cnt = 0
                            var array : [String] = ["a","b","c","d","e","f","g","h"]
                            
                            for utf8text in utf8text.components(separatedBy: .newlines) {
                                array[cnt] = utf8text
                                cnt += 1
                            }
                            
                            print("--------------요청 프로토콜 : 128-------------------------------")
                            print("요청 프로토콜:",NetworkProtocol().CREATE_VID_THUMBNAIL_REQ)
                            print("요청결과: ", utf8Text)
                            print("요청결과: \(utf8Text)")
                            print("-------------------------------------------------------------")
                        }
                    }
                    //
                    
                    
                    
                })

                let when = DispatchTime.now() + 5
                DispatchQueue.main.asyncAfter(deadline: when){
                  alert.dismiss(animated: true, completion: nil)
                    
                    
                    
//---------------------------------------------------------------------------------------------------------------------------------------
                    let dialog = UIAlertController(title: "업로드가 완료되었습니다.", message: "채점을 진행하시겠습니까?", preferredStyle: .alert)
                    let okaction = UIAlertAction(title: "예", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
                        
                        let vc = ScoringViewController()
                        vc.modalPresentationStyle = .fullScreen
                        
                        vc.noreceivedValueFromBeforeVC = self.noreceivedValueFromBeforeVC
                        vc.scopereceivedValueFromBeforeVC = self.scopereceivedValueFromBeforeVC
                        vc.dancefilereceivedValueFromBeforeVC = self.dancefilereceivedValueFromBeforeVC
                        vc.titlereceivedValueFromBeforeVC = self.titlereceivedValueFromBeforeVC
                        vc.creatorreceivedValueFromBeforeVC = self.creatorreceivedValueFromBeforeVC
                        vc.textreceivedValueFromBeforeVC = self.textreceivedValueFromBeforeVC
                        vc.numberoflikereceivedValueFromBeforeVC = self.numberoflikereceivedValueFromBeforeVC
                        vc.checklikereceivedValueFromBeforeVC = self.checklikereceivedValueFromBeforeVC
                        vc.downloadedDatareceivedValueFromBeforeVC = self.downloadedDatareceivedValueFromBeforeVC
                        vc.userfilereceivedValueFromBeforeVC = "\(self.user_fname[0])"
                        
                        print("-------------------------------------------------------------")
                        print("1:", self.noreceivedValueFromBeforeVC)
                        print("2:", self.scopereceivedValueFromBeforeVC)
                        print("3:", self.dancefilereceivedValueFromBeforeVC)
                        print("4:", self.titlereceivedValueFromBeforeVC)
                        print("5:", self.creatorreceivedValueFromBeforeVC)
                        print("6:", self.textreceivedValueFromBeforeVC)
                        print("7:", self.numberoflikereceivedValueFromBeforeVC)
                        print("8:", self.creatorreceivedValueFromBeforeVC)
                        print("9:", self.downloadedDatareceivedValueFromBeforeVC)
                        print("-------------------------------------------------------------")
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    let noaction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
                        
                        //
                        let dialog = UIAlertController(title: "채점이 취소 되었습니다.", message: "", preferredStyle: .alert)
                        let okaction = UIAlertAction(title: "예", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
                            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                        
                        dialog.addAction(okaction)
                        self.present(dialog, animated: true, completion: nil)
                        
                    }
                    
                    dialog.addAction(okaction)
                    dialog.addAction(noaction)
                    
                    self.present(dialog, animated: true, completion: nil)
                }
            }
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------

    
//---------------------------------------------------------------------------------------------------------------------------------------
//플레이 카운트다운
//---------------------------------------------------------------------------------------------------------------------------------------
//    @objc func updateCounter() {
//        if counter > 0 {
//            print("\(counter)")
//            player?.pause()
//            counter -= 1
//            countdownLabel.text = ("\(counter) 초 후 영상 시작")
//
//        } else {
//            player?.play()
//        }
//    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
//비디오 재생중 닫기 버튼을 누를시 재생값 초기화
//---------------------------------------------------------------------------------------------------------------------------------------
    func stopPlayer() {
        if let player = player {
            print("stoped")
            player.pause()
            print("player deallocated")
        
        } else {
            print("player was already deallocated")
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
//재생 뒤 10초가 지나면 발생되는 이벤트
//---------------------------------------------------------------------------------------------------------------------------------------
    func resetTimer() {
    }
    
    //재생 뒤 10초가 지나면 발생되는 이벤트
    @objc func hideControls() {
        pausePlayButton.isHidden = true
        videoSlider.isHidden = true
        videoLengthLabel.isHidden = true
        currentTimeLabel.isHidden = true
    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func toggleControls() {
        pausePlayButton.isHidden = !pausePlayButton.isHidden
        videoSlider.isHidden = !videoSlider.isHidden
        videoLengthLabel.isHidden = !videoLengthLabel.isHidden
        currentTimeLabel.isHidden = !currentTimeLabel.isHidden
        resetTimer()
    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
//카메라 녹화
//---------------------------------------------------------------------------------------------------------------------------------------
    func addImagePickerToContainerView() {
        imagePickers = UIImagePickerController()
        
        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.front) {
            imagePickers?.sourceType = UIImagePickerController.SourceType.camera
            addChild(imagePickers!)

            self.cameraRecordView.addSubview((imagePickers?.view)!)
            imagePickers?.delegate = self
            imagePickers?.view.frame = cameraRecordView.bounds
            imagePickers?.allowsEditing = false
            imagePickers?.showsCameraControls = false
            imagePickers?.cameraViewTransform = CGAffineTransform(scaleX: 5, y: 5)
        }
        
        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear) {
            imagePickers?.mediaTypes = ["public.movie"]
            imagePickers?.cameraCaptureMode = .video
            imagePickers?.view.frame = cameraRecordView.bounds
            imagePickers?.cameraDevice = .front
            
            //녹화시작 딜레이
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                self.imagePickers?.startVideoCapture()
                print("녹화 시작")
            })
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
    
    
//---------------------------------------------------------------------------------------------------------------------------------------
//동영상 촬영 후 바로 S3에 업로드
//---------------------------------------------------------------------------------------------------------------------------------------
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let newKey = "\(self.user_fname[0]).mp4"

        let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = videoUrl! as URL
        uploadRequest?.key = newKey
        uploadRequest?.bucket = "boomclap-ruyi/" + "user/" + "\(UserDefaults.standard.string(forKey: "userno")!)"
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
        uploadRequest?.contentType = "video/mp4"
        uploadRequest?.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            DispatchQueue.main.async(execute: {
                let amountUploaded = totalBytesSent
                print(amountUploaded)
            })
        }

        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task) in
            if task.error != nil {
                print(task.error.debugDescription)

            } else {
                print("video upload success")

            }
            return nil
        })
    }
//---------------------------------------------------------------------------------------------------------------------------------------
}
