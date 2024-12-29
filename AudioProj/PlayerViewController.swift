import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didTapRepeat()
    func didTapSpeed(_ value: Float)
    func didTapText()
    func didTapTextToImage()
    func didTapAddPause(_ value: Float)
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    var book = [AudioTrack]()
    
    let bookCoverView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Transcript will be shown here."
        textView.font = UIFont(name: "Palatino", size: 18)
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.isHidden = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private let detailsView = DetailsView()
    private let controlsView = PlayerControlsView()
    
    private var bookCoverViewHeightConstraint: NSLayoutConstraint!
    private var detailsViewHeightConstraint: NSLayoutConstraint!
    private var detailsViewTopConstraint: NSLayoutConstraint!
    private var detailsViewLeadingConstraint: NSLayoutConstraint!
    private var textViewHeightConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    private var isTextVisible = false
    private var isImageVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(bookCoverView)
        view.addSubview(textView)
        view.addSubview(imageView)
        view.addSubview(detailsView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configure()
        
        bookCoverViewHeightConstraint = bookCoverView.heightAnchor.constraint(equalToConstant: view.width)
        detailsViewTopConstraint = detailsView.topAnchor.constraint(equalTo: bookCoverView.bottomAnchor, constant: 15)
        detailsViewLeadingConstraint = detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25)
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 0)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            bookCoverView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookCoverView.widthAnchor.constraint(equalTo: bookCoverView.heightAnchor),
            bookCoverViewHeightConstraint
        ])
        
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailsViewTopConstraint,
            detailsViewLeadingConstraint,
            detailsView.widthAnchor.constraint(equalToConstant: 200),
            detailsView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textViewHeightConstraint
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: textView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageViewHeightConstraint
        ])

        controlsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        ])
    }

    private func configure() {
        bookCoverView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        textView.text = dataSource?.transcript
        imageView.sd_setImage(with: URL(string: "https://sonobel.com.br/assets/img/loading_icon.gif"))
        detailsView.configure(title: dataSource?.bookName, author: dataSource?.author)
    }
    
    func toggleTextView() {
        isTextVisible.toggle()
        
        self.detailsViewTopConstraint.isActive = false
        self.detailsViewLeadingConstraint.isActive = false
        
        if self.isTextVisible {
            if self.isImageVisible {
                self.imageViewHeightConstraint.constant = 0
                self.imageView.isHidden = true
                self.isImageVisible.toggle()
            }
            
            self.bookCoverViewHeightConstraint.constant = 50
            self.detailsViewTopConstraint = self.detailsView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor)
            self.detailsViewLeadingConstraint = self.detailsView.leadingAnchor.constraint(
                equalTo: self.bookCoverView.trailingAnchor,
                constant: 10)
            self.textViewHeightConstraint.constant = self.view.width + 15
            self.textView.isHidden = false
        } else {
            self.bookCoverViewHeightConstraint.constant = self.view.width
            self.detailsViewTopConstraint = detailsView.topAnchor.constraint(
                equalTo: bookCoverView.bottomAnchor,
                constant: 15)
            self.detailsViewLeadingConstraint = detailsView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 25)
            self.textViewHeightConstraint.constant = 0
            self.textView.isHidden = true
        }
        
        self.detailsViewTopConstraint.isActive = true
        self.detailsViewLeadingConstraint.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func toggleImageView() {
        isImageVisible.toggle()
        
        self.detailsViewTopConstraint.isActive = false
        self.detailsViewLeadingConstraint.isActive = false
        
        if self.isImageVisible {
            if self.isTextVisible {
                self.textViewHeightConstraint.constant = 0
                self.textView.isHidden = true
                self.isTextVisible.toggle()
            }
            
            self.bookCoverViewHeightConstraint.constant = 50
            self.detailsViewTopConstraint = self.detailsView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor)
            self.detailsViewLeadingConstraint = self.detailsView.leadingAnchor.constraint(
                equalTo: self.bookCoverView.trailingAnchor,
                constant: 10)
            self.imageViewHeightConstraint.constant = self.view.width + 15
            self.imageView.isHidden = true
        } else {
            self.bookCoverViewHeightConstraint.constant = self.view.width
            self.detailsViewTopConstraint = detailsView.topAnchor.constraint(
                equalTo: bookCoverView.bottomAnchor,
                constant: 15)
            self.detailsViewLeadingConstraint = detailsView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 25)
            self.imageViewHeightConstraint.constant = 0
            self.imageView.isHidden = true
        }
        
        self.detailsViewTopConstraint.isActive = true
        self.detailsViewLeadingConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            if self.isImageVisible {
                self.imageView.isHidden = false
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.imageView.transform = .identity
                })
            }
        }
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {

    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func playerControlsViewDidTapBackwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playerControlsViewDidTapRepeatButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapRepeat()
    }
    
    func playerControlsViewDidTapSpeedButton(_ playerControlsView: PlayerControlsView, didTapSpeed value: Float) {
        delegate?.didTapSpeed(value)
    }
    
    func playerControlsViewDidTapTextButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapText()
    }
    
    func playerControlsViewDidTapTextToImageButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapTextToImage()
    }
    
    func playerControlsViewDidTapAddPauseButton(_ playerControlsView: PlayerControlsView, didTapAddPause value: Float) {
        delegate?.didTapAddPause(value)
    }
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
}

