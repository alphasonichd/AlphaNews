//
//  UITableView+Extension.swift
//  AlphaNews
//
//  Created by developer on 25.05.21.
//

import UIKit

extension UITableView {
    func register(cellClass: UITableViewCell.Type) {
        self.register(UINib(nibName: cellClass.identifier, bundle: nil), forCellReuseIdentifier: cellClass.identifier)
    }
    
    func register(cellClasses: [UITableViewCell.Type]) {
        cellClasses.forEach { cellType in
            self.register(cellClass: cellType)
        }
    }
    
    func register(headerFooterClass: UITableViewHeaderFooterView.Type) {
        self.register(UINib(nibName: headerFooterClass.identifier, bundle: nil), forCellReuseIdentifier: headerFooterClass.identifier)
    }
}
