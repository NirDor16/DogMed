import UIKit

enum ImageUtils {
    static let maxDimension: CGFloat = 400
    static let jpegQuality: CGFloat = 0.5

    static func base64String(from image: UIImage) -> String? {
        let resized = resize(image, maxDimension: maxDimension)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else { return nil }
        return data.base64EncodedString()
    }

    static func image(fromBase64 base64: String?) -> UIImage? {
        guard let base64 = base64, let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let largestSide = max(size.width, size.height)
        guard largestSide > maxDimension else { return image }
        let scale = maxDimension / largestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
