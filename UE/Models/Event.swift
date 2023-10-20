//
//  Event.swift
//  UE
//
//  Created by Нурбек Болат on 04.10.2023.
//

import Foundation

public struct Event: Identifiable {
    public let id: UUID = UUID()
    public let room: String
    public let name: String
    public let day: String
    public let time: String
}
