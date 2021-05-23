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
    
    struct Log {
        let level: Level
        let message: String?
        let arguments: [String: Any?]
        let filePath: String
        let funcName: String
    }
    
    public class PreLog {
        let log: Log
        var cancelled: Bool = false
        init(log: Log) {
            self.log = log
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard !self.cancelled else { return }
                Logger.log(log, timeout: true)
            }
        }
        func cancel() {
            cancelled = true
        }
    }
    
    public static func preLog(level: Level = .info, message: String? = nil, arguments: [String: Any?] = [:], filePath: String = #file, funcName: String = #function) -> PreLog {
        PreLog(log: Log(level: level, message: message, arguments: arguments, filePath: filePath, funcName: funcName))
    }
    
    public static func postLog(_ preLog: PreLog) {
        preLog.cancel()
        log(preLog.log)
    }
    
    public static func log(level: Level = .info, message: String? = nil, arguments: [String: Any?] = [:], filePath: String = #file, funcName: String = #function) {
        log(Log(level: level, message: message, arguments: arguments, filePath: filePath, funcName: funcName))
    }
    private static func log(_ log: Log, timeout: Bool = false) {

//        let fileName: String = String(filePath.split(separator: "/").last?.split(separator: ".").first ?? "")
        let fileName: String = log.filePath.components(separatedBy: "Sources/").last ?? ""
        
        var text: String = "\(prefix) \(log.level.label) \(fileName) > \(log.funcName)"
        
        if let message: String = log.message {
            text += " <> \"\(message)\""
        }
        if !log.arguments.isEmpty {
            text += " <> [ "
            for (i, argument) in log.arguments.enumerated() {
                if i > 0 {
                    text += ", "
                }
                var arg: String? = nil
                if let value: Any = argument.value {
                    arg = String(describing: value)
                }
                text += "\(argument.key): \(arg ?? "nil")"
            }
            text += " ]"
        }
        if let error: Error = log.level.error {
            text += " <<>> Error: \(String(describing: error))"
        }
        if timeout {
            text += " [TIMEOUT]"
        }
        
        print(text)
    }
}
