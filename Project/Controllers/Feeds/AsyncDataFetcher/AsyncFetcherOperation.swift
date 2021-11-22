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
    private(set) var fetchedData: FeedViewModel?
    private(set) var data: FeedViewModel
    // MARK: Initialization

    init(identifier: UUID, fetchData: FeedViewModel) {
        self.identifier = identifier
        self.data = fetchData
    }

    // MARK: Operation overrides
    override func main() {
        let displayData = self.data
        // Wait for a second to mimic a slow operation.
        
        if !displayData.tweet.images.isEmpty {
            guard let url = URL(string: displayData.tweet.images[0].imageUrl) else {
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
        }
        guard !self.isCancelled else { return }
        self.fetchedData = displayData
    }
}
