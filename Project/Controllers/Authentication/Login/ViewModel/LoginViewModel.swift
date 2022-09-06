//
//  LoginViewModel.swift
//  Triponus
//
//  Created by Be More on 10/11/20.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelProtocol {
    struct Input {
        let email: AnyObserver<String>
        let password: AnyObserver<String>
        let signInDidTap: AnyObserver<Void>
        let signUpDidTap: AnyObserver<Void>
        let fetchUser: AnyObserver<Void>
    }

    struct Output {
        let loginResultObservable: Observable<Bool>
        let signUpResultObservable: Observable<Void>
        let errorsObservable: Observable<Error>
        let fetchUserResultObservable: Observable<User?>
    }

    // MARK: - Public properties
    let input: Input
    let output: Output
    let isLoading = BehaviorRelay(value: false)
    
    // MARK: - Private properties
    private let emailSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
    private let signInDidTapSubject = PublishSubject<Void>()
    private let signUpDidTapSubject = PublishSubject<Void>()
    private let fetchUserSubject = PublishSubject<Void>()
    private let fetchUserResultSubject = PublishSubject<User?>()
    private let loginResultSubject = PublishSubject<Bool>()
    private let signUpResultSubject = PublishSubject<Void>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    private var loginModelObserver: Observable<LoginModel> {
        return Observable.combineLatest(emailSubject.asObserver(), passwordSubject.asObserver()) { email, passwd in
            return LoginModel(email: email, password: passwd)
        }
    }
    
    init(loginService: LoginServiceProtocol) {
        self.input = Input(email: self.emailSubject.asObserver(),
                           password: self.passwordSubject.asObserver(),
                           signInDidTap: self.signInDidTapSubject.asObserver(),
                           signUpDidTap: self.signUpDidTapSubject.asObserver(),
                           fetchUser: self.fetchUserSubject.asObserver())
        
        self.output = Output(loginResultObservable: self.loginResultSubject.asObservable(),
                             signUpResultObservable: self.signUpResultSubject.asObservable(),
                             errorsObservable: self.errorsSubject.asObservable(),
                             fetchUserResultObservable: self.fetchUserResultSubject.asObservable())
        
        self.signInDidTapSubject.withLatestFrom(self.loginModelObserver)
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else {return}
                self.isLoading.accept(true)
            }).flatMapLatest { loginModel in
                return loginService.login(with: loginModel)
            }.subscribe(onNext: { [weak self] result in
                guard let `self` = self else {return}
                if let error = result.1 {
                    self.errorsSubject.onNext(error)
                } else {
                    self.loginResultSubject.onNext(true)
                }
                
            }).disposed(by: self.disposeBag)
        
        self.fetchUserSubject.flatMapLatest { _ in
            return loginService.fetchCurrentUser()
        }.subscribe(onNext: { [weak self] result in
            guard let `self` = self else {return}
            if let error = result.1 {
                self.errorsSubject.onNext(error)
            } else {
                self.fetchUserResultSubject.onNext(result.0)
            }
            self.isLoading.accept(false)
        }).disposed(by: self.disposeBag)

        self.signUpDidTapSubject.subscribe(onNext: { [weak self] in
            guard let `self` = self else {return}
            self.signUpResultSubject.onNext(())
        }).disposed(by: self.disposeBag)
    }

    deinit {
        dLogDebug("[deinit]: \(self) dealloc")
    }
}
