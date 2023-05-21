public struct Passage {
    public let applicationID: String

    public init(appID: String) {
        self.applicationID = appID
    }
    
    /// The snippet that you should insert into the body of your HTML to
    /// provide for Passage authentication.
    public var authSnippet: String {
        return """
            <passage-auth app-id="\(applicationID)"></passage-auth>
            <script src="https://psg.so/web.js"></script>
        """
    }

}
