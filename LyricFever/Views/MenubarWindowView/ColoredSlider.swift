//
//  ColoredSlider.swift
//  Lyric Fever
//

import SwiftUI

final class ColoredSliderCell: NSSliderCell {
    var customKnobColor: NSColor = .white

    override func drawKnob(_ knobRect: NSRect) {
        let diameter = min(knobRect.width, knobRect.height)
        let x = knobRect.midX - diameter / 2
        let y = knobRect.midY - diameter / 2
        let circleRect = NSRect(x: x, y: y, width: diameter, height: diameter)
        let path = NSBezierPath(ovalIn: circleRect)
        customKnobColor.setFill()
        path.fill()
    }

    override func knobRect(flipped: Bool) -> NSRect {
        var rect = super.knobRect(flipped: flipped)
        // ensure square knob rect for a circular knob
        let size = min(rect.width, rect.height)
        rect = NSRect(x: rect.midX - size / 2, y: rect.midY - size / 2,
                      width: size, height: size)
        return rect
    }
}

struct ColoredSlider: NSViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(value: value,
                             minValue: range.lowerBound,
                             maxValue: range.upperBound,
                             target: context.coordinator,
                             action: #selector(Coordinator.sliderChanged))
        let cell = ColoredSliderCell()
        cell.customKnobColor = NSColor(color)
        slider.cell = cell
        slider.trackFillColor = NSColor(color)
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        let newColor = NSColor(color)
        if nsView.trackFillColor != newColor {
            nsView.trackFillColor = newColor
        }
        if let cell = nsView.cell as? ColoredSliderCell,
           cell.customKnobColor != newColor {
            cell.customKnobColor = newColor
            nsView.needsDisplay = true
        }
        if nsView.doubleValue != value {
            nsView.doubleValue = value
        }
    }

    final class Coordinator: NSObject {
        let parent: ColoredSlider

        init(_ parent: ColoredSlider) {
            self.parent = parent
        }

        @objc func sliderChanged(_ sender: NSSlider) {
            parent.value = sender.doubleValue
        }
    }
}
