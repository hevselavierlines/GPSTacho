import UIKit

public extension UIImageView {
  // MARK: - Computed Properties
  var animatableImage: AnimatedImage? {
    return image as? AnimatedImage
  }

  var isAnimatingGIF: Bool {
    return animatableImage?.isAnimating() ?? isAnimating()
  }

  var animatable: Bool {
    return animatableImage != .None
  }

  // MARK: - Method Overrides
  override public func displayLayer(layer: CALayer) {
    layer.contents = animatableImage?.currentFrame?.CGImage
  }

  // MARK: - Setter Methods
  public func setAnimatedImage(image: AnimatedImage) {
    image.delegate = self
    self.image = image
    layer.setNeedsDisplay()
  }

  /**
    * Starts an animation from the startValue to the endValue.
    * if the endValue is larger than the amount of frames it will be repated.
    */
    func startAnimatingGIF(startValue : Int, endValue: Int) {
        animatableImage?.resumeAnimation(startValue, endValue: endValue)// ?? startAnimating()
    }
    /**
    * Starts a infinit-loop animation from the startValue.
    */
    func startAnimatingGIF(startValue : Int) {
        animatableImage?.resumeAnimation(startValue)
    }
    /**
    * Sets the frame-duration of the animation (how long a frame is shown on the screen).
    */
    func setDuration(duration: Double) {
        animatableImage?.setDuration(duration)
    }
    /**
    * Starts a infinit-loop animation from the first frame.
    */
    func startAnimatingGIF() {
        animatableImage?.resumeAnimation()// ?? startAnimating()
    }
    /**
    * Stops the animation and returns the current frame.
    */
    func stopAnimatingGIF() -> Int? {
        let frame = animatableImage?.pauseAnimation()
        stopAnimating()
        return frame
    }
}
