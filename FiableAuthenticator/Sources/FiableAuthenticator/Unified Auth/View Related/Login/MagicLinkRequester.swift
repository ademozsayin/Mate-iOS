import Foundation

/// Encapsulates the async request for a magic link and email validation for use cases that send a magic link.
struct MagicLinkRequester {
    /// Makes the call to request a magic authentication link be emailed to the user if possible.
    /// 
    func requestMagicLink(email: String, flow: MateAccountService.Flow) async -> Result<Void, Error> {
        await withCheckedContinuation { continuation in
            guard email.isValidEmail() else {
                return continuation.resume(returning: .failure(MagicLinkRequestError.invalidEmail))
            }
            
            let service = MateAccountService()
            service.requestAuthenticationLink(for: email, flow:flow) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: .success(()))
                case .failure(let err):
                    return continuation.resume(returning: .failure(err))
                }
            }
        }
    }
}

extension MagicLinkRequester {
    enum MagicLinkRequestError: Error {
        case invalidEmail
    }
}
