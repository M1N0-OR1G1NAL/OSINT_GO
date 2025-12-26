import Foundation

enum SearchType: String, CaseIterable, Identifiable, Hashable {
    case domain = "Doména"
    case ip = "IP adresa"
    case username = "Uživatelské jméno"
    case email = "E-mail"
    case phone = "Telefonní číslo"
    case ico = "IČO"
    case address = "Adresa"
    case uvid = "UVID / jiné ID"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

struct OSINTURLBuilder {
        // Build a list of URL strings based on the selected type and value.
        // This mirrors the AppleScript templates attached in the workspace.

    static func buildUrls(for type: SearchType, value: String) -> [URL] {
        let q = urlEncode(value)
        let v = value
        var urls: [URL] = []

        func append(_ str: String) {
            if let u = URL(string: str) {
                urls.append(u)
            }
        }

            // universal search engines
        append("https://www.google.com/search?q=\(q)")
        append("https://duckduckgo.com/?q=\(q)")
        append("https://www.bing.com/search?q=\(q)")
        append("https://search.seznam.cz/?q=\(q)")
        append("https://search.yahoo.com/search?p=\(q)")

        switch type {
        case .domain:
            append("https://crt.sh/?q=\(q)")
            append("https://viewdns.info/dnsreport/?domain=\(v)")
            append("https://viewdns.info/reverseip/?host=\(v)&t=1")
            append("https://securitytrails.com/domain/\(v)")
            append("https://urlscan.io/search/#\(q)")
            append("https://mxtoolbox.com/SuperTool.aspx?action=mx%3a\(v)&run=toolpage")
            append("https://www.virustotal.com/gui/domain/\(v)")
            append("https://www.shodan.io/search?query=\(q)")
            append("https://search.censys.io/search?resource=hosts&q=\(q)")
        case .ip:
            append("https://viewdns.info/ipinfo/?ip=\(v)")
            append("https://viewdns.info/iplocation/?ip=\(v)")
            append("https://ipinfo.io/\(v)")
            append("https://rdap.arin.net/registry/ip/\(v)")
            append("https://www.virustotal.com/gui/ip-address/\(v)")
            append("https://www.shodan.io/host/\(v)")
            append("https://search.censys.io/hosts/\(v)")
            append("https://scamalytics.com/ip")
        case .username:
            let handle = v
            let encHandle = q
            append("https://github.com/\(handle)")
            append("https://x.com/search?q=\(encHandle)&f=user")
            append("https://www.facebook.com/search/top/?q=\(encHandle)")
            append("https://www.instagram.com/\(handle)/")
            append("https://www.tiktok.com/@\(handle)")
            append("https://www.linkedin.com/search/results/all/?keywords=\(encHandle)")
            append("https://www.youtube.com/results?search_query=\(encHandle)")
        case .email:
            append("https://www.google.com/search?q=\(q)%20\"email\"")
            append("https://duckduckgo.com/?q=\(q)%20\"email\"")
            append("https://github.com/search?q=\(q)")
            append("https://pastebin.com/search?q=\(q)")

            if let atRange = v.range(of: "@") {
                let domain = String(v[atRange.upperBound...])
                let mailDomEnc = urlEncode(domain)
                append("https://www.google.com/search?q=site:outlook.com%20\(mailDomEnc)")
                append("https://www.google.com/search?q=site:icloud.com%20\(mailDomEnc)")
                append("https://www.google.com/search?q=site:yahoo.com%20\(mailDomEnc)")
            }

            append("https://haveibeenpwned.com/")
        case .phone:
            append("https://www.google.com/search?q=\(q)%20telefon")
            append("https://duckduckgo.com/?q=\(q)%20telefon")
            append("https://www.kdomivolal.cz/?q=\(v)")
            append("https://www.kdomivolal.eu/hledat/\(v)")
            append("https://www.vyhledatcislo.cz/\(v)")
        case .ico:
            append("https://www.google.com/search?q=I%C4%8CO%20\(q)")
            append("https://duckduckgo.com/?q=I%C4%8CO%20\(q)")
            append("https://or.justice.cz/ias/ui/rejstrik-%24%C3%BUsel?ico=\(v)")
            append("https://resdata.cz/ico/\(v)")
            append("https://rejstrik-firem.kurzy.cz/ico/\(v)")
            append("https://ares.gov.cz/")
        case .address:
            append("https://www.google.com/maps/search/\(q)")
            append("https://mapy.cz/zakladni?q=\(q)")
        case .uvid:
            append("https://www.google.com/search?q=\(q)")
            append("https://duckduckgo.com/?q=\(q)")
            append("https://www.google.com/search?q=\(q)%20p%C3%A1tr%C3%A1n%C3%AD%20po%20osob%C3%A1ch")
        }

            // for sensitive types, add person-search query
        if [.phone, .address, .uvid, .email].contains(type) {
            append("https://www.google.com/search?q=\(q)%20p%C3%A1tr%C3%A1n%C3%AD%20po%20osob%C3%A1ch")
        }

        return urls
    }

    static func urlEncode(_ s: String) -> String {
        return s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
    }

    static func buildUrls(from inputs: [SearchType: String]) -> [URL] {
        var out: [URL] = []
        for (type, value) in inputs {
            let u = buildUrls(for: type, value: value)
            out.append(contentsOf: u)
        }
        return out
    }
}
