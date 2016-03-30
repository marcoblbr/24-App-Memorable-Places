//
//  NewAlertController.swift
//  23 - App Memorable Places
//
//  Created by Marco on 7/31/15.
//  Copyright (c) 2015 Marco. All rights reserved.
//

import UIKit

// essa classe extende o alert controller padrão para que tenhamos acesso ao método viewDidAppear
class NewAlertController : UIAlertController {
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear (animated)
        
        // estou usando um for pois na declaração existem vários textfields. mas apenas o 1o é selecionado
        for textField in self.textFields!
        {
            textField.selectAll(self)
            
            break
        }
    }    
}
