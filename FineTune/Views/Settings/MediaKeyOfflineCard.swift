// FineTune/Views/Settings/MediaKeyOfflineCard.swift
import SwiftUI

/// Inline card shown when `MediaKeyStatus.isOffline` is `true` (kernel-stall path only;
/// AX revocation surfaces via the permission card instead).
@MainActor
struct MediaKeyOfflineCard: View {
    @Bindable var status: MediaKeyStatus
    let onRetry: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 18, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color(nsColor: .systemOrange))
                .frame(width: DesignTokens.Dimensions.settingsIconWidth, alignment: .center)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.xs) {
                    Text("Media keys offline")
                        .font(DesignTokens.Typography.rowNameBold)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                    Spacer(minLength: DesignTokens.Spacing.xs)
                }

                Text(message)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onRetry) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .medium))
                        Text("Retry")
                    }
                    .font(DesignTokens.Typography.pickerText)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                }
                .buttonStyle(.plain)
                .glassButtonStyle()
                .padding(.top, 2)
                .accessibilityHint("Reinstalls the media-key event tap.")
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                .strokeBorder(Color(nsColor: .systemOrange).opacity(0.35), lineWidth: 0.5)
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Media keys offline. Retry to reinstall the event tap.")
    }

    private var message: String {
        switch status.failureReason {
        case .eventTapCreation:
            "FineTune 无法创建媒体键监听器。请确认已允许辅助功能权限，然后重试。"
        case .disabledBySystem, .none:
            "系统禁用了 FineTune 的媒体键监听器，通常发生在睡眠唤醒或系统卡顿后。重试即可重新安装。"
        }
    }
}

// MARK: - Previews

#Preview("Offline Card") {
    PreviewContainer {
        MediaKeyOfflineCard(status: MediaKeyStatus(), onRetry: {})
            .frame(width: 420)
            .padding()
    }
}
