import UIKit

struct Dog {
    var id: String
    var name: String
    var breed: String
    var age: Int
    var notes: String
    var photoBase64: String?
    var medications: [Medication]

    init(id: String, name: String, breed: String, age: Int, notes: String,
         photoBase64: String?, medications: [Medication] = []) {
        self.id = id
        self.name = name
        self.breed = breed
        self.age = age
        self.notes = notes
        self.photoBase64 = photoBase64
        self.medications = medications
    }

    init?(id: String, dict: [String: Any]) {
        guard let name = dict["name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.breed = dict["breed"] as? String ?? ""
        self.age = dict["age"] as? Int ?? 0
        self.notes = dict["notes"] as? String ?? ""
        self.photoBase64 = dict["photoBase64"] as? String
        self.medications = []
    }

    /// Excludes "medications" — medications are written/removed via their own path.
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "breed": breed,
            "age": age,
            "notes": notes
        ]
        if let photoBase64 = photoBase64 {
            dict["photoBase64"] = photoBase64
        }
        return dict
    }

    var activeMedicationCount: Int {
        medications.filter { $0.isActive(on: Date()) }.count
    }

    var image: UIImage? {
        ImageUtils.image(fromBase64: photoBase64)
    }
}
