/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that implements both `UICollectionViewDataSource` and `UICollectionViewDataSourcePrefetching`.
*/

import UIKit
import SwiftUI

/// - Tag: CustomDataSource
class CustomDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    // MARK: Properties
    
    var feedViewModel: [FeedViewModel] = []
    var user: User?
    private var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    /// An `AsyncFetcher` that is used to asynchronously fetch `DisplayData` objects.
    private let asyncFetcher = AsyncFetcher()

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedViewModel.count
    }

    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = TweetCollectionViewCell.loadCell(collectionView, indexPath: indexPath) as? TweetCollectionViewCell else {
            return TweetCollectionViewCell()
        }
        
        let model = feedViewModel[indexPath.row]
        let identifier = model.identifier
        cell.representedIdentifier = identifier
        if let feedsViewController = self.viewController as? FeedsViewController {
            cell.delegate = feedsViewController
        }
        
        // Check if the `asyncFetcher` has already fetched data for the specified identifier.
        if let fetchedData = asyncFetcher.fetchedData(for: identifier) {
            // The data has already been fetched and cached; use it to configure the cell.
            cell.feedViewModel = fetchedData
        } else {
            // There is no data available; clear the cell until we've fetched data.
            cell.feedViewModel = nil

            // Ask the `asyncFetcher` to fetch data for the specified identifier.
            asyncFetcher.fetchAsync(identifier, fetchData: model) { fetchedData in
                DispatchQueue.main.async {
                    /*
                     The `asyncFetcher` has fetched data for the identifier. Before
                     updating the cell, check if it has been recycled by the
                     collection view to represent other data.
                     */
                    guard cell.representedIdentifier == identifier else { return }
                    
                    // Configure the cell with the fetched image.
                    cell.feedViewModel = fetchedData
                }
            }
        }

        return cell
    }

    // MARK: UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let model = self.feedViewModel[indexPath.row]
            asyncFetcher.fetchAsync(model.identifier, fetchData: model)
        }
    }

    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // Cancel any in-flight requests for data for the specified index paths.
        for indexPath in indexPaths {
            let model = self.feedViewModel[indexPath.row]
            asyncFetcher.cancelFetch(model.identifier)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? FeedsHeaderCollectionReusableView else {
            return FeedsHeaderCollectionReusableView()
        }
        header.user = self.user
        if let feedsViewController = self.viewController as? FeedsViewController {
            header.delegate = feedsViewController
        }
        return header
    }
}
