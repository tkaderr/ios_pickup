//
//  delegates.swift
//  pick up
//
//  Created by KYLE C BIBLE on 5/18/17.
//  Copyright © 2017 KYLE C BIBLE. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol AddEventViewControllerDelegate: class {
    func cancelButtonPressed (by controller: UIViewController)
    func doneButtonPressed (by controller: UIViewController, data: (String, String, String, String))
}
