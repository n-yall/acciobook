import Foundation
import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapRepeatButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapSpeedButton(_ plaayerControlsView: PlayerControlsView, didTapSpeed value: Float)
    func playerControlsViewDidTapTextButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapTextToImageButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapAddPauseButton(_ plaayerControlsView: PlayerControlsView, didTapAddPause value: Float)
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

final class PlayerControlsView: UIView {
    
    private var isPlaying = true
    private var isRepeating = false
        
    weak var delegate: PlayerControlsViewDelegate?
    
    static let progressSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    static let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    private let backButton: CustomBackButton = {
//        let button = CustomBackButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
//    private let nextButton: CustomNextButton = {
//        let button = CustomNextButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
//    private let repeatButton: CustomRepeatButton = {
//        let button = CustomRepeatButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "gobackward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "goforward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .regular))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let speedButton: UIButton = {
        let button = UIButton()
        button.setTitle("1x", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let repeatButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let textButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "captions.bubble", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let textToImageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addPauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Pause", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        addSubview(PlayerControlsView.progressSlider)
        PlayerControlsView.progressSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        addSubview(PlayerControlsView.currentTimeLabel)
        addSubview(PlayerControlsView.endTimeLabel)
        
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        addSubview(speedButton)
        addSubview(repeatButton)
        addSubview(textButton)
        addSubview(textToImageButton)
        addSubview(addPauseButton)
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        speedButton.addTarget(self, action: #selector(didTapSpeed), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(didTapRepeat), for: .touchUpInside)
        textButton.addTarget(self, action: #selector(didTapText), for: .touchUpInside)
        textToImageButton.addTarget(self, action: #selector(didTapTextToImage), for: .touchUpInside)
        addPauseButton.addTarget(self, action: #selector(didTapAddPause), for: .touchUpInside)
        
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        delegate?.playerControlsView(self, didSlideSlider: value)
    }
    
    @objc private func didTapBack() {
        delegate?.playerControlsViewDidTapBackwardButton(self)
    }
    
    @objc private func didTapNext() {
        delegate?.playerControlsViewDidTapForwardButton(self)
    }
    
    @objc private func didTapPlayPause() {
        self.isPlaying.toggle()
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
        
        let pause = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .regular))
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44, weight: .regular))

        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
    
    @objc private func didTapRepeat() {
        self.isRepeating.toggle()
        delegate?.playerControlsViewDidTapRepeatButton(self)

        let addRepeat = UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))
        let removeRepeat = UIImage(systemName: "repeat.1", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))

