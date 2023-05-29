import Vapor
import JWT

public enum PassageError: Error {
    case publicKeyNotBase64
    case publicKeyInvalidUTF8
}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(string: value)!
    }
    
    static func / (_ lhs: URL, _ rhs: String) -> URL {
        return lhs.appending(component: rhs)
    }
}

#if os(Linux)
extension URL {
    func appending(component: String) -> URL {
        var result = self
        result.append(component: component)
        return result
    }
}

public struct PassageToken: JWTPayload {
    // Maps the longer Swift property names to the
    // shortened keys used in the JWT payload.
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }

    // The "sub" (subject) claim identifies the principal that is the
    // subject of the JWT.
    var subject: SubjectClaim

    // The "exp" (expiration time) claim identifies the expiration time on
    // or after which the JWT MUST NOT be accepted for processing.
    var expiration: ExpirationClaim

    // Run any additional verification logic beyond
    // signature verification here.
    // Since we have an ExpirationClaim, we will
    // call its verify method.
    public func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}

public struct Passage: Encodable {
    public let applicationID: String
    private let apiKey: String
    
    // We want the Passage to be Encodable so it can be part of a Leaf context,
    // but we don't want our private apiKey to leak out to the client, so make
    // sure the apiKey is not included in our CodingKeys.
    enum CodingKeys: CodingKey {
        case applicationID
    }
    
    static let authRoot: URL = "https://auth.passage.id/v1/"
    static let apiRoot: URL = "https://api.passage.id/v1/"

    public init(appID: String, apiKey: String) throws {
        self.applicationID = appID
        self.apiKey = apiKey
    }
    
    /// The snippet that you should insert into the body of your HTML to
    /// provide for Passage authentication.
    public var authSnippet: String {
        return """
            <passage-auth app-id="\(applicationID)"></passage-auth>
            <script src="https://psg.so/web.js"></script>
        """
    }
    
    public var profileSnippet: String {
        return """
            <passage-profile app-id="\(applicationID)"></passage-profile>
            <script src="https://psg.so/web.js"></script>
        """
    }
    
    
//    public var signer: JWTSigner {
//        return JWTSigner.rs256(key: .public(publicKey))
//    }
    
    func getApp() async throws -> PassageApp {
        var request = URLRequest(url: Passage.apiRoot / "apps" / applicationID)
        request.addValue("Bearer " + apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: request)
        let appResp = try JSONDecoder().decode(PassageAppResponse.self, from: data)
        return appResp.app
    }

}

enum PassageKey: StorageKey {
    typealias Value = Passage
}

struct PassageAppResponse: Decodable {
    var app: PassageApp
}

struct PassageApp: Decodable {
    var id: String
    var auth_origin: String
    var rsa_public_key: String
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
    
    public func configure(passage: Passage, isDefault: Bool = true) async throws {
        self.passage = passage
        
        let app = try await passage.getApp()
        guard let data = Data(base64Encoded: app.rsa_public_key) else {
            throw PassageError.publicKeyNotBase64
        }
        guard let rsaPEM = String(data: data, encoding: .utf8) else {
            throw PassageError.publicKeyInvalidUTF8
        }
        /// Passages provides their public key in the older BEGIN RSA PUBLIC KEY format, but
        /// the Vapor JWT library requires it to be in the newer BEGIN PUBLIC KEY format. It turns
        /// out that we can convert between formats using simple string replacement.
        /// See https://stackoverflow.com/a/29707204 for a detailed explanation.
        let genericPEM = rsaPEM.replacingOccurrences(of: "-----BEGIN RSA PUBLIC KEY-----",
                                            with: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A")
            .replacingOccurrences(of: "-----END RSA PUBLIC KEY-----", with: "-----END PUBLIC KEY-----")
        let key = try RSAKey.public(pem: genericPEM)
        self.jwt.signers.use(.rs256(key: key), isDefault: isDefault)
    }
}
