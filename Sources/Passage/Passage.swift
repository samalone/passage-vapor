import Vapor
import JWT

public enum PassageError: Error {
    case publicKeyNotBase64
    case publicKeyInvalidUTF8
}

public struct Passage {
    public let applicationID: String
    public let publicKey: String

    public init(appID: String, publicKey: String) throws {
        self.applicationID = appID
        self.publicKey = publicKey
    }
    
    /// The snippet that you should insert into the body of your HTML to
    /// provide for Passage authentication.
    public var authSnippet: String {
        return """
            <passage-auth app-id="\(applicationID)"></passage-auth>
            <script src="https://psg.so/web.js"></script>
        """
    }
    
//    public var signer: JWTSigner {
//        return JWTSigner.rs256(key: .public(publicKey))
//    }

}

private enum PassageKey: StorageKey {
    typealias Value = Passage
}

extension Application {
    public var passage: Passage {
        get {
            guard let passage = self.storage[PassageKey.self] else {
                fatalError("Passage not configured. Use app.passage = Passage(...) to configure.")
            }
            return passage
        }
        set {
            self.storage[PassageKey.self] = newValue
        }
    }
    
    public func configure(passage: Passage, isDefault: Bool = true) throws {
        self.passage = passage
        guard let data = Data(base64Encoded: passage.publicKey) else {
            throw PassageError.publicKeyNotBase64
        }
        guard let pem = String(data: data, encoding: .utf8) else {
            throw PassageError.publicKeyInvalidUTF8
        }
        let key = try RSAKey.public(pem: pem)
        self.jwt.signers.use(.rs256(key: key), isDefault: isDefault)
    }
}
