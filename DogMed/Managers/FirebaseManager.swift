import Foundation
import FirebaseDatabase

extension Notification.Name {
    static let dogMedDataDidChange = Notification.Name("dogMedDataDidChange")
}

enum FirebaseManagerError: LocalizedError {
    case notSignedIn
    var errorDescription: String? { "Not signed in yet — please try again in a moment." }
}

/// Single observer on /users/{uid}/dogs for the whole app lifetime. Broadcasts changes via
/// NotificationCenter (rather than a single closure) because UITabBarController keeps all three
/// tab root view controllers alive simultaneously, so more than one screen needs to observe at once.
final class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}

    private(set) var dogs: [Dog] = []
    private var dogsRef: DatabaseReference?
    private var dogsHandle: DatabaseHandle?

    private var userDogsPath: String? {
        guard let uid = AuthManager.shared.uid else { return nil }
        return "users/\(uid)/dogs"
    }

    func startObserving() {
        guard let path = userDogsPath else { return }
        stopObserving()
        let ref = Database.database().reference(withPath: path)
        dogsRef = ref
        dogsHandle = ref.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            self.dogs = Self.parseDogs(from: snapshot)
            NotificationCenter.default.post(name: .dogMedDataDidChange, object: nil)
        }
    }

    func stopObserving() {
        if let ref = dogsRef, let handle = dogsHandle {
            ref.removeObserver(withHandle: handle)
        }
        dogsRef = nil
        dogsHandle = nil
    }

    private static func parseDogs(from snapshot: DataSnapshot) -> [Dog] {
        var result: [Dog] = []
        for case let child as DataSnapshot in snapshot.children {
            guard let dict = child.value as? [String: Any],
                  var dog = Dog(id: child.key, dict: dict) else { continue }
            var medications: [Medication] = []
            let medsSnapshot = child.childSnapshot(forPath: "medications")
            for case let medChild as DataSnapshot in medsSnapshot.children {
                guard let medDict = medChild.value as? [String: Any],
                      let medication = Medication(id: medChild.key, dogId: child.key, dict: medDict) else { continue }
                medications.append(medication)
            }
            dog.medications = medications
            result.append(dog)
        }
        return result
    }

    // MARK: - Dog CUD

    func addDog(_ dog: Dog, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        let ref = Database.database().reference(withPath: path).childByAutoId()
        ref.setValue(dog.toDictionary()) { error, _ in completion(error) }
    }

    func updateDog(_ dog: Dog, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        Database.database().reference(withPath: "\(path)/\(dog.id)").updateChildValues(dog.toDictionary()) { error, _ in
            completion(error)
        }
    }

    func deleteDog(_ dog: Dog, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        Database.database().reference(withPath: "\(path)/\(dog.id)").removeValue { error, _ in completion(error) }
    }

    // MARK: - Medication CUD

    func addMedication(_ medication: Medication, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        let ref = Database.database().reference(withPath: "\(path)/\(medication.dogId)/medications").childByAutoId()
        ref.setValue(medication.toDictionary()) { error, _ in completion(error) }
    }

    func updateMedication(_ medication: Medication, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        Database.database().reference(withPath: "\(path)/\(medication.dogId)/medications/\(medication.id)")
            .updateChildValues(medication.toDictionary()) { error, _ in completion(error) }
    }

    func deleteMedication(_ medication: Medication, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        Database.database().reference(withPath: "\(path)/\(medication.dogId)/medications/\(medication.id)")
            .removeValue { error, _ in completion(error) }
    }

    // MARK: - History

    func setMedication(_ medication: Medication, given: Bool, on dateKey: String, time: String, completion: @escaping (Error?) -> Void) {
        guard let path = userDogsPath else { completion(FirebaseManagerError.notSignedIn); return }
        let timeKey = DateUtils.timeKey(from: time)
        let ref = Database.database().reference(withPath: "\(path)/\(medication.dogId)/medications/\(medication.id)/history/\(dateKey)/\(timeKey)")
        if given {
            ref.setValue(ServerValue.timestamp()) { error, _ in completion(error) }
        } else {
            ref.removeValue { error, _ in completion(error) }
        }
    }
}
