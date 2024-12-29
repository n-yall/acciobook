import UIKit

class MainViewController: UIViewController {
    
    private var tracks = [AudioTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APICaller.shared.getAudiobooks { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audiobooks):
                    self.tracks = audiobooks
                    guard let firstTrack = self.tracks.first else {
                        print("No tracks available")
                        return
                    }
                    PlaybackPresenter.shared.startPlayback(from: self, track: firstTrack)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        view.backgroundColor = .systemMint
    }
}
