//
//  TriponusError.swift
//  Triponus
//
//  Created by Be More on 25/10/2021.
//

import Foundation

// MARK: - TriponusAuthencationError
/// Triponus error type
public enum TriponusAuthencationError: Error {

    /// Email validation failed
    case emailValidationError

    /// Email empty
    case emptyEmail
    
    /// Password empty
    case passwordEmpty
    
    /// Password not match
    case passwordNotMatch
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
        case .passwordNotMatch:
            return NSLocalizedString("Password not match.", comment: "Password not match")
        }
    }

    public var failureReason: String? {
        switch self {
        case .emailValidationError:
            return NSLocalizedString("User entered wrong email format", comment: "")
        case .emptyEmail:
            return NSLocalizedString("User leaved email empty", comment: "")
        case .passwordNotMatch:
            return NSLocalizedString("Password not match.", comment: "Password not match")
        case .passwordEmpty:
            return NSLocalizedString("User leaved password empty", comment: "")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .emailValidationError:
            return NSLocalizedString("Re-enter email", comment: "")
        case .passwordNotMatch:
            return NSLocalizedString("Re-enter password", comment: "")
        case .emptyEmail:
            return NSLocalizedString("Re-enter email", comment: "")
        case .passwordEmpty:
            return NSLocalizedString("Re-enter password", comment: "")
        }
    }
}

// MARK: - TriponusTweetsError
/// Triponus error type
public enum TriponusTweetsError: Error {
    case fetchFollowingUserTweetsError
    case fetchUserTweetsError
}

extension TriponusTweetsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fetchFollowingUserTweetsError:
            return NSLocalizedString("Fetch Following User Tweets Error.", comment: "Fetch Following User Tweets Error.")
        case .fetchUserTweetsError:
            return NSLocalizedString("Fetch User Tweets Error", comment: "Fetch User Tweets Error")
        }
    }

    public var failureReason: String? {
        switch self {
        case .fetchFollowingUserTweetsError:
            return NSLocalizedString("Fetch Following User Tweets Error.", comment: "")
        case .fetchUserTweetsError:
            return NSLocalizedString("Fetch User Tweets Error", comment: "")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .fetchFollowingUserTweetsError:
            return NSLocalizedString("", comment: "")
        case .fetchUserTweetsError:
            return NSLocalizedString("", comment: "")
        }
    }
}

// MARK: - TriponusUserError
public enum TriponusUserError: Error {
    case fetchCurrentUserError
}
 
extension TriponusUserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fetchCurrentUserError:
            return NSLocalizedString("Fetch Current User Error.", comment: "Fetch Current User Error.")
        }
    }

    public var failureReason: String? {
        switch self {
        case .fetchCurrentUserError:
            return NSLocalizedString("Fetch Current User Error.", comment: "")
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .fetchCurrentUserError:
            return NSLocalizedString("", comment: "")
        }
    }
}
