// FineTune/Views/Settings/Tabs/GeneralTab.swift
import SwiftUI

@MainActor
struct GeneralTab: View {
    @Bindable var settings: SettingsManager
    @Bindable var audioEngine: AudioEngine
    let onResetAll: () -> Void

    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                generalSection
                menuBarSection
                dataSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.never)
        .onChange(of: settings.appSettings.lockInputDevice) { oldValue, newValue in
            if !oldValue && newValue {
                audioEngine.handleInputLockEnabled()
            }
        }
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
            SettingsRowDivider()
            SettingsRow(
                "Auto-switch headphone output",
                description: "Make a newly connected Bluetooth, USB, or headphone device the default output immediately"
            ) {
                Toggle("", isOn: $settings.appSettings.autoSwitchNewHeadphoneOutput)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .labelsHidden()
            }
            SettingsRowDivider()
            SettingsRow(
                "Auto-switch microphone",
                description: "Make a newly connected microphone the default input immediately"
            ) {
                Toggle(
                    "",
                    isOn: Binding(
                        get: { !settings.appSettings.lockInputDevice },
                        set: { settings.appSettings.lockInputDevice = !$0 }
                    )
                )
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
