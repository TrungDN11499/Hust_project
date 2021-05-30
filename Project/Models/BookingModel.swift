//
//  BookingModel.swift
//  Triponus
//
//  Created by admin on 31/05/2021.
//

import Foundation

class BookingModel {
    let imageName: String
    let url: String
    
    init(imageName: String, url: String) {
        self.imageName = imageName
        self.url = url
    }
}

class Booking {
    let booking = [
        BookingModel(imageName: "ic_agoda", url: "https://www.agoda.com/"),
        BookingModel(imageName: "ic_booking", url: "https://www.booking.com")
    ]
}
