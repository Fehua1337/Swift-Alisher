//
//  WarriorInfo.swift
//  WarriorGame
//
//  Created by Alisher Tulembekov on 24.03.2024.
//

import Foundation
import RealmSwift

class warrior: Object {
    @Persisted var name: String
    @Persisted var health: Int
    @Persisted var damage: Int
}
