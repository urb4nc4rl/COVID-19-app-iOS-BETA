//
//  OnboardingViewController.swift
//  Sonar
//
//  Created by NHSX on 3/31/20.
//  Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class OnboardingViewController: UINavigationController, Storyboarded {
    static let storyboardName = "Onboarding"

    private var environment: OnboardingEnvironment! = nil
    private var onboardingCoordinator: OnboardingCoordinating! = nil
    private var bluetoothNursery: BluetoothNursery! = nil
    private var completionHandler: (() -> Void)! = nil
    private var uiQueue: TestableQueue! = nil

    func inject(env: OnboardingEnvironment, coordinator: OnboardingCoordinating, bluetoothNursery: BluetoothNursery, uiQueue: TestableQueue, completionHandler: @escaping () -> Void) {
        self.environment = env
        self.onboardingCoordinator = coordinator
        self.bluetoothNursery = bluetoothNursery
        self.completionHandler = completionHandler
        self.uiQueue = uiQueue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Disallow pulling to dismiss the card modal
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        (viewControllers.first as! StartNowViewController).inject(persistence: environment.persistence,
                                                                  notificationCenter: environment.notificationCenter,
                                                                  continueHandler: updateState)
        updateState()
    }

    @IBAction func unwindFromPermissionsDenied(unwindSegue: UIStoryboardSegue) {
        updateState()
    }
    
    private func updateState() {
        onboardingCoordinator.state { [weak self] state in
            guard let self = self else { return }

            self.uiQueue.async { self.handle(state: state) }
        }
    }

    private func handle(state: OnboardingCoordinating.State) {
        let vc: UIViewController
        switch state {
        case .initial:
            vc = StartNowViewController.instantiate() {
                $0.inject(persistence: environment.persistence, notificationCenter: environment.notificationCenter, continueHandler: updateState)
            }
            
        case .partialPostcode:
            vc = PostcodeViewController.instantiate() {
                $0.inject(persistence: environment.persistence, notificationCenter: environment.notificationCenter, continueHandler: updateState)
            }
            
        case .permissions:
            vc = PermissionsViewController.instantiate() {
                $0.inject(authManager: environment.authorizationManager,
                          remoteNotificationManager: environment.remoteNotificationManager,
                          bluetoothNursery: bluetoothNursery,
                          persistence: environment.persistence,
                          uiQueue: uiQueue,
                          continueHandler: updateState)
            }
            
        case .bluetoothDenied:
            vc = BluetoothPermissionDeniedViewController.instantiate() {
                $0.inject(notificationCenter: environment.notificationCenter, uiQueue: uiQueue, continueHandler: updateState)
           }
            
        case .bluetoothOff:
            vc = BluetoothOffViewController.instantiate() {
                $0.inject(notificationCenter: environment.notificationCenter, uiQueue: uiQueue, continueHandler: updateState)
            }
            
        case .notificationsDenied:
             vc = NotificationPermissionDeniedViewController.instantiate() {
                 $0.inject(notificationCenter: environment.notificationCenter, uiQueue: uiQueue, continueHandler: updateState)
            }

        case .done:
            completionHandler()
            return
        }

        viewControllers = [vc]
    }
}
