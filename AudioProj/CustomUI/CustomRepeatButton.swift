import UIKit

class CustomRepeatButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        titleLabel?.numberOfLines = 1
        titleLabel?.textAlignment = .center
        
        let image = UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        setImage(image, for: .normal)
        tintColor = .black
        
        let title = "Segment"
        let font = UIFont.systemFont(ofSize: 8, weight: .bold)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let attributedText = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributedText, for: .normal)

        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center

        let imageSize = image!.size
        let titleSize = attributedText.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        ).size
        
        let spacing: CGFloat = 0
        
        imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height / 2 + spacing / 2),
            left: 0,
            bottom: (titleSize.height / 2 + spacing / 2),
            right: -titleSize.width
        )
        
        titleEdgeInsets = UIEdgeInsets(
            top: (imageSize.height / 2 + spacing / 2),
            left: -imageSize.width,
            bottom: -(imageSize.height / 2 + spacing / 2),
            right: 0
        )
        
        sizeToFit()
    }
}
