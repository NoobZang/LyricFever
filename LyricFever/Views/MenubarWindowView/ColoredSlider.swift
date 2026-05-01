//
//  ColoredSlider.swift
//  Lyric Fever
//

import SwiftUI

final class ColoredSliderCell: NSSliderCell {
    var sliderColor: NSColor = .white

    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let trackHeight: CGFloat = 4
        let trackRect = NSRect(
            x: rect.minX,
            y: rect.midY - trackHeight / 2,
            width: rect.width,
            height: trackHeight
        )
        let backgroundPath = NSBezierPath(
            roundedRect: trackRect,
            xRadius: trackHeight / 2,
            yRadius: trackHeight / 2
        )
        sliderColor.withAlphaComponent(0.28).setFill()
        backgroundPath.fill()

        let valueRange = maxValue - minValue
        guard valueRange > 0 else { return }

        let ratio = min(max((doubleValue - minValue) / valueRange, 0), 1)
        let fillWidth = trackRect.width * CGFloat(ratio)
        guard fillWidth > 0 else { return }

        let fillRect = NSRect(
            x: trackRect.minX,
            y: trackRect.minY,
            width: fillWidth,
            height: trackRect.height
        )
        let fillPath = NSBezierPath(
            roundedRect: fillRect,
            xRadius: trackHeight / 2,
            yRadius: trackHeight / 2
        )
        sliderColor.setFill()
        fillPath.fill()
    }

    override func drawKnob(_ knobRect: NSRect) {
        let diameter = min(knobRect.width, knobRect.height)
        let x = knobRect.midX - diameter / 2
        let y = knobRect.midY - diameter / 2
        let circleRect = NSRect(x: x, y: y, width: diameter, height: diameter)
        let path = NSBezierPath(ovalIn: circleRect)
        sliderColor.setFill()
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
        let slider = NSSlider(
            value: clampedValue,
            minValue: range.lowerBound,
            maxValue: range.upperBound,
            target: context.coordinator,
            action: #selector(Coordinator.sliderChanged)
        )
        let cell = ColoredSliderCell()
        cell.sliderColor = NSColor(color)
        slider.cell = cell
        configure(slider, coordinator: context.coordinator)
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        let newColor = NSColor(color)
        context.coordinator.parent = self
        configure(nsView, coordinator: context.coordinator)
        if let cell = nsView.cell as? ColoredSliderCell,
           cell.sliderColor != newColor {
            cell.sliderColor = newColor
            nsView.needsDisplay = true
        }
    }

    private func configure(_ slider: NSSlider, coordinator: Coordinator) {
        slider.minValue = range.lowerBound
        slider.maxValue = range.upperBound
        slider.target = coordinator
        slider.action = #selector(Coordinator.sliderChanged)
        slider.doubleValue = clampedValue
        slider.isContinuous = true
    }

    private var clampedValue: Double {
        min(max(value, range.lowerBound), range.upperBound)
    }

    final class Coordinator: NSObject {
        var parent: ColoredSlider

        init(_ parent: ColoredSlider) {
            self.parent = parent
        }

        @objc func sliderChanged(_ sender: NSSlider) {
            parent.value = sender.doubleValue
        }
    }
}
