import Argon2
import Vapor
import Random

public enum Argon2ProviderError: Error {
    case invalidVariant(String)
}

public final class Argon2Hash: HashProtocol, ConfigInitializable {
    static let defaultTimeCost: UInt32 = 3
    static let defaultMemoryCost: UInt32 = 12
    static let defaultParallelism: UInt32 = 1
    static let defaultSaltLength: Int = 32

    let variant: Argon2
    let saltLength: Int
    let timeCost: UInt32
    let memoryCost: UInt32
    let parallelism: UInt32

    public init(variant: Argon2,
                saltLength: Int = Argon2Hash.defaultSaltLength,
                timeCost: UInt32 = Argon2Hash.defaultTimeCost,
                memoryCost: UInt32 = Argon2Hash.defaultMemoryCost,
                parallelism: UInt32 = Argon2Hash.defaultParallelism) {
        self.variant = variant
        self.saltLength = saltLength
        self.timeCost = timeCost
        self.memoryCost = memoryCost
        self.parallelism = parallelism
    }

    public convenience init(config: Config) throws {
        let variantName: String = (try? config.get("argon2.variant")) ?? "i"
        let variant: Argon2

        switch variantName.lowercased() {
        case "i":
            variant = .i
        case "id":
            variant = .id
        case "d":
            variant = .d
        default:
            throw Argon2ProviderError.invalidVariant(variantName)
        }

        self.init(variant: variant,
                  saltLength: (try? config.get("argon2.saltLength")) ?? Argon2Hash.defaultSaltLength,
                  timeCost: (try? config.get("argon2.timeCost")) ?? Argon2Hash.defaultTimeCost,
                  memoryCost: (try? config.get("argon2.memoryCost")) ?? Argon2Hash.defaultMemoryCost,
                  parallelism: (try? config.get("argon2.parallelism")) ?? Argon2Hash.defaultParallelism)
    }

    public func make(_ message: Bytes) throws -> Bytes {
        let salt = OSRandom().bytes(count: saltLength)
        return try variant.hash(message,
                                salt: salt,
                                timeCost: timeCost,
                                memoryCost: memoryCost,
                                parallelism: parallelism).makeBytes()
    }

    public func check(_ message: Bytes, matchesHash: Bytes) throws -> Bool {
        return variant.verify(matchesHash.makeString(), against: message)
    }
}
