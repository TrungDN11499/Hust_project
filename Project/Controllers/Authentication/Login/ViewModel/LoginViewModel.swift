//
//  LoginViewModel.swift
//  Triponus
//
//  Created by Be More on 10/11/20.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelProtocol {
    struct Input {
        let email: AnyObserver<String>
        let password: AnyObserver<String>
        let signInDidTap: AnyObserver<Void>
        let signUpDidTap: AnyObserver<Void>
    }
    
    struct Output {
        let loginResultObservable: Observable<Bool>
        let signUpResultObservable: Observable<Void>
        let errorsObservable: Observable<Error>
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
        input = Input(email: emailSubject.asObserver(),
                      password: passwordSubject.asObserver(),
                      signInDidTap: signInDidTapSubject.asObserver(),
                      signUpDidTap: signUpDidTapSubject.asObserver())
        
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        signUpResultObservable: signUpResultSubject.asObserver(),
                        errorsObservable: errorsSubject.asObservable())
        
        self.signInDidTapSubject.withLatestFrom(self.loginModelObserver)
            .do(onNext: {[weak self] (_) in
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
                self.isLoading.accept(false)
            }).disposed(by: self.disposeBag)
        
        self.signUpDidTapSubject.subscribe(onNext: {
            self.signUpResultSubject.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    deinit {
        dLogDebug("[deinit]: \(self) dealloc")
    }
}
