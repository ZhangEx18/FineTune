// FineTune/Views/Settings/Components/AccessibilityPromptStrip.swift
import SwiftUI

/// Shows the current Accessibility trust used by media-key control.
@MainActor
struct AccessibilityPromptStrip: View {
    @Bindable var accessibility: AccessibilityPermissionService

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: accessibility.isTrustedCached ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .font(.system(size: 12, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(iconColor)
                .frame(width: 28, alignment: .center)
                .contentTransition(.symbolEffect(.replace))

            Text(LocalizedStringKey(message))
                .font(DesignTokens.Typography.rowDescription)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: DesignTokens.Spacing.xs)

            if accessibility.isTrustedCached {
                grantedPill
            } else {
                Button(action: { accessibility.requestAccess() }) {
                    HStack(spacing: 3) {
                        Text("Grant")
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 9, weight: .medium))
                    }
                    .font(DesignTokens.Typography.pickerText)
                    .foregroundStyle(DesignTokens.Colors.accentPrimary)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Registers FineTune in the Accessibility list and opens System Settings.")
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(
            reduceMotion ? .linear(duration: 0.15) : .spring(response: 0.35, dampingFraction: 0.85),
            value: accessibility.isTrustedCached
        )
    }

    @ViewBuilder
    private var grantedPill: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(DesignTokens.Colors.vuGreen)
                .frame(width: 5, height: 5)
            Text("Granted")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Capsule().fill(DesignTokens.Colors.glassFill))
    }

    private var iconColor: Color {
        accessibility.isTrustedCached ? DesignTokens.Colors.vuGreen : DesignTokens.Colors.accentPrimary
    }

    private var message: String {
        accessibility.isTrustedCached
            ? "Accessibility access is granted."
            : "Media keys need Accessibility. If already allowed but unavailable, remove FineTune in System Settings, add the installed app again, and relaunch."
    }
}
