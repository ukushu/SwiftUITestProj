import Foundation
import Essentials

extension Date {
    var readableString: String {
        let days = self.distance(from: .now, only: .day)
        let timestamp = self.asString(DateFormatter.timeOnlyTemplate)
        
        switch days {
        case 0:
            return "Today\(timestamp)"
        case 1:
            return "Yesterday\(timestamp)"
        default:
            return self.asString(DateFormatter.defaultTemplate) //DateFormatter.shared.string(from: self)
        }
    }
    
    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }
}

fileprivate extension DateFormatter {
    static var shared = getSharedDateFormatter()
    
    static var defaultTemplate: String {
        var dateFormat: String
        
        let lanIdent = Locale.current.identifier.count == 2 ? Locale.current.identifier : Locale.current.identifier.dropFirstCustom(3)
        
        //http://www.lingoes.net/en/translator/langcode.htm
        //https://calendars.fandom.com/wiki/Date_format_by_country
        
        switch lanIdent {
        case "CA":
            fallthrough
        //English (Belize)
        case "BZ":
            fallthrough
        //USA
        case "en":
            fallthrough
        case "US":
            //y-M-dd
            dateFormat = "MM/dd/yyyy, h:mm a"
            
        //china
        case "zh":
            fallthrough
        case "CN":
            fallthrough
        case "HK":
            fallthrough
        case "MO":
            fallthrough
        case "SG":
            fallthrough
        case "TW":
            fallthrough
        // Korea
        case "ko":
            fallthrough
        case "KR":
            fallthrough
        //Hungarian
        case "hu":
            fallthrough
        case "HU":
            fallthrough
        //Japan
        case "ja":
            fallthrough
        case "JP":
            fallthrough
        //Lithuanian (Lithuania)
        case "lt":
            fallthrough
        case "LT":
            fallthrough
        //Basque (Spain)
        case "eu":
            fallthrough
        case "ES":
            fallthrough
        //Albanian
        case "sq":
            fallthrough
        case "AL":
            fallthrough
        //Swahili (Kenya)
        case "sw":
            fallthrough
        case "KE":
            fallthrough
        //Mongolian (Mongolia)
        case "mn":
            fallthrough
        case "MN":
            fallthrough
        // South Africa
        case "af":
            fallthrough
        case "ZA":
            fallthrough
        // IRAQ
        case "fa":
            fallthrough
        case "IR":
            dateFormat = "yyyy/MM/dd, HH:mm"
            
        default:
            dateFormat = "dd/MM/yyyy, HH:mm"
        }
        
//        print("curr local identifier: \(lanIdent)")
//        print("dateFormat: \(dateFormat)")
        
        return dateFormat
    }
    
    static var timeOnlyTemplate: String {
        var dateFormat: String
        
        let lanIdent = Locale.current.identifier.count == 2 ? Locale.current.identifier : Locale.current.identifier.dropFirstCustom(3)
        
        
        switch lanIdent {
        case "CA":
            fallthrough
            //English (Belize)
        case "BZ":
            fallthrough
            //USA
        case "en":
            fallthrough
        case "US":
            dateFormat = ", h:mm a"
            
        default:
            dateFormat = ", HH:mm"
        }
        
        return dateFormat
    }
}

extension Locale {
    static var preferredLanguageCode: String {
        guard let preferredLanguage = preferredLanguages.first,
              let code = Locale(identifier: preferredLanguage).languageCode else {
            return "en"
        }
        return code
    }
    
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({Locale(identifier: $0).languageCode})
    }
}


fileprivate func getSharedDateFormatter(template: String? = nil) -> DateFormatter {
    let df = DateFormatter()
    df.timeZone = .current
    df.dateFormat = template ?? DateFormatter.defaultTemplate
    
    df.amSymbol = "AM"
    df.pmSymbol = "PM"
    
    //debug:
    //print("preffered locale: \(Locale.preferredLanguageCode)")
    
    return df
}


extension Date {
    func rounded(minutes: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        return rounded(seconds: minutes * 60, rounding: rounding)
    }
    func rounded(seconds: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        var roundedInterval: TimeInterval = 0
        switch rounding  {
        case .round:
            roundedInterval = (timeIntervalSinceReferenceDate / seconds).rounded() * seconds
        case .ceil:
            roundedInterval = ceil(timeIntervalSinceReferenceDate / seconds) * seconds
        case .floor:
            roundedInterval = floor(timeIntervalSinceReferenceDate / seconds) * seconds
        }
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
}

enum DateRoundingType {
    case round
    case ceil
    case floor
}
