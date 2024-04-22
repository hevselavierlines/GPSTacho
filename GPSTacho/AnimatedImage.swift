import UIKit
import ImageIO

public class AnimatedImage: UIImage {
  // MARK: - Constants
  let maxTimeStep = 1.0

  // MARK: - Public Properties
  var delegate: UIImageView?
  var animatedFrames = [AnimatedFrame]()
  var totalDuration: NSTimeInterval = 0.0

  override public var size: CGSize {
    return frameAtIndex(0)?.size ?? CGSizeZero
  }

  // MARK: - Private Properties
  private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "updateCurrentFrame")
  private var currentFrameIndex = 0
  private var direction = true
  private var startFrame = 0
  private var endFrame = 50
  private var timeSinceLastFrameChange: NSTimeInterval = 0.0
  private var frameDuration = 0.01

  // MARK: - Computed Properties
  var currentFrame: UIImage? {
    return frameAtIndex(currentFrameIndex)
  }

  private var isAnimated: Bool {
    return totalDuration != 0.0
  }

  // MARK: - Initializers
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  public override convenience init(data: NSData) {
    self.init(data: data, size: CGSizeZero)
  }

  required public init(data: NSData, size: CGSize) {
    super.init()

    let imageSource = CGImageSourceCreateWithData(data, nil)
    attachDisplayLink()
    curry(prepareFrames) <^> imageSource <*> size
    pauseAnimation()
  }

  required convenience public init(imageLiteral name: String) {
      fatalError("init(imageLiteral:) has not been implemented")
  }

  // MARK: - Factories
  public class func animatedImageWithName(name: String) -> AnimatedImage? {
    let path = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent(name)
    return animatedImageWithData <^> NSData(contentsOfFile: path)
  }

  public class func animatedImageWithData(data: NSData) -> AnimatedImage {
    let size = UIImage.sizeForImageData(data) ?? CGSizeZero
    return self.init(data: data, size: size)
  }

  public class func animatedImageWithName(name: String, size: CGSize) -> AnimatedImage? {
    let path = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent(name)
    return curry(animatedImageWithData) <^> NSData(contentsOfFile: path) <*> size
  }

  public class func animatedImageWithData(data: NSData, size: CGSize) -> AnimatedImage {
    return self.init(data: data, size: size)
  }
    
    public func setDuration(_duration: Double) {
        frameDuration = _duration
    }

  // MARK: - Display Link Helpers
  func attachDisplayLink() {
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }

  // MARK: - Frame Methods
  private func prepareFrames(imageSource: CGImageSourceRef, size: CGSize) {
    let numberOfFrames = Int(CGImageSourceGetCount(imageSource))
    animatedFrames.reserveCapacity(numberOfFrames)

    (animatedFrames, totalDuration) = (0..<numberOfFrames).reduce(([AnimatedFrame](), 0.0)) { accumulator, index in
      let accumulatedFrames = accumulator.0
      let accumulatedDuration = accumulator.1
      frameDuration = CGImageSourceGIFFrameDuration(imageSource, index: index)
      let frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, Int(index), nil)
      let frame = UIImage(CGImage: frameImageRef!).resize(size)
      let animatedFrame = AnimatedFrame(image: frame, duration: frameDuration)

      return (accumulatedFrames + [animatedFrame], accumulatedDuration + frameDuration)
    }
  }
    

    func preparForReuse() {
        pauseAnimation()
        animatedFrames.removeAll(keepCapacity: false)
    }

  func frameAtIndex(index: Int) -> UIImage? {
    if index >= animatedFrames.count { return .None }
    return animatedFrames[index].image
  }

  func updateCurrentFrame() {
    if !isAnimated { return }

    timeSinceLastFrameChange += min(maxTimeStep, displayLink.duration)
    if timeSinceLastFrameChange >= frameDuration {
      timeSinceLastFrameChange -= frameDuration
        if direction == true {
            currentFrameIndex = ++currentFrameIndex % animatedFrames.count
            if currentFrameIndex >= endFrame && endFrame >= 0 {
                displayLink.paused = true
            }
        } else {
            if currentFrameIndex <= 0 {
                currentFrameIndex = animatedFrames.count - 1
            } else {
                currentFrameIndex = currentFrameIndex - 1
            }
            if currentFrameIndex <= endFrame {
                displayLink.paused = true
            }
        }
      delegate?.layer.setNeedsDisplay()
    }
  }

  // MARK: - Animation
  func pauseAnimation() -> Int {
    displayLink.paused = true
    return currentFrameIndex
  }

    func resumeAnimation(startValue : Int, endValue : Int) {
    startFrame = startValue
    endFrame = endValue
    currentFrameIndex = startValue
        if(startValue > endValue) {
            direction = false
        } else {
            direction = true
        }
    
    displayLink.paused = false
  }
    
    func resumeAnimation(startValue : Int) {
        startFrame = startValue
        endFrame = -1
        direction = true
        displayLink.paused = false
    }
    
    func resumeAnimation() {
        displayLink.paused = false
        endFrame = -1
    }

  func isAnimating() -> Bool {
    return !displayLink.paused
  }
}
