//
//  WidgetSetup.swift
//  WidgetAnimation
//
//  Created by Bryce Pauken on 5/10/25.
//

import SwiftUI
import WidgetKit

// This file contains Widget boilerplate that isn't super interesting for the animation

struct AnimatedWidgetEntry: TimelineEntry {

    var date: Date

    init(date: Date = Date()) {
        self.date = date
    }

}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> AnimatedWidgetEntry {
        AnimatedWidgetEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (AnimatedWidgetEntry) -> ()) {
        completion(AnimatedWidgetEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AnimatedWidgetEntry>) -> ()) {
        completion(Timeline(entries: [AnimatedWidgetEntry()], policy: .never))
    }

}

struct AnimatedWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

