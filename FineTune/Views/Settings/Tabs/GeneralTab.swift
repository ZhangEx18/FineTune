// FineTune/Views/Settings/Tabs/GeneralTab.swift
import AppKit
import AVFoundation
import SwiftUI

@MainActor
struct GeneralTab: View {
    @Bindable var settings: SettingsManager
    @Bindable var permission: AudioRecordingPermission
    @Bindable var accessibility: AccessibilityPermissionService
    let onResetAll: () -> Void

    @State private var showResetConfirmation = false
    @State private var microphoneAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                generalSection
                permissionsSection
                menuBarSection
                dataSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.never)
        .confirmationDialog(
            "Reset all settings?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) { onResetAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .onAppear { refreshMicrophoneAuthorization() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshMicrophoneAuthorization()
        }
    }

    // MARK: - Permissions

    private var permissionsSection: some View {
        SettingsSection("权限") {
            SettingsRow(
                "辅助功能",
                description: "拦截 F10、F11、F12 媒体键"
            ) {
                permissionStatus(accessibility.isTrustedCached)
                Button("打开设置") {
                    accessibility.requestAccess()
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignTokens.Colors.accentPrimary)
            }
            SettingsRowDivider()
            SettingsRow(
                "音频采集",
                description: "控制单个应用音量和路由时需要"
            ) {
                permissionStatus(permission.status == .authorized)
                Button("打开设置") {
                    if permission.status == .denied {
                        openAudioCaptureSettings()
                    } else {
                        permission.request()
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignTokens.Colors.accentPrimary)
            }
            SettingsRowDivider()
            SettingsRow(
                "麦克风",
                description: "处理输入设备音频时需要"
            ) {
                permissionStatus(microphoneGranted)
                Button("打开设置") {
                    requestMicrophoneAccess()
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignTokens.Colors.accentPrimary)
            }
        }
    }

    private var microphoneGranted: Bool {
        microphoneAuthorizationStatus == .authorized
    }

    private func permissionStatus(_ granted: Bool) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(granted ? DesignTokens.Colors.vuGreen : DesignTokens.Colors.textTertiary)
                .frame(width: 6, height: 6)
            Text(granted ? "已允许" : "未允许")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
    }

    private func openAudioCaptureSettings() {
        let url = "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture"
        if let settingsURL = URL(string: url) {
            NSWorkspace.shared.open(settingsURL)
        }
    }

    private func requestMicrophoneAccess() {
        if microphoneAuthorizationStatus == .denied || microphoneAuthorizationStatus == .restricted {
            let url = "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
            if let settingsURL = URL(string: url) {
                NSWorkspace.shared.open(settingsURL)
            }
            return
        }
        AVCaptureDevice.requestAccess(for: .audio) { _ in
            Task { @MainActor in
                refreshMicrophoneAuthorization()
            }
        }
    }

    private func refreshMicrophoneAuthorization() {
        microphoneAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    }

    // MARK: - General

    private var generalSection: some View {
        SettingsSection("General") {
            SettingsRow(
                "Launch at Login",
                description: "Start FineTune when you log in"
            ) {
                Toggle("", isOn: $settings.appSettings.launchAtLogin)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .labelsHidden()
            }
            SettingsRowDivider()
            SettingsRow(
                "Theme",
                description: "Match macOS, or lock to Light or Dark"
            ) {
                ThemeTilePicker(selection: $settings.appSettings.appearance)
            }
            SettingsRowDivider()
            SettingsRow(
                "Device Disconnect Alerts",
                description: "Show notification when an audio device disconnects"
            ) {
                Toggle("", isOn: $settings.appSettings.showDeviceDisconnectAlerts)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .labelsHidden()
            }
        }
    }

    // MARK: - Menu Bar

    private var menuBarSection: some View {
        SettingsSection("Menu Bar") {
            SettingsRow(
                "Icon Style",
                description: "How FineTune appears in your menu bar"
            ) {
                IconStyleSegmentedControl(selection: $settings.appSettings.menuBarIconStyle)
            }
            SettingsRowDivider()
            SettingsRow(
                "Popup Size",
                description: "Smaller fits more on screen; larger leaves more breathing room."
            ) {
                PopupSizeTilePicker(selection: $settings.appSettings.popupSize)
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        SettingsSection("Data") {
            SettingsRow(
                "Reset All Settings",
                description: "Clear all volumes, EQ, and device routings"
            ) {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Text("Reset")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.small)
            }
        }
    }
}
