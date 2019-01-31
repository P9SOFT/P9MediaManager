//
//  ViewController.swift
//  Sample
//
//  Created by Tae Hyun Na on 2019. 1. 4.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var playerView: P9MediaView!
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var controlContainerView: UIView!
    @IBOutlet weak var mediaTableView: UITableView!
    @IBOutlet weak var volumnLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressBackgroundView: UIView!
    @IBOutlet weak var progressThumbLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    let customKeyPlaying = "playing"
    let customKeySeeking = "seeking"
    let volumnBarSize:CGSize = CGSize(width: 30, height: 180)
    
    let volumnBarView:UIView = UIView(frame: .zero)
    var mediaUrls:[URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.p9MediaManagerNotificationHandler(notification:)), name: .P9MediaManager, object: nil)
        
        mediaUrls.append(Bundle.main.url(forResource: "local_video", withExtension: "mp4")!)
        mediaUrls.append(URL(string: "https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_10mb.mp4")!)
        mediaUrls.append(URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        mediaUrls.append(URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!)
        mediaUrls.append(URL(string: "http://www.streambox.fr/playlists/test_001/stream.m3u8")!)
        mediaUrls.append(URL(string: "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8")!)
        mediaUrls.append(URL(string: "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8")!)
        mediaUrls.append(URL(string: "https://bitmovin-a.akamaihd.net/content/playhouse-vr/m3u8s/105560.m3u8")!)
        mediaUrls.append(URL(string: "https://www.abercap.com/build/media/samples/Subtitle_Movie_JPN.mp4")!)
        mediaUrls.append(URL(string: "https://www.abercap.com/build/media/samples/PSA_2016_Enhanced_Webcast_SDH.mp4")!)
        mediaUrls.append(URL(string: "https://ia601205.us.archive.org/35/items/cc_sample/cc_sample.mp4")!)
        mediaUrls.append(Bundle.main.url(forResource: "local_video_subtitle", withExtension: "mp4")!)
        mediaUrls.append(Bundle.main.url(forResource: "local_audio", withExtension: "mp3")!)
        mediaUrls.append(URL(string: "https://sample-videos.com/audio/mp3/wave.mp3")!)
        
        playerView.releasePlayerWhenImOut = true
        
        guideLabel.isHidden = true
        
        volumnBarView.backgroundColor = .white
        volumnBarView.layer.borderColor = UIColor.darkGray.cgColor
        volumnBarView.layer.borderWidth = 1
        
        mediaTableView.register(UINib.init(nibName: MediaTableViewCell.defaultIdentifier, bundle: nil), forCellReuseIdentifier: MediaTableViewCell.defaultIdentifier)
        mediaTableView.dataSource = self
        mediaTableView.delegate = self
        
        P9ViewDragger.default().trackingDecoyView(volumnLabel, stageView: self.view, parameters: [P9ViewDraggerLockRotateKey:true, P9ViewDraggerLockScaleKey:true, P9ViewDraggerStartWhenTouchDownKey:true], ready: { [weak self] (trackingView) in
            guard let `self` = self else {
                return
            }
            self.volumnLabel.isHidden = true
            let volumn = CGFloat(P9MediaManager.shared.volumeOfPlayer(forKey: self.playerView.suggestedKey))
            let length = self.volumnBarSize.height - trackingView.frame.size.height
            let x = trackingView.frame.origin.x + (trackingView.frame.size.width - self.volumnBarSize.width)*0.5
            let y = trackingView.frame.origin.y - self.volumnBarSize.height + trackingView.frame.size.height + (length*volumn)
            self.volumnBarView.frame = CGRect(x: x-2, y: y, width: self.volumnBarSize.width, height: self.volumnBarSize.height)
            if self.volumnBarView.superview == nil {
                self.view.insertSubview(self.volumnBarView, belowSubview: trackingView)
            }
        }, trackingHandler: { [weak self] (trackingView) in
            guard let `self` = self else {
                return
            }
            let volumnThumbFrame = self.view.convert(self.volumnLabel.frame, from: self.controlContainerView)
            let baseOffset = volumnThumbFrame.origin.y - self.volumnBarView.frame.origin.y
            let length = self.volumnBarSize.height - trackingView.frame.size.height
            let offset = trackingView.frame.origin.y - self.volumnBarView.frame.origin.y
            var volumn = 1-(offset/length)
            var transform = trackingView.transform
            if volumn < 0 {
                transform.ty = length-baseOffset
                volumn = 0
            }
            if volumn > 1 {
                transform.ty = -baseOffset
                volumn = 1
            }
            P9MediaManager.shared.setVolumeOfPlayer(volume: Float(volumn), forKey: self.playerView.suggestedKey)
            transform.tx = 0
            trackingView.transform = transform
        }) { [weak self] (trackingView) in
            guard let `self` = self else {
                return
            }
            if self.volumnBarView.superview != nil {
                self.volumnBarView.removeFromSuperview()
            }
            self.volumnLabel.isHidden = false
        }
        
        P9ViewDragger.default().trackingView(progressThumbLabel, parameters: [P9ViewDraggerLockRotateKey:true, P9ViewDraggerLockScaleKey:true], ready: { [weak self] (trackingView) in
            guard let `self` = self else {
                return
            }
            if P9MediaManager.shared.isPlayingPlayer(forKey: self.playerView.suggestedKey) == true {
                P9MediaManager.shared.setCustom(value: true, forKey: self.customKeyPlaying, ofPlayerKey: self.playerView.suggestedKey)
                P9MediaManager.shared.setCustom(value: true, forKey: self.customKeySeeking, ofPlayerKey: self.playerView.suggestedKey)
                P9MediaManager.shared.pausePlayer(forKey: self.playerView.suggestedKey)
            }
        }, trackingHandler: { [weak self] (trackingView) in
            guard let `self` = self else {
                return
            }
            let maxOffset = self.progressBackgroundView.frame.size.width - self.progressThumbLabel.frame.size.width
            var transform = trackingView.transform
            if transform.tx < 0 {
                transform.tx = 0
            }
            if transform.tx > maxOffset {
                transform.tx = maxOffset
            }
            transform.ty = 0
            trackingView.transform = transform
            let rate = Float(transform.tx/maxOffset)
            P9MediaManager.shared.setSeekTimeOfPlayer(rate: rate, forKey: self.playerView.suggestedKey)
        }) { [weak self] (trackingView) in
            guard let `self` = self else {
                return
            }
            if let flag = P9MediaManager.shared.customValue(forKey: self.customKeyPlaying, ofPlayerKey: self.playerView.suggestedKey) as? Bool, flag == true {
                P9MediaManager.shared.removeCustomeValue(forKey: self.customKeyPlaying, ofPlayerKey: self.playerView.suggestedKey)
                P9MediaManager.shared.removeCustomeValue(forKey: self.customKeySeeking, ofPlayerKey: self.playerView.suggestedKey)
                P9MediaManager.shared.playPlayer(forKey: self.playerView.suggestedKey)
            }
        }
    }
    
    @IBAction func playButtonTouchUpInside(_ sender: Any) {
        
        if P9MediaManager.shared.isPlayingPlayer(forKey: playerView.suggestedKey) == true {
            P9MediaManager.shared.pausePlayer(forKey: playerView.suggestedKey)
        } else {
            if P9MediaManager.shared.currentSecondsOfPlayer(forKey: playerView.suggestedKey) >= P9MediaManager.shared.amountSecondsOfPlayer(forKey: playerView.suggestedKey) {
                P9MediaManager.shared.setSeekTimeOfPlayer(rate: 0, forKey: playerView.suggestedKey)
            }
            P9MediaManager.shared.playPlayer(forKey: playerView.suggestedKey)
        }
    }
    
    @objc func p9MediaManagerNotificationHandler(notification:Notification) {
        
        guard let userInfo = notification.userInfo, let key = userInfo[P9MediaManager.NotificationPlayerKey] as? String, let eventValue = userInfo[P9MediaManager.NotificationEvent] as? Int, let event = P9MediaManager.Event(rawValue: eventValue), key == playerView.suggestedKey else {
            return
        }
        
        switch event {
        case .place, .placeAgain, .placeAlready:
            guideLabel.isHidden = false
            guideLabel.text = "placed, loading.."
            controlContainerView.isHidden = true
            progressThumbLabel.transform = .identity
        case .fail:
            guideLabel.text = "loading failed."
        case .readyToPlay:
            controlContainerView.isHidden = false
            if let haveAudio = userInfo[P9MediaManager.NotificationHaveAudioTrack] as? Bool, haveAudio == true {
                volumnLabel.text = "🔊"
                volumnLabel.isUserInteractionEnabled = true
                if let haveVideo = userInfo[P9MediaManager.NotificationHaveVideoTrack] as? Bool, haveVideo == true {
                    guideLabel.isHidden = true
                } else {
                    guideLabel.isHidden = false
                    guideLabel.text = "Audio Only"
                }
            } else {
                volumnLabel.text = "🔇"
                volumnLabel.isUserInteractionEnabled = false
                guideLabel.isHidden = true
            }
            if let haveSubtitle = userInfo[P9MediaManager.NotificationHaveSubtitleTrack] as? Bool, haveSubtitle == true {
                if let subtitles = P9MediaManager.shared.subtitleDisplayNamesOfPlayer(forKey: playerView.suggestedKey), subtitles.count > 0 {
                    P9MediaManager.shared.selectSubtitle(byDisplayName: subtitles[0], forKey: playerView.suggestedKey)
                }
            }
            playButton.setTitle("▶️", for: .normal)
            timeLabel.text = "ready."
            progressThumbLabel.isHidden = ((userInfo[P9MediaManager.NotificationAmountSeconds] as? Int64 ?? 0) == 0)
        case .play:
            playButton.setTitle("⏸", for: .normal)
        case .playing, .seek:
            if let seeking = P9MediaManager.shared.customValue(forKey: customKeySeeking, ofPlayerKey: playerView.suggestedKey) as? Bool, seeking == true {
                break
            }
            let currentSeconds = userInfo[P9MediaManager.NotificationCurrentSeconds] as? Int64 ?? 0
            let amountSeconds = userInfo[P9MediaManager.NotificationAmountSeconds] as? Int64 ?? 0
            if amountSeconds > 0 {
                let offset = (progressBackgroundView.frame.size.width-progressThumbLabel.frame.size.width) * (CGFloat(currentSeconds)/CGFloat(amountSeconds))
                progressThumbLabel.transform = CGAffineTransform.init(translationX: offset, y: 0)
            }
            timeLabel.text = String(format: "%02d:%02d:%02d", (currentSeconds/3600), (currentSeconds/60)%60, currentSeconds%60)
        case .pause:
            playButton.setTitle("▶️", for: .normal)
        case .playToEnd, .playToEndAndWillRewind:
            playButton.setTitle("▶️", for: .normal)
        default:
            break
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mediaUrls.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return MediaTableViewCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MediaTableViewCell.defaultIdentifier, for: indexPath)
        if let mediaCell = cell as? MediaTableViewCell {
            mediaCell.underlineView.isHidden = (indexPath.row >= mediaUrls.count-1)
            mediaCell.url = mediaUrls[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MediaTableViewCell.defaultIdentifier, for: indexPath)
        if let mediaCell = cell as? MediaTableViewCell {
            mediaCell.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if P9MediaManager.shared.setPlayer(resourceUrl: mediaUrls[indexPath.row], forKey: playerView.suggestedKey) == true {
            P9MediaManager.shared.placePlayer(forKey: playerView.suggestedKey, toView: playerView, mute: false, loop: false, autoPlayWhenReadyFlag: true)
        }
    }
}
