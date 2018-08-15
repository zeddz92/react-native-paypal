//
//  RNPaypal.swift
//  OneBoatApp
//
//  Created by Edward R on 1/11/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import UIKit


//RNPaypal.switf


@objc(RNPaypal)
class RNPaypal: UIViewController, PayPalPaymentDelegate, PayPalProfileSharingDelegate {
  func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
    
  }
  
  func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable : Any]) {
    
  }
  
  
  var payPalConfig = PayPalConfiguration()
  var payPalPayment = PayPalPayment();
  var successCallback: RCTResponseSenderBlock? = nil;
  var errorCallback: RCTResponseSenderBlock? = nil;
  
 
//  var environment:String = PayPalEnvironmentProduction {
//    willSet(newEnvironment) {
//      if (newEnvironment != environment) {
//        PayPalMobile.preconnect(withEnvironment: newEnvironment)
//      }
//    }
//  }
  
  
 
  
  func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
  
    print("Payment canceled")
    paymentViewController.dismiss(animated: true, completion: nil)
    self.errorCallback!([["error_code": 101, "error_message" : "Payment Cancelled"], NSNull()])
  }
  
  func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
    
    paymentViewController.dismiss(animated: true, completion: { () -> Void in
       self.successCallback!([completedPayment.confirmation])
    })
    
  }
  
  fileprivate func configureEnvironment(_ payPalParameters: [String : Any]) {
    if let clientId = payPalParameters["clientId"] as? NSString {
      
      if let environment = payPalParameters["environment"] as? NSString {
        DispatchQueue.main.async {
          PayPalMobile.initializeWithClientIds(forEnvironments: [environment : clientId ])
          PayPalMobile.preconnect(withEnvironment: environment as String)
        }
      }
      
    }
  }
  
  fileprivate func configurePaymentSettings(_ payPalParameters: [String : Any]) {
    if let intent = payPalParameters["intent"] as? NSNumber {
      payPalPayment.intent = PayPalPaymentIntent(rawValue: Int(intent))!;
    }
    
    if let acceptCreditCards = payPalParameters["acceptCreditCards"] as? Bool {
      payPalConfig.acceptCreditCards = acceptCreditCards;
    }
    
    if let price = payPalParameters["price"] as? NSNumber {
      payPalPayment.amount = NSDecimalNumber(decimal: price.decimalValue)
    }
    
    if let currency = payPalParameters["currency"] as? String {
      payPalPayment.currencyCode = currency
    }
    
    if let description = payPalParameters["description"] as? String {
      payPalPayment.shortDescription = description
    }
  }
  
  @objc(paymentRequest:payPalParameters:successCallback:errorCallback:)
  func paymentRequest(name: String, payPalParameters: [String: Any], successCallback: @escaping RCTResponseSenderBlock, errorCallback: @escaping RCTResponseSenderBlock) -> Void {
    
    self.successCallback = successCallback;
    self.errorCallback = errorCallback;

    configureEnvironment(payPalParameters)
    
    configurePaymentSettings(payPalParameters)


    if (payPalPayment.processable) {
       let paymentViewController = PayPalPaymentViewController(payment: payPalPayment, configuration: payPalConfig, delegate: self)
       DispatchQueue.main.async {
        let rootVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        rootVC?.present(paymentViewController!, animated: true, completion: nil)
      }
     
    }
    else {
       self.errorCallback!([["error_code": 102, "error_message" : "Payment not processable"], NSNull()])
    }
    
  }

  
  func constantsToExport() -> [AnyHashable: Any]! {
    return [
      "ENVIRONMENT": [
        "SANDBOX": PayPalEnvironmentSandbox,
        "PRODUCTION": PayPalEnvironmentProduction,
        "NO_NETWORK": PayPalEnvironmentNoNetwork,
      ],
      "INTENT": [
        "SALE": PayPalPaymentIntent.sale,
        "AUTHORIZE": PayPalPaymentIntent.authorize,
        "ORDER": PayPalPaymentIntent.order
      ]
      
    ]
  }
  
  
}