        if isRepeating {
            repeatButton.setImage(removeRepeat, for: .normal)
            backButton.isEnabled = false
            nextButton.isEnabled = false
            speedButton.isEnabled = false
            speedButton.setTitleColor(.gray, for: .normal)
        }
        else {
            repeatButton.setImage(addRepeat, for: .normal)
            backButton.isEnabled = true
            nextButton.isEnabled = true
            speedButton.isEnabled = true
            speedButton.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc private func didTapSpeed(sender: UIButton) {
        
        let menu = UIMenu(title: "Select Speed", children: [
                    UIAction(title: "0.5x",
                             handler: { _ in
                                 self.speedButton.setTitle("0.5x", for: .normal)
                                 self.delegate?.playerControlsViewDidTapSpeedButton(self, didTapSpeed: 0.5) }),
                    UIAction(title: "0.75x",
                             handler: { _ in 
                                 self.speedButton.setTitle("0.75x", for: .normal)
                                 self.delegate?.playerControlsViewDidTapSpeedButton(self, didTapSpeed: 0.75) }),
                    UIAction(title: "1x",
                             handler: { _ in 
                                 self.speedButton.setTitle("1x", for: .normal)
                                 self.delegate?.playerControlsViewDidTapSpeedButton(self, didTapSpeed: 1) }),
                    UIAction(title: "1.25x",
                             handler: { _ in 
                                 self.speedButton.setTitle("1.25x", for: .normal)
                                 self.delegate?.playerControlsViewDidTapSpeedButton(self, didTapSpeed: 1.25) }),
                    UIAction(title: "1.5x",
                             handler: { _ in 
                                 self.speedButton.setTitle("1.5x", for: .normal)
                                 self.delegate?.playerControlsViewDidTapSpeedButton(self, didTapSpeed: 1.5) }),
                    UIAction(title: "2x",
                             handler: { _ in 
                                 self.speedButton.setTitle("2x", for: .normal)
                                 self.delegate?.playerControlsViewDidTapSpeedButton(self, didTapSpeed: 2) })
                ])
                
                sender.menu = menu
                sender.showsMenuAsPrimaryAction = true
    }
    
    @objc private func didTapText() {
        delegate?.playerControlsViewDidTapTextButton(self)
    }
    
    @objc private func didTapTextToImage() {
        delegate?.playerControlsViewDidTapTextToImageButton(self)
    }
    
    @objc private func didTapAddPause(sender: UIButton) {
        let menu = UIMenu(title: "Select Pause Duration", children: [
                    UIAction(title: "No Pause",
                             handler: { _ in
                                 self.addPauseButton.setTitle("Add Pause", for: .normal)
                                 self.delegate?.playerControlsViewDidTapAddPauseButton(self, didTapAddPause: 0) }),
                    UIAction(title: "1 second",
                             handler: { _ in 
                                 self.addPauseButton.setTitle("Pause: 1s", for: .normal)
                                 self.delegate?.playerControlsViewDidTapAddPauseButton(self, didTapAddPause: 1) }),
                    UIAction(title: "2 seconds",
                             handler: { _ in 
                                 self.addPauseButton.setTitle("Pause: 2s", for: .normal)
                                 self.delegate?.playerControlsViewDidTapAddPauseButton(self, didTapAddPause: 2) }),
                    UIAction(title: "3 seconds",
                             handler: { _ in 
                                 self.addPauseButton.setTitle("Pause: 3s", for: .normal)
                                 self.delegate?.playerControlsViewDidTapAddPauseButton(self, didTapAddPause: 3) }),
                    UIAction(title: "4 seconds",
                             handler: { _ in 
                                 self.addPauseButton.setTitle("Pause: 4s", for: .normal)
                                 self.delegate?.playerControlsViewDidTapAddPauseButton(self, didTapAddPause: 4) }),
                    UIAction(title: "5 seconds",
                             handler: { _ in 
                                 self.addPauseButton.setTitle("Pause: 5s", for: .normal)
                                 self.delegate?.playerControlsViewDidTapAddPauseButton(self, didTapAddPause: 5) })
                ])
                
                sender.menu = menu
                sender.showsMenuAsPrimaryAction = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
                    
            PlayerControlsView.progressSlider.topAnchor.constraint(equalTo: topAnchor),
            PlayerControlsView.progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            PlayerControlsView.progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            PlayerControlsView.progressSlider.heightAnchor.constraint(equalToConstant: 40),
                    
            PlayerControlsView.currentTimeLabel.topAnchor.constraint(equalTo: PlayerControlsView.progressSlider.bottomAnchor),
            PlayerControlsView.currentTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            PlayerControlsView.currentTimeLabel.heightAnchor.constraint(equalToConstant: 20),
            
            PlayerControlsView.endTimeLabel.topAnchor.constraint(equalTo: PlayerControlsView.progressSlider.bottomAnchor),
            PlayerControlsView.endTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            PlayerControlsView.endTimeLabel.heightAnchor.constraint(equalToConstant: 20),
            
            playPauseButton.topAnchor.constraint(equalTo: PlayerControlsView.currentTimeLabel.bottomAnchor, constant: 25),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            backButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -25),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 60),
            
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 25),
            nextButton.widthAnchor.constraint(equalToConstant: 60),
            nextButton.heightAnchor.constraint(equalToConstant: 60),
            
            speedButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            speedButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            speedButton.widthAnchor.constraint(equalToConstant: 60),
            speedButton.heightAnchor.constraint(equalToConstant: 60),
            
            repeatButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            repeatButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            repeatButton.widthAnchor.constraint(equalToConstant: 60),
            repeatButton.heightAnchor.constraint(equalToConstant: 60),
            
            addPauseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            addPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addPauseButton.widthAnchor.constraint(equalToConstant: 100),
            addPauseButton.heightAnchor.constraint(equalToConstant: 30),
            
            textButton.centerYAnchor.constraint(equalTo: addPauseButton.centerYAnchor),
            textButton.trailingAnchor.constraint(equalTo: addPauseButton.leadingAnchor, constant: -30),
            textButton.widthAnchor.constraint(equalToConstant: 60),
            textButton.heightAnchor.constraint(equalToConstant: 60),
            
            textToImageButton.centerYAnchor.constraint(equalTo: addPauseButton.centerYAnchor),
            textToImageButton.leadingAnchor.constraint(equalTo: addPauseButton.trailingAnchor, constant: 30),
            textToImageButton.widthAnchor.constraint(equalToConstant: 60),
            textToImageButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
