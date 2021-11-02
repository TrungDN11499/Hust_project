//
//  RegisterViewModel.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewModel: ViewModelProtocol {

    struct Input {
        let email: AnyObserver<String>
        let password: AnyObserver<String>
        let confirmPassword: AnyObserver<String>
        let fullName: AnyObserver<String>
        let userName: AnyObserver<String>
        let profileImage: AnyObserver<UIImage>
        let registerDidTap: AnyObserver<Void>
        let signUpDidTap: AnyObserver<Void>
    }

    struct Output {
        let registerResultObservable: Observable<Bool>
        let gotoLoginResultObservable: Observable<Void>
        let errorsObservable: Observable<Error>
    }

    // MARK: - Public properties
    let input: Input
    let output: Output
    let isLoading = BehaviorRelay(value: false)

    // MARK: - Private properties
    private let emailSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
    private let confirmPasswordSubject = PublishSubject<String>()
    private let fullNamePasswordSubject = PublishSubject<String>()
    private let userNamePasswordSubject = PublishSubject<String>()
    private let profileImageSubject = PublishSubject<UIImage>()
    private let registerSubject = PublishSubject<Void>()
    private let signInSubject = PublishSubject<Void>()
    private let errorsSubject = PublishSubject<Error>()
    private let registerResultSubject = PublishSubject<Bool>()
    private let signInResultSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    private var registerModelObserver: Observable<RegisterModel> {
        return Observable.combineLatest(emailSubject.asObserver(),
                                        passwordSubject.asObserver(),
                                        confirmPasswordSubject.asObserver(),
                                        fullNamePasswordSubject.asObserver(),
                                        userNamePasswordSubject.asObserver(),
                                        profileImageSubject.asObserver()) { email, passwd, confirmPassword, fullName, userName, image in

            return RegisterModel(email: email,
                                 password: passwd,
                                 confirmPassword: confirmPassword,
                                 username: userName,
                                 fullName: fullName,
                                 profileImage: image)
        }
    }

    init(registrationService: RegistrationService) {
        self.input = Input(email: emailSubject.asObserver(),
                           password: passwordSubject.asObserver(),
                           confirmPassword: confirmPasswordSubject.asObserver(),
                           fullName: fullNamePasswordSubject.asObserver(),
                           userName: userNamePasswordSubject.asObserver(),
                           profileImage: profileImageSubject.asObserver(),
                           registerDidTap: registerSubject.asObserver(),
                           signUpDidTap: signInSubject.asObserver())

        self.output = Output(registerResultObservable: registerResultSubject.asObservable(),
                             gotoLoginResultObservable: signInResultSubject.asObservable(),
                             errorsObservable: errorsSubject.asObservable())

        self.registerSubject.withLatestFrom(self.registerModelObserver)
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.isLoading.accept(true)
            }).flatMapLatest { registerModel in
                return registrationService.register(with: registerModel) { progress in
                    print(progress)
                }
            }.subscribe(onNext: { [weak self] result in
                guard let `self` = self else {return}
                if let error = result.1 {
                    self.errorsSubject.onNext(error)
                } else {
                    self.registerResultSubject.onNext(true)
                }
                self.isLoading.accept(false)
            }).disposed(by: self.disposeBag)
        
        self.signInSubject.subscribe(onNext: { [weak self] in
            guard let `self` = self else {return}
            self.signInResultSubject.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    deinit {
        dLogDebug("[deinit]: \(self) dealloc")
    }
}
