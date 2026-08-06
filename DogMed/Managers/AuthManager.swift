import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    var uid: String? { Auth.auth().currentUser?.uid }

    func signIn(completion: @escaping (String?) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            completion(uid)
            return
        }
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("DogMed: anonymous sign-in failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(result?.user.uid)
        }
    }
}
