import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var muscleGroup: String?
    var equipment: String?
    var descriptionText: String?
    var imageUrlString: String?
    
    init(name: String, muscleGroup: String? = nil, equipment: String? = nil, descriptionText: String? = nil, imageUrlString: String? = nil) {
        self.id = UUID()
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.descriptionText = descriptionText
        self.imageUrlString = imageUrlString
    }
}
