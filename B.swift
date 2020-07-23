import UIKit
import Alamofire
import AVFoundation

struct AVPlayerQueueBuilder {
    static func from(_ urls: [URL]) -> [AVPlayerItem] {
        return urls.map { return AVPlayerItem(url: $0) }
    }
}

class DancePlayViewController: UIViewController {

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
    var isPlaying = false
    var isFinFirst = false
    
    //
    var playerItem : AVPlayerItem!

    //
    var seconds = 6
    var timer:Timer?
    var isTimerRunning = false
    var resumeTapped = false
    
    //
    @objc lazy var player: AVQueuePlayer? = {
        var items = AVPlayerQueueBuilder.from(videoUrls)
        var player = AVQueuePlayer(items: items)
        return player
    }()
    
    //
    var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resize.rawValue)
        layer.needsDisplayOnBoundsChange = true
        return layer
    }()
    
    //광고
    var videoUrls = [
        URL(string: "http://download.appboomclap.co.kr/ad/ad_1.mp4")!,
    ]

    //
    enum Settings {
        static let screenW: CGFloat = 375
        static let playerHeight: CGFloat = Settings.screenW * (9/16)
        static let endpoint = URL(string: "http://download.appboomclap.co.kr/content/")!
    }

    //로딩
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.isUserInteractionEnabled = true
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    //??뷰
    let playerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    
    //??뷰
    let progressView: UIView = {
        let prov = UIView()
        prov.translatesAutoresizingMaskIntoConstraints = false
        prov.backgroundColor = UIColor(red: 248/255, green: 182/255, blue: 156/255, alpha: 0.7)
        return prov
    }()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    //
    lazy var rePlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.isHidden = true
        button.addTarget(self, action: #selector(replayButtonWasPressed), for: .touchUpInside)
        return button
    }()
    
    //비디오 슬라이더
    let videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor(red: 255/255, green: 104/255, blue: 99/255, alpha: 1.0)
        slider.isUserInteractionEnabled = true
        slider.maximumTrackTintColor = .white
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    //
    var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.isUserInteractionEnabled = true
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    //
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .black
        //label.textColor = .white
        label.isUserInteractionEnabled = true
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    //
    let titlelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "title"
        label.isUserInteractionEnabled = true
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    //
    let subtitlelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "subtitle"
        label.isUserInteractionEnabled = true
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    //
    let skipbutton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 57/255, green: 57/255, blue: 57/255, alpha: 0.5)
        button.layer.borderWidth = 1.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.borderColor = UIColor.clear.cgColor
        button.isHidden = true
        button.isEnabled = false
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(skipbuttonAction), for: .touchUpInside)
        return button
    }()
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("-------------------------------------------------------------")
        print("컨텐츠 번호 : \(noreceivedValueFromBeforeVC)")
        print("번호 : \(scopereceivedValueFromBeforeVC)")
        print("댄스파일 : \(dancefilereceivedValueFromBeforeVC)")
        
        titlelabel.text = titlereceivedValueFromBeforeVC
        print("제목 : \(titlereceivedValueFromBeforeVC)")
        
        subtitlelabel.text = creatorreceivedValueFromBeforeVC
        print("부제목 : \(creatorreceivedValueFromBeforeVC)")
        print("텍스트: \(textreceivedValueFromBeforeVC)")

        print("좋아요 수 : \(numberoflikereceivedValueFromBeforeVC)")
        print("좋아요 체크 : \(checklikereceivedValueFromBeforeVC)")
        print("-------------------------------------------------------------")
        
        //
        view.backgroundColor = .white
        
        //
        navigationItem.title = "춤추기"
        navigationController?.navigationBar.isTranslucent = false
        
        //
        view.addSubview(playerView)
        view.addSubview(activityIndicatorView)
        view.addSubview(pausePlayButton)
        view.addSubview(rePlayButton)
        view.addSubview(progressView)
        
        //
        progressView.addSubview(videoLengthLabel)
        progressView.addSubview(currentTimeLabel)
        progressView.addSubview(videoSlider)
        
        //
        view.addSubview(titlelabel)
        view.addSubview(subtitlelabel)
        view.addSubview(skipbutton)
        
        //댄스영상
        let url = Settings.endpoint.appendingPathComponent(dancefilereceivedValueFromBeforeVC).appendingPathExtension("mp4")
        print("비디오 주소1: ", url)
        videoUrls.append(url)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        setupPlayerView()
        player?.play()
        
        pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        runTimer()
        
        //
        let loginbutton = UIButton()
        loginbutton.setTitle("춤추기", for: .normal)
        loginbutton.setTitleColor(UIColor.white, for: .normal)
        loginbutton.backgroundColor = UIColor(red: 255/255, green: 104/255, blue: 99/255, alpha: 1.0)
        loginbutton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginbutton.addTarget(self, action: #selector(self.pressed), for: .touchUpInside)
        self.view.addSubview(loginbutton)
        
        loginbutton.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.height.equalTo(55)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //
    private func setupPlayerView() {
        
        //
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
        ])
        
        //
        NSLayoutConstraint.activate([
            pausePlayButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            pausePlayButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            pausePlayButton.widthAnchor.constraint(equalToConstant: 50),
            pausePlayButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        //
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerView.heightAnchor.constraint(equalToConstant: Settings.playerHeight),
        ])
        
        //
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: playerView.leftAnchor),
            progressView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 40),
            progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 60),
            progressView.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        //총 시간
        NSLayoutConstraint.activate([
            videoLengthLabel.rightAnchor.constraint(equalTo: progressView.rightAnchor, constant: -8),
            videoLengthLabel.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -8),
            videoLengthLabel.widthAnchor.constraint(equalToConstant: 60),
            videoLengthLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        //이동시간
        NSLayoutConstraint.activate([
            currentTimeLabel.leftAnchor.constraint(equalTo: progressView.leftAnchor, constant: 8),
            currentTimeLabel.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -8),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 60),
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        //비디오 슬라이더
        NSLayoutConstraint.activate([
            videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor, constant: -8),
            videoSlider.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -8),
            videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor),
            videoSlider.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        //제목
        NSLayoutConstraint.activate([
            titlelabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 20),
            titlelabel.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 90),
        ])
        
        //부제목
        NSLayoutConstraint.activate([
            subtitlelabel.leftAnchor.constraint(equalTo: playerView.leftAnchor, constant: 20),
            subtitlelabel.bottomAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 28),
        ])
        
        //스킵버튼
        NSLayoutConstraint.activate([
            skipbutton.rightAnchor.constraint(equalTo: view.rightAnchor),
            skipbutton.topAnchor.constraint(equalTo: progressView.topAnchor, constant: -37),
            skipbutton.widthAnchor.constraint(equalToConstant: 115),
            skipbutton.heightAnchor.constraint(equalToConstant: 37),
        ])
        
        //
        NSLayoutConstraint.activate([
            rePlayButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            rePlayButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            rePlayButton.widthAnchor.constraint(equalToConstant: 50),
            rePlayButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        
//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
        playerView.layer.addSublayer(playerLayer)
        playerLayer.player = player
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//비디오 로딩이 끝나면 일시정지 버튼으로 변경됨
//---------------------------------------------------------------------------------------------------------------------------------------
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
//---------------------------------------------------------------------------------------------------------------------------------------
        

//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
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
//
//---------------------------------------------------------------------------------------------------------------------------------------
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
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
//
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func handleSliderChange(_ sender: UISlider) {
        //print(videoSlider.value)
        
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
    @objc func handlePause(_ sender: UIButton) {
        
        //
        if self.resumeTapped == false {
            timer?.invalidate()
            self.resumeTapped = true
        
        } else {
            runTimer()
            self.resumeTapped = false
        }
        
        //
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            print("일시정지 버튼 클릭")
            
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
            print("재생 버튼 클릭")
        }
        isPlaying = !isPlaying
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(DancePlayViewController.update)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func playerDidFinishPlaying(notification: NSNotification) {
        if self.isFinFirst {
            pausePlayButton.isHidden = true
            rePlayButton.setImage(UIImage(named: "replay"), for: .normal)
            rePlayButton.isHidden = false
            print("댄스 영상 끝")
            
        } else {
            self.isFinFirst = true
            skipbutton.isHidden = true
            print("댄스 영상 시작")
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func replayButtonWasPressed(_ sender: UIButton) {
        rePlayButton.isHidden = true
        pausePlayButton.isHidden = false
        print("리플레이 버튼 클릭")
        
        playerItem = nil
        let playerI = AVPlayerItem.init(url: NSURL.init(string: "http://download.appboomclap.co.kr/content/\(dancefilereceivedValueFromBeforeVC).mp4")! as URL)
        player?.replaceCurrentItem(with: playerI)
        playerItem = playerI
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        player?.play()
        
        if self.isFinFirst {
            print("댄스 영상 리플레이 시작")
            
        } else {
            print("댄스 영상 리플레이 끝")
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------
    
//---------------------------------------------------------------------------------------------------------------------------------------
//춤추기 버튼 클릭 이벤트 //_ sender: Any
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func pressed(_ sender: UIButton) {
        print("춤추기 버튼 클릭")
        
        //
        let vc = MainViewController()
        vc.modalPresentationStyle = .fullScreen
        
        //
        vc.noreceivedValueFromBeforeVC = noreceivedValueFromBeforeVC
        vc.scopereceivedValueFromBeforeVC = scopereceivedValueFromBeforeVC
        vc.dancefilereceivedValueFromBeforeVC = dancefilereceivedValueFromBeforeVC
        vc.titlereceivedValueFromBeforeVC = titlereceivedValueFromBeforeVC
        vc.creatorreceivedValueFromBeforeVC = creatorreceivedValueFromBeforeVC
        vc.textreceivedValueFromBeforeVC = textreceivedValueFromBeforeVC
        vc.numberoflikereceivedValueFromBeforeVC = numberoflikereceivedValueFromBeforeVC
        vc.checklikereceivedValueFromBeforeVC = checklikereceivedValueFromBeforeVC
        vc.downloadedDatareceivedValueFromBeforeVC = downloadedDatareceivedValueFromBeforeVC
        
        //
        print("-------------------------------------------------------------")
        print("컨텐츠 번호 : \(noreceivedValueFromBeforeVC)")
        print("번호 : \(scopereceivedValueFromBeforeVC)")
        print("댄스파일 : \(dancefilereceivedValueFromBeforeVC)")
        print("제목 : \(titlereceivedValueFromBeforeVC)")
        print("부제목 : \(creatorreceivedValueFromBeforeVC)")
        print("텍스트: \(textreceivedValueFromBeforeVC)")
        
        //
        UserDefaults.standard.string(forKey: "loginID")
        print("아이디:", UserDefaults.standard.string(forKey: "loginID")!)
        print("-------------------------------------------------------------")
        
        //
        self.present(vc, animated: true)
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerView.bounds
    }
//---------------------------------------------------------------------------------------------------------------------------------------
  

//---------------------------------------------------------------------------------------------------------------------------------------
//광고 Skip 버튼 이벤트
//---------------------------------------------------------------------------------------------------------------------------------------
    @objc func update() {
        if (seconds > 1) {
            seconds -= 1
            skipbutton.isHidden = false
            skipbutton.setTitle("\(seconds)" + "초 후 Skip", for: .normal)
            skipbutton.setTitleColor(UIColor.white, for: .normal)
            
        } else if (seconds == 1) {
            skipbutton.setTitle("광고 건너뛰기", for: .normal)
            skipbutton.setTitleColor(UIColor.white, for: .normal)
            skipbutton.isEnabled = true
        }
    }
//---------------------------------------------------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------------------------------------------------
//Skip 버튼 클릭 이벤트
    @objc func skipbuttonAction(sender: UIButton) {
        print("Skip 버튼 클릭")
        
        let url = Settings.endpoint.appendingPathComponent(dancefilereceivedValueFromBeforeVC).appendingPathExtension("mp4")
        player?.advanceToNextItem()
        player?.play()
        skipbutton.isHidden = true
        
        if self.isFinFirst {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            isPlaying = !isPlaying
            
        } else {
            self.isFinFirst = true
        }
        print("비디오 주소 : ", url)
    }
}
//---------------------------------------------------------------------------------------------------------------------------------------
