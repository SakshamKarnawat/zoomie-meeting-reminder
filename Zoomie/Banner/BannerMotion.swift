import Foundation

enum BannerMotion {
    /// Maps 0...1 elapsed fraction to 0...1 travel.
    /// First and last `easePortion` ease in/out; the middle stays linear (constant speed).
    static func progress(elapsedFraction t: Double, easePortion: Double = Design.easePortion) -> Double {
        let t = min(1, max(0, t))
        let ease = min(max(easePortion, 0), 0.45)
        if t < ease {
            let u = t / ease
            return ease * (-u * u * u + 2 * u * u)
        }
        if t > 1 - ease {
            let u = (t - (1 - ease)) / ease
            let start = 1 - ease
            return (2 * u * u * u - 3 * u * u + 1) * start
                + ease * (u * u * u - 2 * u * u + u)
                + (-2 * u * u * u + 3 * u * u)
        }
        return t
    }

    static func duration(distance: Double, pixelsPerSecond: Double = Design.pixelsPerSecond) -> TimeInterval {
        max(distance / max(pixelsPerSecond, 1), 0.25)
    }
}
