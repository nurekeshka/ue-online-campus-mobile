//
//  TimetableView.swift
//  UE
//
//  Created by Нурбек Болат on 30.09.2023.
//

import SwiftUI

struct TimetableView: View {
    @State public var events: [Event]
    
    public init(events: [Event]) {
        self.events = events.sorted(by: { left_event, right_event in
            return left_event.day < right_event.day
        })
    }
    
    var body: some View {
        List {
            Section {
                ForEach(self.events) { event in
                    HStack {
                        Text(event.day)
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        Text(event.name)
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        VStack {
                            Text(event.time)
                                .font(.system(size: 12))
                            Text(event.room)
                                .font(.system(size: 10))
                        }
                    }
                }
            }
        }.listStyle(.plain)
    }
}

let events: [Event] = [
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45"),
    Event(room: "P_Room 02 Flex",
          name: "Employability: Business English SE (B)",
          day: "Friday", time: "08:30 - 10:45")
]

#Preview {
    TimetableView(events: events)
}
