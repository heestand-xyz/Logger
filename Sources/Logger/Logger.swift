import Foundation
import Collections

public struct Logger {
    
    public enum Frequency: Int {
        case regular
        case verbose
        case loop
    }
    
    public static var frequency: Frequency = .regular
    
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
        let frequency: Frequency
        let message: String?
        let arguments: OrderedDictionary<String, Any?>
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
    
    public static func preLog(_ level: Level = .info, message: String? = nil, arguments: OrderedDictionary<String, Any?> = [:], frequency: Frequency = .regular, filePath: String = #file, funcName: String = #function) -> PreLog {
        PreLog(log: Log(level: level, frequency: frequency, message: message, arguments: arguments, filePath: filePath, funcName: funcName))
    }
    
    public static func postLog(_ preLog: PreLog) {
        preLog.cancel()
        log(preLog.log)
    }
    
    public static func log(_ level: Level = .info, message: String? = nil, arguments: OrderedDictionary<String, Any?> = [:], frequency: Frequency = .regular, filePath: String = #file, funcName: String = #function) {
        log(Log(level: level, frequency: frequency, message: message, arguments: arguments, filePath: filePath, funcName: funcName))
    }
    private static func log(_ log: Log, timeout: Bool = false) {
        
        #if DEBUG
        
        guard log.frequency.rawValue <= Self.frequency.rawValue else { return }
        
//        var fileName: String = log.filePath.components(separatedBy: "code/").last ?? ""
//        if fileName.contains("App/Sources/") {
//            fileName = "App " + (fileName.components(separatedBy: "App/Sources/").last ?? "")
//        } else if fileName.contains("Sources/") {
//            fileName = "Package " + (fileName.components(separatedBy: "Sources/").last ?? "")
//        }
        let fileName: String = String(log.filePath.split(separator: "/").last ?? "")
        
        var text: String = "\(log.level.label) \(fileName) > \(log.funcName) >>>"
        
        if let message: String = log.message {
            text += " \"\(message)\""
        }
        if !log.arguments.isEmpty {
            text += " [ "
            for (i, argument) in log.arguments.enumerated() {
                if i > 0 {
                    text += ", "
                }
                var arg: String? = nil
                if let value: Any = argument.value {
                    if let string = value as? String {
                        arg = "\"\(string)\""
                    } else {
                        arg = String(describing: value)
                    }
                }
                text += "\(argument.key): \(arg ?? "nil")"
            }
            text += " ]"
        }
        if let error: Error = log.level.error {
            text += " <<!>> Error: \(error.localizedDescription) <!> \(String(describing: error))"
        }
        if timeout {
            text += " [TIMEOUT]"
        }
        
        print(text)
        
        #endif
    }
}
