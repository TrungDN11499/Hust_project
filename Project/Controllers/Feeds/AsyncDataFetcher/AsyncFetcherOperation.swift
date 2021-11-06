//
//  AsyncFetcherOperation.swift
//  Project
//
//  Created by Be More on 07/04/2021.
//

import Foundation
import Kingfisher

class AsyncFetcherOperation: Operation {
    // MARK: Properties

    /// The `UUID` that the operation is fetching data for.
    let identifier: UUID

    /// The `DisplayData` that has been fetched by this operation.
    private(set) var fetchedData: DisplayData?

    // MARK: Initialization

    init(identifier: UUID) {
        self.identifier = identifier
    }

    // MARK: Operation overrides

    override func main() {
        let displayData = DisplayData()
        // Wait for a second to mimic a slow operation.
        guard let url = URL(string: "http://www.riovistajamaica.com/wp-content/uploads/2015/08/2015-12-26-125958.jpg") else {
            return
        }
        let resource = ImageResource(downloadURL: url)
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case .success(let result):
                displayData.image = result.image
            case .failure:
                break
            }
        }
        
        guard !self.isCancelled else { return }
        self.fetchedData = displayData
    }
}
