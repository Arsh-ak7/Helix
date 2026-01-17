import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var muscleGroup: String? // Primary muscle
    var secondaryMuscles: String?
    var equipment: String?
    var descriptionText: String?
    var imageUrlString: String? // Primary image
    var images: [String]? // Array of all images
    
    var force: String?
    var level: String?
    var mechanic: String?
    var category: String?
    
    init(name: String, 
         muscleGroup: String? = nil, 
         secondaryMuscles: String? = nil,
         equipment: String? = nil, 
         descriptionText: String? = nil, 
         imageUrlString: String? = nil,
         images: [String]? = nil,
         force: String? = nil,
         level: String? = nil,
         mechanic: String? = nil,
         category: String? = nil) {
        self.id = UUID()
        self.name = name
        self.muscleGroup = muscleGroup
        self.secondaryMuscles = secondaryMuscles
        self.equipment = equipment
        self.descriptionText = descriptionText
        self.imageUrlString = imageUrlString
        self.images = images
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.category = category
    }
}
