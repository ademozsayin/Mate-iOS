import Foundation

/// Defines all actions supported by `SystemPluginStore`
///
public enum SystemStatusAction: Action {

    /// Fetch system status report 
    ///
    case fetchSystemStatusReport(onCompletion: (Result<SystemStatus, Error>) -> Void)
}
