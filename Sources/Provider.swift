import Vapor
import Argon2

public final class Provider: Vapor.Provider {
    public static let repositoryName = "argon2-provider"

    public init(config: Config) throws {
    }

    public func boot(_ config: Config) throws {
        config.addConfigurable(hash: Argon2Hash.init, name: "argon2")
    }

    public func boot(_ droplet: Droplet) throws {
    }

    public func beforeRun(_ droplet: Droplet) throws {
    }
}
