@MainActor
protocol AudioProcessMonitoring: AnyObject {
    var activeApps: [AudioApp] { get }
    /// Apps previously observed producing audio that are still running but currently paused.
    var inactiveApps: [AudioApp] { get }
    var onAppsChanged: (([AudioApp]) -> Void)? { get set }

    func start()
    func stop()
}
