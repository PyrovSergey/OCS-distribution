//
//  DetailViewController.swift
//  OCS distribution
//
//  Created by Sergey on 24/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    
    var vacancy: Vacancy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vacancy = self.vacancy {
            descriptionTextView.attributedText = parseHtml(htmlString: vacancy.description)
        }
    }
    
    private func parseHtml(htmlString: String) -> NSAttributedString {
        
        let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue)
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        
        return attributedString
    }
}
