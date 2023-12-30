/*
Nonisolated Methods
Expose stable read-only views from actors safely.
Mark constants and pure helpers as nonisolated.
Keep mutable state behind async actor boundaries.
*/
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

actor BankAccount {
    nonisolated let accountNumber: String
    private var balanceCents: Int = 0
    init(number: String, initial: Int) {
        self.accountNumber = number
        self.balanceCents = initial
    }
    nonisolated func masked() -> String {
        let tail = accountNumber.suffix(4)
        return "•••• \(tail)"
    }
    func deposit(_ cents: Int) {
        balanceCents += cents
    }
    func withdraw(_ cents: Int) async throws {
        try await Task.sleep(nanoseconds: 40_000_000)
        guard balanceCents >= cents else { throw NSError(domain: "insufficient", code: 1) }
        balanceCents -= cents
    }
    func balance() -> Int {
        balanceCents
    }
}

let acct = BankAccount(number: "ES7620770024003102575766", initial: 12_500)
print("public", acct.masked())

Task {
    await acct.deposit(2_500)
    do { try await acct.withdraw(4_000) } catch { print("error", error.localizedDescription) }
    let current = await acct.balance()
    print("balance", current)
    PlaygroundPage.current.finishExecution()
}
