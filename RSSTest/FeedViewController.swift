//
//  ViewController.swift
//  RSSTest
//
//  Created by Надежда Возна on 05.12.2019.
//  Copyright © 2019 Надежда Возна. All rights reserved.
//

import UIKit
import CoreData

class FeedViewController: UITableViewController {
    
    private var xmlParser = XMLParser()
    private var items: [Item] = []
    private var itemTitle = String()
    private var itemLink = String()
    private var itemDate = String()
    private var itemDescription = String()
    private var elementName: String?
    private var fullURL: String?
    private var scanner = Scanner()
    public var source = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rssResponse()
    }
    
    //RSS Response
    public func rssResponse() {
        if let url = URL(string: source) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                parser.parse()
            } else {
                print("failed to parse")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.pubDate
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let descriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionViewController
        let item = items[indexPath.row]
        descriptionVC.titleMore = item.title
        descriptionVC.descriptionMore = item.description
        self.navigationController?.pushViewController(descriptionVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - RSS Parser

extension FeedViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        print("did start")
        if elementName == "item" {
            itemTitle = String()
            itemLink = String()
            itemDate = String()
            itemDescription = String()
        }
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
            let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (!data.isEmpty) {
                switch elementName {
                case "title":
                    itemTitle += data
                case "link":
                    itemLink += data
                case "pubDate":
                    itemDate += data
                case "description":
                    
                    let str = data.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    let str2 = str.replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression, range: nil)
//                    var str2 = String()
//                    if
//                        let hashtag = str.range(of: "&"),
//                        let word = str.range(of: " ", range: hashtag.upperBound..<str.endIndex)
//                    {
//                        let hashtagWord = str[hashtag.upperBound..<word.upperBound]
//                        str2 = String(hashtagWord)
//                        if let range = str.range(of: str2) {
//                           str.removeSubrange(range)
//                        }
////                        print(str2)
//                    } else {
//                        if
//                            let hashtag = str.range(of: "more"),
//                            let word = str.range(of: " ", range: hashtag.upperBound..<str.endIndex)
//                        {
//                            let hashtagWord = str[hashtag.upperBound..<word.upperBound]
//                            str2 = String(hashtagWord)
//                            if let range = str.range(of: str2) {
//                               str.removeSubrange(range)
//                            }
////                            print(str2)
//                        }
//                    }
                    
//                    do {
//                        let img = try NSRegularExpression(pattern: "(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?", options: .caseInsensitive)
//                        let matches = img.matches(in: itemDescription, options: [], range: NSRange(location: 0, length: itemDescription.utf16.count))
//
//                        if let match = matches.first {
//                            let range = match.range(at:1)
//                            if let swiftRange = Range(range, in: itemDescription) {
//                                let name = itemDescription[swiftRange]
//                                print("name \(name)")
//                            }
//                        }
//                    } catch {
//                        print("error")
//                    }
                    
                    itemDescription += str2
//                    print("\(str)")
                default:
                    print("news")
                }
            }
        }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("failure error: ", parseError)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let item = Item(title: itemTitle, link: itemLink, pubDate: itemDate, description: itemDescription)
            items.append(item)
        }
    }
}

extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func slices(from: String, to: String) -> [Substring] {
        let pattern = "(?<=" + from + ").*?(?=" + to + ")"
        return ranges(of: pattern, options: .regularExpression)
            .map{ self[$0] }
    }
}
