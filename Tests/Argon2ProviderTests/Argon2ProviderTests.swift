import XCTest
import Vapor
@testable import Argon2Provider

class Argon2ProviderTests: XCTestCase {
    static var allTests = [
        ("testServiceRegistration", testServiceRegistration),
        ("testCustomParameters", testCustomParameters),
        ("testInvalidVariantName", testInvalidVariantName),
        ("testFunctionality", testFunctionality),
    ]

    func testServiceRegistration() throws {
        var config = try Config()
        try config.addProvider(Argon2Provider.Provider)
        try config.set("droplet.hash", "argon2")

        let hash = try config.resolveHash()

        guard let argon = hash as? Argon2Hash else {
            XCTFail("Resolved hash was not Argon2")
            return
        }

        XCTAssertEqual(Argon2Hash.defaultTimeCost, argon.timeCost)
        XCTAssertEqual(Argon2Hash.defaultMemoryCost, argon.memoryCost)
        XCTAssertEqual(Argon2Hash.defaultParallelism, argon.parallelism)
    }

    func testCustomParameters() throws {
        var config = try Config()
        try config.addProvider(Argon2Provider.Provider)
        try config.set("droplet.hash", "argon2")
        try config.set("argon2.variant", "id")
        try config.set("argon2.timeCost", 4)
        try config.set("argon2.memoryCost", 8)
        try config.set("argon2.parallelism", 2)
        try config.set("argon2.saltLength", 64)

        let hash = try config.resolveHash()

        guard let argon = hash as? Argon2Hash else {
            XCTFail("Resolved hash was not Argon2")
            return
        }

        XCTAssertEqual(64, argon.saltLength)
        XCTAssertEqual(4, argon.timeCost)
        XCTAssertEqual(8, argon.memoryCost)
        XCTAssertEqual(2, argon.parallelism)
    }

    func testInvalidVariantName() throws {
        var config = try Config()
        try config.addProvider(Argon2Provider.Provider)
        try config.set("droplet.hash", "argon2")
        try config.set("argon2.variant", "foo")

        XCTAssertThrowsError(try config.resolveHash(), "Provider accepted an invalid variant name") { (err) in
            guard case Argon2ProviderError.invalidVariant("foo") = err else {
                XCTFail("Provider did not throw the expoected invalidVariant error")
                return
            }
        }
    }

    func testFunctionality() throws {
        var config = try Config()
        try config.addProvider(Argon2Provider.Provider)
        try config.set("droplet.hash", "argon2")

        let hash = try config.resolveHash()

        let input = "Correct Horse Battery Staple".makeBytes()
        let result = try hash.make(input)
        XCTAssertTrue(try hash.check(input, matchesHash: result))
    }
}
