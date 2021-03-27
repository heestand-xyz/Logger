import Foundation

public struct Logger {
    
    public static var prefix: String = "Log"
    
    public enum Level {
        
        case info
        case warning
        case error(Error)
        
        var label: String {
            switch self {
            case .info:
                return "Info"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            }
        }
        
        var error: Error? {
            switch self {
            case .error(let error):
                return error
            default:
                return nil
            }
        }
    }
    
    public static func log(level: Level = .info, message: String? = nil, filePath: String = #file, funcName: String = #function) {
        
        let fileName: String = String(filePath.split(separator: "/").last?.split(separator: ".").first ?? "")
        
        var log: String = "\(prefix) \(level.label) \(fileName) \(funcName)"
        
        if let message: String = message {
            log += " \"\(message)\""
        }
        if let error: Error = level.error {
            log += " Error: \(String(describing: error))"
        }
        
        print(log)
    }
}
