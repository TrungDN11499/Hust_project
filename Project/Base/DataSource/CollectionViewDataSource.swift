//
//  CollectionViewDataSource.swift
//  Project
//
//  Created by Be More on 30/03/2021.
//

import UIKit

class CollectionViewDataSource<CellType, ViewModel>: NSObject, UICollectionViewDataSource where CellType: BaseCollectionViewCell {
    
    var items: [ViewModel]
    
    let configureCell: (CellType, ViewModel) -> ()
    
    func updateItem(_ vm: [ViewModel]) {
        self.items = vm
    }
    
    init(vm: [ViewModel], configure: @escaping (CellType, ViewModel) -> ()) {
        self.items = vm
        self.configureCell = configure
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = CellType.loadCell(collectionView, indexPath: indexPath) as? CellType else {
            return CellType()
        }
        let vm = self.items[indexPath.row]
        self.configureCell(cell, vm)
        return cell
    }
    
}
