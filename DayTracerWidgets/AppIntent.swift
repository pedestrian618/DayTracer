//
//  AppIntent.swift
//  DayTracerWidgets
//
//  Created by murate on 2023/12/02.
//

import WidgetKit
import AppIntents

enum ColorOption: String, CaseIterable, AppEnum {
    case red = "🟥Red"
    case green = "🟩Green"
    case blue = "🟦Blue"
    case yellow = "🟨Yellow"
    case purple = "🟪Purple"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Color Options"

    static var caseDisplayRepresentations: [ColorOption : DisplayRepresentation] = [
        .red: DisplayRepresentation(title: LocalizedStringResource("🟥Red")),
        .green: DisplayRepresentation(title: LocalizedStringResource("🟩Green")),
        .blue: DisplayRepresentation(title: LocalizedStringResource("🟦Blue")),
        .yellow: DisplayRepresentation(title: LocalizedStringResource("🟨Yellow")),
        .purple: DisplayRepresentation(title: LocalizedStringResource("🟪Purple"))
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Customize Widget"
    static var description = IntentDescription("Customize the color of your widget.")

    @Parameter(title: "Select Main Color", default: ColorOption.blue)
    var selectedColor: ColorOption

    @Parameter(title: "Select Sub Color", default: ColorOption.yellow)
    var selectedSubColor: ColorOption

    static var parameterSummary: some ParameterSummary {
        Summary("Main color set to \(\.$selectedColor), sub color set to \(\.$selectedSubColor).")
    }
}
