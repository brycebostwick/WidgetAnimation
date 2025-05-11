//
//  Widget.swift
//  Widget
//
//  Created by Bryce Bostwick on 5/9/25.
//

import WidgetKit
import SwiftUI

struct WidgetEntryView : View {

    var entry: Provider.Entry

    /**
     Shows a 30-second long looping animation running at 8 FPS
     (though you can get up to 30+ FPS with this technique).

     Uses 17 custom fonts — 16 of the fonts contain the actual frames for the animation, where each
     font contains every 16th frame:

     `CatFont0` - Contains frames 0, 16, 32, 48, etc
     `CatFont1` - Contains frames 1, 17, 33, 49, etc
     `CatFont2` - Contains frames 2, 18, 34, 50, etc

     The 17th font contains a square that blinks on and off - e.g., shows a solid square for one second,
     then nothing for a second, then a solid square again.

     The cat fonts are then used in timers that are stacked on top of eachother — the blinking font is then
     used to reveal each timer in sequence, so that we see `CatFont0`, and then `CatFont1` a frame later,
     then `CatFont2` a frame after that, all the way up to `CatFont15`.

     The frame after `CatFont15` is shown, we hide it to loop back to `CatFont0` — which at this point,
     has moved on to now show frame 16 (since it itself is a timer!). The next frame show `CatFont1`
     (whichi s now showing frame 17), and so on.
     */
    var body: some View {

        // Since we're creating a bunch of timers, we want them to all
        // be animating relative to the same predictable starting date.
        // We set that date to be a bit in the past since we add some time offsets
        // to different timers; we want to make sure after those additions,
        // all timers still started sometime in the past.
        let referenceDate = Date() - 60

        // Hardcoded frame count: we are showing 8 frames per second, and
        // we need to show at least 2 seconds' worth of frames (because
        // of the periodic nature of our blinking timer view, which blinks
        // on for a second, then off for a second). 8 * 2 = 16 total frames
        let frameCount = 16

        // Animate at 8 frames per second
        let frameDuration = 1 / CGFloat(8)

        // Hardcoded widget size to make life a bit easier.
        // In an actual application, you'd obviously want to read this
        // value from elsewhere
        let size: CGFloat = 364

        // Create two different stacks of frames: one for the first half
        // of frames, and one for the second half
        ZStack {

            // The first stack of frames (always on-screen, so sometimes
            // blocked by the second stack)
            ZStack {

                // The first frame should always be on-screen; it will mostly
                // be blocked by other frames, but if all other frames are currently
                // hidden, we want this frame to be visible by default
                Text(referenceDate + 1, style: .timer)
                    .font(Font.custom("CatFont0-Regular", size: size))
                    .centerLastCharacer(size: size)

                // For the rest of the first half of frames, create each frame...
                ForEach(1 ..< (frameCount / 2), id: \.self) { i in
                    Text(referenceDate + 1 + frameDuration * CGFloat(i), style: .timer)
                        .font(Font.custom("CatFont\(i)-Regular", size: size))
                        .centerLastCharacer(size: size)
                        .mask(
                            // ... and set the frame to appear one `frameDuration` after the last
                            SimpleBlinkingView(blinkOffset: CGFloat(-i) * frameDuration)
                                .frame(width: size, height: size)
                        )
                }
            }

            // The second stack of frames (only on-screen half the time).
            // This allows us to stack all these frames on top of the first, and then
            // when it comes time to loop the entire animation, hide this entire stack
            // so that we can see the initial frames again
            ZStack {

                // Very similar to above; create a stack of frames,
                // and show each frame one `frameDuration` after the last
                ForEach((frameCount / 2) ..< frameCount, id: \.self) { i in
                    Text(referenceDate + 1 + frameDuration * CGFloat(i), style: .timer)
                        .font(Font.custom("CatFont\(i)-Regular", size: size))
                        .centerLastCharacer(size: size)
                        .mask(
                            SimpleBlinkingView(blinkOffset: CGFloat(-i) * frameDuration)
                                .frame(width: size, height: size)
                        )
                }
            }
            .mask(
                // Mask the entire second stack so that it's only visible from t=0 to t=1,
                // then invisble from t=1 to t=2, etc
                SimpleBlinkingView(blinkOffset: 1)
                    .frame(width: size, height: size)
            )
        }
    }
}

/**
 A simple blinking view — uses a timer with a custom font to blink on for a second,
 then off for a second, repeating infinitely
 */
struct SimpleBlinkingView: View {

    static let referenceDate = Date() - 60
    var blinkOffset: TimeInterval

    init(blinkOffset: TimeInterval) {
        self.blinkOffset = blinkOffset
    }

    var body: some View {
        GeometryReader { geometry in
            let maxSize = max(
                geometry.size.width,
                geometry.size.height
            )

            Text(Self.referenceDate - blinkOffset, style: .timer)
                .font(Font.custom("Custom-Regular", size: maxSize))
                .centerLastCharacer(size: maxSize, isInGeometryReader: true)
        }
        .clipped()
    }

}

extension Text {

    /**
     Small extension on `Text` to do three things:
     1) Set a predictable frame size (reserve enough room to
       always show 9 digits of a timer; this makes the rest easier)
     2) Give the last character of the timer a predictable position
       by using a trailing alignment (so that the last character is always
       at the end of the frame, rather than being pushed around depending
       on how many minutes / hours digits are visible)
     3) Shift the entire timer so that the last character is now in the center of the view
     */
    func centerLastCharacer(size: CGFloat, isInGeometryReader: Bool = false) -> some View {
        self
            .frame(width: size * 9, height: size)
            .multilineTextAlignment(.trailing)
            .offset(x: -size * (isInGeometryReader ? 8 : 4))
    }


}

#Preview(as: .systemSmall) {
    AnimatedWidget()
} timeline: {
    AnimatedWidgetEntry()
}
