import AVFoundation
import Foundation
import UIKit
import SDWebImage

protocol PlayerDataSource: AnyObject {
    var bookName: String? { get }
    var author: String? { get }
    var imageURL: URL? { get }
    var transcript: String? { get }
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    private var playerVc: PlayerViewController = PlayerViewController()
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        return nil
    }
    
    var player: AVPlayer?
    
    var playTimer: DispatchSourceTimer?
    var imageTimer: Timer?
    var progressTimer: Timer?
    
    var pauseDuration: Float = 0.0
    
    var isPlaying: Bool = true
    var isRepeating: Bool = false
    var isTextOnDisplay: Bool = false
    var isImageOnDisplay: Bool = false
    
    var repeatObserverToken: Any?
        
    func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ) {
        guard let filePath = Bundle.main.path(forResource: "cantervilleghost_1", ofType: "mp3") else {
            return
        }

        let url = URL(fileURLWithPath: filePath)
        player = AVPlayer(url: url)
        
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        
        PlayerControlsView.endTimeLabel.text = convertTimeToString(time: Double(track.duration))
        
        playerVc = PlayerViewController()
        playerVc.dataSource = self
        playerVc.delegate = self
        
        viewController.present(UINavigationController(rootViewController: playerVc), animated: true) { [weak self] in
            self?.player?.play()
            self?.progressTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                       target: self,
                                                       selector: #selector(self!.updatePlayTime),
                                                       userInfo: nil,
                                                       repeats: true)
            
        }
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func convertTimeToString(time: Double) -> String {
        let min = Int(time / 60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min, sec)
        return strTime
    }
    
    @objc func updatePlayTime() {
        if let currentTime = player?.currentTime(), let duration = track?.duration {
            PlayerControlsView.currentTimeLabel.text = convertTimeToString(time: CMTimeGetSeconds(currentTime))
            PlayerControlsView.progressSlider.value = Float(CMTimeGetSeconds(currentTime) / Double(duration))
        }
    }
    
    func didTapPlayPause() {
        guard let player = player else { return }
        
        isPlaying.toggle()
        
        if player.timeControlStatus == .playing {
            player.pause()
            playTimer?.cancel()
        }
        else if player.timeControlStatus == .paused {
            if pauseDuration == 0 {
                player.play()
            }
            else {
                let currentSegmentIndex = getCurrentSegmentIndex()
                playSegment(index: currentSegmentIndex)
            }
        }
    }
    
    func didTapForward() {
        guard let player = player else { return }
        
        player.pause()
        
        let currentSegmentIndex = getCurrentSegmentIndex()
        
        if let segmentSeconds = track?.segmentSeconds {
            if currentSegmentIndex < segmentSeconds.count - 1 {
                let nextSegmentIndex = currentSegmentIndex + 1
                
                if pauseDuration == 0 {
                    let startSecond = segmentSeconds[nextSegmentIndex].0
                    
                    player.seek(to: CMTime(seconds: Double(startSecond), preferredTimescale: 22050))
                    if isPlaying {
                        player.play()
                    }
                }
                else {
                    if isPlaying {
                        playSegment(index: nextSegmentIndex)
                    }
                }
            }
        }
    }
    
    func didTapBackward() {
        guard let player = player else { return }
        
        player.pause()
        
        let currentSegmentIndex = getCurrentSegmentIndex()
        
        if let segmentSeconds = track?.segmentSeconds {
            let previousSegmentIndex = (currentSegmentIndex == 0) ? 0 : currentSegmentIndex - 1
            
            if pauseDuration == 0 {
                let startSecond = segmentSeconds[previousSegmentIndex].0
                
                player.seek(to: CMTime(seconds: Double(startSecond), preferredTimescale: 22050))
                if isPlaying {
                    player.play()
                }
            }
            else {
                if isPlaying {
                    playSegment(index: previousSegmentIndex)
                }
            }
        }
    }
    
    func didTapRepeat() {
        if isRepeating {
            removeRepeatObserver()
        } else {
            addRepeatObserver()
        }
        
        isRepeating.toggle()
    }
    
    private func addRepeatObserver() {
        guard let player = player else { return }
        
        let index = getCurrentSegmentIndex()
        
        if let segmentSeconds = track?.segmentSeconds {
            if pauseDuration != 0 {
                playTimer?.cancel()
            }
            let currentSegment = segmentSeconds[index]

            if isPlaying, player.timeControlStatus == .paused {
                player.play()
            }
            
            repeatObserverToken = player.addBoundaryTimeObserver(
                forTimes: [NSValue(time: CMTime(seconds: Double(currentSegment.1),
                                                preferredTimescale: 22050))],
                queue: .main) {
                player.seek(to: CMTime(seconds: Double(currentSegment.0), preferredTimescale: 22050))
                player.play()
            }
        }
    }

    private func removeRepeatObserver() {
        guard let player = player else { return }
        
        if let token = repeatObserverToken {
            player.removeTimeObserver(token)
            repeatObserverToken = nil
            
            if pauseDuration != 0 {
                if let segmentSeconds = track?.segmentSeconds {
                    let currentSegmentIndex = getCurrentSegmentIndex()
                    let endSecond = segmentSeconds[currentSegmentIndex].1
                    let currentTime = player.currentTime()
                    let currentTimeFloat = CMTimeGetSeconds(currentTime)
                    
                    let waitTime = (Double(endSecond) - currentTimeFloat) / Double(player.defaultRate)
                    DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) { [weak self] in
                        self!.player?.pause()
                        self!.playSegment(index: currentSegmentIndex + 1)
                    }
                }

            }
        }
    }
    
    func didTapSpeed(_ value: Float) {
        guard let player = player else { return }
        
        player.defaultRate = value

        if player.timeControlStatus == .playing {
            if self.pauseDuration == 0 {
                player.rate = value
            }
            else {
                player.pause()
                playSegment(index: getCurrentSegmentIndex())
            }
        }
    }
    
    func didTapText() {
        playerVc.toggleTextView()
        
        isTextOnDisplay.toggle()
        
        if isImageOnDisplay {
            isImageOnDisplay.toggle()
            stopTimer()
        }
    }
    
    func didTapTextToImage() {
        playerVc.toggleImageView()
        
        isImageOnDisplay.toggle()
        
        if isImageOnDisplay {
            startTimer()
        }
        else {
            stopTimer()
        }
    }
        
    func startTimer() {
        imageTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateImage), userInfo: nil, repeats: true)
    }
        
    func stopTimer() {
        imageTimer?.invalidate()
        imageTimer = nil
    }    

    @objc func updateImage() {
        guard let player = player, let currentTime = player.currentItem?.currentTime().seconds else {
            return
        }
        
        if let sections = self.track?.sections {
            for section in sections {
                if currentTime >= Double(section.start_time) && currentTime <= Double(section.end_time) {
                    let url = section.image_url
                    self.playerVc.imageView.sd_setImage(with: url, completed: nil)

                    return
                }
            }
        }
        
    }
    
    func didTapAddPause(_ value: Float) {
        guard let player = player else { return }
        
        self.pauseDuration = value
        
        if isPlaying {
            player.pause()
            
            if self.pauseDuration == 0 {
                playTimer?.cancel()
                player.play()
            }
            else {
                let currentSegmentIndex = getCurrentSegmentIndex()
                playSegment(index: currentSegmentIndex)
            }
        }
    }
    
    func didSlideSlider(_ value: Float) {
        guard let player = player, let duration = self.track?.duration else { return }
                
        let value = Double(value) * Double(duration)
        let seekTime = CMTime(value: CMTimeValue(value * 1000), timescale: 1000)
        
        player.seek(to: seekTime)
    }
    
    func getCurrentSegmentIndex() -> Int {
        var currentIndex: Int = 0
        
        if let segmentSeconds = track?.segmentSeconds, let currentTime = player?.currentTime() {
            for (index, seconds) in segmentSeconds.enumerated() {
                if currentTime >= CMTime(seconds: Double(seconds.0), preferredTimescale: 22050) {
                    currentIndex = index
                }
                else {
                    break
                }
            }
        }
        
        return currentIndex
    }
    
    func playSegment(index: Int) {
        guard let player = player else { return }
        guard index < (track?.segmentSeconds.count)!, isPlaying else { return }
        
        let currentSegmentIndex = index
        
        if let segmentSeconds = track?.segmentSeconds {
            let startSecond = segmentSeconds[currentSegmentIndex].0
            let endSecond = segmentSeconds[currentSegmentIndex].1
            let duration = Double(endSecond - startSecond) / Double(player.defaultRate)
            
            player.seek(to: CMTime(seconds: Double(startSecond), preferredTimescale: 22050))
            player.play()

            playTimer = DispatchSource.makeTimerSource()
            playTimer?.schedule(deadline: .now() + duration, repeating: .never)
            playTimer?.setEventHandler {
                self.playNextSegmentAfterPause(index: currentSegmentIndex)
            }
            playTimer?.resume()
            
        }
    }
        
    func playNextSegmentAfterPause(index: Int) {
        guard let player = player else { return }
        guard index + 1 < (track?.segmentSeconds.count)!, isPlaying else { return }
        
        player.pause()

        playTimer = DispatchSource.makeTimerSource()
        let pauseDurationNanoseconds = Int(self.pauseDuration * 1_000_000_000)
        let pauseEndTime = DispatchTime.now() + DispatchTimeInterval.nanoseconds(pauseDurationNanoseconds)
        playTimer?.schedule(deadline: pauseEndTime, repeating: .never)
        playTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            playSegment(index: index + 1)
        }
        playTimer?.resume()
    }

}

extension PlaybackPresenter: PlayerDataSource {
    var bookName: String? {
        return currentTrack?.title
    }
    
    var author: String? {
        return currentTrack?.author
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.imageURL ?? "")
    }
    
    var transcript: String? {
        return currentTrack?.transcript
    }
}
