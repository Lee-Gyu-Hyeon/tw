import UIKit
import AVFoundation
import Alamofire

class ScoringViewController: UIViewController {
    
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
    var userfilereceivedValueFromBeforeVC = ""
    
    
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
    var player: AVPlayer?
    var isPlaying = false
    var timer: Timer?
    
    //
    let videoPlayerView = UIView()
    let videoSlider = UISlider()
    let currentTimeLabel = UILabel()
    let videoLengthLabel = UILabel()

    //
    enum Settings {
        static let screenW: CGFloat = 375
        static let playerHeight: CGFloat = Settings.screenW * (9/16)
        static let endpoint = URL(string: "http://download.appboomclap.co.kr/ad/ad_1.mp4")
    }

    //
    var cnt = 0
    var array : [String] = ["a","b","c","d","e","f","g","h"]
    var score : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("-------------------------------------------------------------")
        print("컨텐츠 번호 : \(noreceivedValueFromBeforeVC)")
        print("번호 : \(scopereceivedValueFromBeforeVC)")
        print("댄스파일 : \(dancefilereceivedValueFromBeforeVC)")
        print("제목 : \(titlereceivedValueFromBeforeVC)")
        print("부제목 : \(creatorreceivedValueFromBeforeVC)")
        print("텍스트: \(textreceivedValueFromBeforeVC)")
        print("좋아요 수 : \(numberoflikereceivedValueFromBeforeVC)")
        print("좋아요 체크 : \(checklikereceivedValueFromBeforeVC)")
        print("유저파일 : \(userfilereceivedValueFromBeforeVC)")
        print("-------------------------------------------------------------")

        //
        player?.play()
        
        //
        videoPlayerView.backgroundColor = UIColor.black
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        view.addSubview(videoPlayerView)
        view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
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


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVideoPlayer()
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    func setupVideoPlayer() {
        let url = Settings.endpoint
        
        player = AVPlayer(url: url!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds
        playerLayer.videoGravity = .resizeAspect
        
        videoPlayerView.layer.addSublayer(playerLayer)
        player?.play()
        
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds) % 60)
            let minutesString = String(format: "%02d", Int(seconds) / 60)
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            
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
            isPlaying = true
            
            if let duration = player?.currentItem?.asset.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = String(format: "%02d", Int(seconds) % 60)
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            }
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func handlePause(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying = !isPlaying
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
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
//
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
        let dialog = UIAlertController(title: "채점이 완료되었습니다.\n 결과를 확인하시겠습니까?", message: "", preferredStyle: .alert)
        let okaction = UIAlertAction(title: "예", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
 
            
            
//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
            let _url3 = "http://ruyi-boomclap-elb-1137529646.ap-northeast-2.elb.amazonaws.com:8080/BoomClap/Main"
            let parameters3: Parameters = [
                "protocol": NetworkProtocol().GET_USER_GRADE_REQ,
                "user_file": self.userfilereceivedValueFromBeforeVC,
            ]
            print("채점 파라미터 : ", parameters3)
            
            Alamofire.request(_url3, method: .post, parameters: parameters3).responseJSON { response in
                
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
                    self.score = self.array[2].split {$0 == "#"}.map(String.init)
                    print("1:", self.score)
                    print("2:", "\(self.score[0])")
                    
                    let test = utf8Text.components(separatedBy: ["\r","\n"])
                    print("test:", test)

                    print("--------------요청 프로토콜 : 134--------------------------------")
                    print("요청 프로토콜:",NetworkProtocol().GET_USER_GRADE_REQ)
                    print("요청결과: ", utf8Text)
                    print("점수: ",self.score)
                    print("점수2:", "\(self.score[0])")
                    print("-------------------------------------------------------------")
                    
                    print("-------------------------------------------------------------")
                    print("c1:", self.score)
                    print("c2:", "\(self.score[0])")
                    print("-------------------------------------------------------------")
//---------------------------------------------------------------------------------------------------------------------------------------
                    if self.score[0] == "S" {
                        
                    } else if self.score[0] == "A" {
                        print("Your Score is A")
                    } else if self.score[0] == "B" {
                        print("Your Score is B")
                        
                    } else if self.score[0] == "C" {
                        print("Your Score is C")
                        
                    } else if self.score[0] == "D" {
                        print("Your Score is D")

                    } else if self.score[0] == "F" {
                        print("Your Score is F")

                    } else if self.score[0] == "0" {
                        print("채점이 완료되지 않았습니다.")
                        
                        }
                        
                        dialog.addAction(okaction)
                        self.present(dialog, animated: true, completion: nil)*/
                    }
//---------------------------------------------------------------------------------------------------------------------------------------
                }
            }
//---------------------------------------------------------------------------------------------------------------------------------------
        }
        
        let noaction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.default){ (action: UIAlertAction) -> Void in
            
            //
            let dialog = UIAlertController(title: "취소 되었습니다.", message: "", preferredStyle: .alert)
            let okaction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            
            dialog.addAction(okaction)
            self.present(dialog, animated: true, completion: nil)
            
        }
        
        dialog.addAction(okaction)
        dialog.addAction(noaction)
        
        self.present(dialog, animated: true, completion: nil)
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
    func stopPlayer() {
        if let player = player {
            print("stoped")
            player.pause()
            //player == nil
            print("player deallocated")
        
        } else {
            print("player was already deallocated")
            
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------
}
