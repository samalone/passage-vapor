import Vapor
import JWT

public struct PassageAuthenticator: Authenticator {
    public init() {}
    
    func authenticate(request: Request) -> PassageUser? {
        guard let token = request.cookies["psg_auth_token"]?.string else {
            return nil
        }
        guard let payload = try? request.jwt.verify(token, as: PassageToken.self) else {
            return nil
        }
        return PassageUser(id: payload.subject.value)
    }
    
    public func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        if let user = authenticate(request: request) {
            request.auth.login(user)
        }
        return next.respond(to: request)
    }
}
