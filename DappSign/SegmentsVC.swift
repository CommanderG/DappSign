//
//  SegmentsVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 5/2/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

enum Segment {
    case PetitionsSubmitted
    case PetitionsSigned
}

protocol SegmentsDelegate {
    func didSelectSegment(segment: Segment)
}

class SegmentsVC: UIViewController {
    internal static let embedSegueID = "embedSegmentsVC"
    
    internal var delegate: SegmentsDelegate? = nil
    internal private(set) var selectedSegment: Segment = .PetitionsSubmitted
    
    @IBOutlet weak var petitionsSubmittedButton: UIButton!
    @IBOutlet weak var petitionsSignedButton: UIButton!
    @IBOutlet weak var petitionsSubmittedButtonHeightLC: NSLayoutConstraint!
    @IBOutlet weak var petitionsSignedButtonHeightLC: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.initButton(self.petitionsSubmittedButton)
        self.initButton(self.petitionsSignedButton)
        
        self.selectedSegment = .PetitionsSubmitted
        
        self.selectPetitionsSubmittedButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    
    private func initButton(button: UIButton) {
        button.layer.cornerRadius = 2.0
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2.0
    }
    
    private func selectSegment(segment: Segment) {
        if self.selectedSegment == segment {
            return
        }
        
        switch segment {
        case .PetitionsSubmitted:
            self.selectPetitionsSubmittedButton()
        case .PetitionsSigned:
            self.selectPetitionsSignedButton()
        }
        
        self.selectedSegment = segment
        
        self.delegate?.didSelectSegment(segment)
    }
    
    private func selectPetitionsSubmittedButton() {
        self.selectButton(self.petitionsSubmittedButton)
        self.deselectButton(self.petitionsSignedButton)
        
        self.petitionsSubmittedButtonHeightLC.constant = 40.0
        self.petitionsSignedButtonHeightLC.constant = 36.0
    }
    
    private func selectPetitionsSignedButton() {
        self.selectButton(self.petitionsSignedButton)
        self.deselectButton(self.petitionsSubmittedButton)
        
        self.petitionsSubmittedButtonHeightLC.constant = 36.0
        self.petitionsSignedButtonHeightLC.constant = 40.0
    }
    
    private func selectButton(button: UIButton) {
        let color = UIColor(red: 0.0, green: 118.0 / 255.0, blue: 1.0, alpha: 1.0)
        
        button.backgroundColor = color
    }
    
    private func deselectButton(button: UIButton) {
        let color = UIColor.clearColor()
        
        button.backgroundColor = color
    }
    
    // MARK: - IBActions
    
    @IBAction func handlePetitionsSubmittedButtonTap() {
        self.selectSegment(.PetitionsSubmitted)
    }
    
    @IBAction func handlePetitionsSignedButtonTap() {
        self.selectSegment(.PetitionsSigned)
    }
}
