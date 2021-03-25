//
//  TableViewDataSource.swift
//  Project
//
//  Created by Be More on 9/29/20.
//

import UIKit

class TableViewDataSource<CellType, ViewModel>: NSObject, UITableViewDataSource where CellType: BaseTableViewCell {
    
    var items: [ViewModel]
    
    let configureCell: (CellType, ViewModel) -> ()
    
    func updateItem(_ vm: [ViewModel]) {
        self.items = vm
    }
    
    init(vm: [ViewModel], configure: @escaping (CellType, ViewModel) -> ()) {
        self.items = vm
        self.configureCell = configure
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = CellType.loadCell(tableView, indexPath: indexPath) as? CellType else {
            return CellType()
        }
        let vm = self.items[indexPath.row]
        self.configureCell(cell, vm)
        return cell
    }
}
