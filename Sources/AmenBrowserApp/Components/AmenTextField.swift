import SwiftUI
import AppKit

struct AmenTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var font: NSFont = .systemFont(ofSize: 14, weight: .medium)
    var textColor: NSColor = .labelColor
    var accentColor: NSColor = NSColor(calibratedRed: 0.39, green: 0.67, blue: 0.31, alpha: 1.0)
    var isFirstResponder: Bool = false
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = AmenNSTextField()
        textField.delegate = context.coordinator
        textField.font = font
        textField.textColor = textColor
        textField.placeholderAttributedString = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: NSColor.secondaryLabelColor,
                .font: font
            ]
        )
        textField.backgroundColor = .clear
        textField.isBordered = false
        textField.focusRingType = .none
        textField.lineBreakMode = .byTruncatingTail
        textField.allowsDefaultTighteningForTruncation = true
        textField.target = context.coordinator
        textField.action = #selector(Coordinator.commitAction)

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        context.coordinator.parent = self
        if nsView.stringValue != text {
            nsView.stringValue = text
        }

        if let editor = nsView.window?.fieldEditor(true, for: nsView) as? NSTextView {
            editor.insertionPointColor = accentColor
        }

        if isFirstResponder {
            if nsView.window?.firstResponder !== nsView {
                nsView.window?.makeFirstResponder(nsView)
            }
        } else if nsView.window?.firstResponder === nsView {
            nsView.window?.makeFirstResponder(nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: AmenTextField

        init(_ parent: AmenTextField) {
            self.parent = parent
        }

        func controlTextDidBeginEditing(_ obj: Notification) {
            parent.onEditingChanged(true)
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            parent.text = field.stringValue
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            parent.onEditingChanged(false)
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            switch commandSelector {
            case #selector(NSResponder.insertNewline(_:)):
                parent.onCommit()
                return true
            case #selector(NSResponder.cancelOperation(_:)):
                parent.onEditingChanged(false)
                return true
            default:
                return false
            }
        }

        @objc func commitAction() {
            parent.onCommit()
        }
    }
}

private final class AmenNSTextField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result, let editor = currentEditor() as? NSTextView {
            editor.isRichText = false
            editor.importsGraphics = false
        }
        return result
    }
}
