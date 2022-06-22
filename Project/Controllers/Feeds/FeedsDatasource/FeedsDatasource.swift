//
//  FeedsDatasource.swift
//  Triponus
//
//  Created by TrungDN on 21/06/2022.
//

import RxDataSources
import Foundation

enum FeedsCollecionViewItem {
    /// Represents a cell with a collection view inside
    case feedCollectionViewwItem(tweets: [Tweet])
}

enum FeedsCollecionViewSection {
    case feedSection(header: User, items: [FeedsCollecionViewItem])
}

extension FeedsCollecionViewSection: SectionModelType {
    typealias Item = FeedsCollecionViewItem

    var header: User {
        switch self {
        case .feedSection(header: let user, items: _):
            return user
        }
    }

    var items: [FeedsCollecionViewItem] {
        switch self {
        case .feedSection(header: _, items: let items):
            return items
        }
    }
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct FeedsCollecionViewSource {
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    
    static func dataSource() -> DataSource<FeedsCollecionViewSection> {
        return .init { dataSource, collectionView, indexPath, item in
            switch dataSource[indexPath] {
            case let .feedCollectionViewwItem(tweets):
                let cell = collectionView.dequeuCell(ofType: TweetCollectionViewCell.self, for: indexPath)
                cell.feedViewModel = FeedViewModel(tweets[indexPath.item])
                return cell
            }
        } configureSupplementaryView: { dataSource, collectionView, string, indexPath in
            let header = collectionView.dequeueHeader(ofType: FeedsHeaderCollectionReusableView.self, for: indexPath)
            header.user = dataSource.sectionModels[indexPath.section].header
            return header
        } moveItem: { dataSource, sourceIndexPath, destinationIndexPath in
        } canMoveItemAtIndexPath: { _, _ in
            return false
        }

    }
}
