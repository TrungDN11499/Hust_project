//
//  TriponusError.swift
//  Triponus
//
//  Created by Be More on 25/10/2021.
//

import Foundation

/// Triponus error type
public enum TriponusAuthencationError: Error {

    /// Email validation failed
    case emailValidationError

    /// Email empty
    case emptyEmail
    
    /// Password empty
    case passwordEmpty
}

extension TriponusAuthencationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emailValidationError:
            return NSLocalizedString("Email badly formatted.", comment: "Email validation failed.")
        case .emptyEmail:
            return NSLocalizedString("Email cannot leave empty.", comment: "Email empty")
        case .passwordEmpty:
            return NSLocalizedString("Password cannot leave empty.", comment: "Password empty")
        }
    }

    public var failureReason: String? {
        switch self {
        case .emailValidationError:
            return NSLocalizedString("User entered wrong email format", comment: "")
        case .emptyEmail:
            return NSLocalizedString("User leaved email empty", comment: "")
        case .passwordEmpty:
            return NSLocalizedString("User leaved password empty", comment: "")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .emailValidationError:
            return NSLocalizedString("Re-enter email", comment: "")
        case .emptyEmail:
            return NSLocalizedString("Re-enter email", comment: "")
        case .passwordEmpty:
            return NSLocalizedString("Re-enter password", comment: "")
        }
    }
}
