//
//  DayTracerWidgetsLiveActivity.swift
//  DayTracerWidgets
//
//  Created by murate on 2023/12/02.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DayTracerWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DayTracerWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DayTracerWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DayTracerWidgetsAttributes {
    fileprivate static var preview: DayTracerWidgetsAttributes {
        DayTracerWidgetsAttributes(name: "World")
    }
}

extension DayTracerWidgetsAttributes.ContentState {
    fileprivate static var smiley: DayTracerWidgetsAttributes.ContentState {
        DayTracerWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DayTracerWidgetsAttributes.ContentState {
         DayTracerWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DayTracerWidgetsAttributes.preview) {
   DayTracerWidgetsLiveActivity()
} contentStates: {
    DayTracerWidgetsAttributes.ContentState.smiley
    DayTracerWidgetsAttributes.ContentState.starEyes
}
