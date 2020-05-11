//
//  QuestionSymptomsViewController.swift
//  Sonar
//
//  Created by NHSX on 23/04/2020.
//  Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class QuestionSymptomsViewController: UIViewController, Storyboarded {
    static var storyboardName = "SelfDiagnosis"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var errorLabel: AccessibleErrorLabel!
    @IBOutlet weak var yesButton: AnswerButton!
    @IBOutlet weak var noButton: AnswerButton!
    @IBOutlet weak var questionButton: PrimaryButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var buttonAction: ((Bool) -> Void)!
    var questionState: Bool?
    
    var pageNumber: Int!
    var pageCount: Int!
    var questionTitle: String!
    var questionDetail: String!
    var questionError: String!
    var questionYes: String!
    var questionNo: String!
    var buttonText: String!
    
    func inject(
        pageNumber: Int,
        pageCount: Int,
        questionTitle: String,
        questionDetail: String,
        questionError: String,
        questionYes: String,
        questionNo: String,
        buttonText: String,
        buttonAction: @escaping (Bool) -> Void
    ) {        
        self.pageNumber = pageNumber
        self.pageCount = pageCount
        self.questionTitle = questionTitle
        self.questionDetail = questionDetail
        self.questionError = questionError
        self.questionYes = questionYes
        self.questionNo = questionNo
        self.buttonText = buttonText
        self.buttonAction = buttonAction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageLabel.text = "\(pageNumber!)/\(pageCount!)"
        pageLabel.accessibilityLabel = "Step \(pageNumber!) of \(pageCount!)"
        titleLabel.text = questionTitle
        detailLabel.text = questionDetail
        detailLabel.textColor = UIColor(named: "NHS Secondary Text")
        errorLabel.text = questionError
        yesButton.text = questionYes
        noButton.text = questionNo
        questionButton.setTitle(buttonText, for: .normal)
        yesButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedYes)))
        noButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedNo)))
    }
    
    @objc func longPressedYes(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.ended {
            yesButton.layer.borderWidth = 2
            yesButton.layer.borderColor = UIColor(named: "NHS Highlight")!.withAlphaComponent(0.96).cgColor
        } else {
            yesTapped(self)
        }
    }
    
    @objc func longPressedNo(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.ended {
            noButton.layer.borderWidth = 2
            noButton.layer.borderColor = UIColor(named: "NHS Highlight")!.withAlphaComponent(0.96).cgColor
        } else {
            noTapped(self)
        }
    }
    
    @IBAction func yesTapped(_ sender: Any) {
        yesButton.isSelected = true
        noButton.isSelected = false
        questionState = true
    }
    
    @IBAction func noTapped(_ sender: Any) {
        yesButton.isSelected = false
        noButton.isSelected = true
        questionState = false
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        guard let state = questionState else {
            scroll(after: {
                self.errorLabel.isHidden = false
            }, to: errorLabel)
            return
        }
        buttonAction(state)
    }
    
}
