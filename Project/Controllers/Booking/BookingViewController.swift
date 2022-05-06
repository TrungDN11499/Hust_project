//
//  BookingViewController.swift
//  Triponus
//
//  Created by admin on 26/05/2021.
//

import UIKit

class BookingViewController: UIViewController {

    @IBOutlet weak var bookingCollectionView: UICollectionView!
    let bookings = Booking()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        
    }

    private func configureCollectionView() {
        self.bookingCollectionView.delegate = self
        self.bookingCollectionView.dataSource = self
        self.bookingCollectionView.backgroundColor = .white
        self.bookingCollectionView.register(UINib.init(nibName: "BookingCLVCell", bundle: nil), forCellWithReuseIdentifier: "cellID")
    }

    private func configureViewController() {
        self.navigationItem.title = "Booking Agency"
    }
}

// MARK: UICollectionViewExtension
extension BookingViewController: UICollectionViewDelegate {
}

extension BookingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookings.booking.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.bookingCollectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as? BookingCLVCell else {
            return BookingCLVCell()
        }
        cell.booking = self.bookings.booking[indexPath.row]
        if indexPath.row == 0 {
            cell.bookingImageView.borderWidth = 1
            cell.bookingImageView.borderColor = .black
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let webViewController = WebViewController()
        webViewController.urlString = self.bookings.booking[indexPath.item].url
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
}
extension BookingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.frame.width - (12*3))/2
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
