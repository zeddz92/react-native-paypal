
#import "RNPaypal.h"
#import "React/RCTBridge.h"
#import "PayPalMobile.h"
#import "React/RCTConvert.h"

@interface RNPaypal () <PayPalPaymentDelegate, RCTBridgeModule>

@property(nonatomic, strong, readwrite) PayPalPayment *payment;
@property(nonatomic, strong, readwrite) PayPalConfiguration *config;
@property (copy) RCTResponseSenderBlock flowCompletedCallback;
@property (copy) RCTPromiseResolveBlock resolve;
@property (copy) RCTPromiseRejectBlock reject;
@property (readwrite, strong, nonatomic) NSArray *requiredParams;

@end


@implementation RNPaypal


- (dispatch_queue_t)methodQueue
{
    _requiredParams = [NSArray arrayWithObjects: @"clientId", @"environment", @"intent", @"price", @"currency", @"description", @"acceptCreditCards", nil];
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


RCT_REMAP_METHOD(paymentRequest,
                 params:(NSDictionary *)params
                 findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
    
    self.resolve = resolve;
    self.reject = reject;
    
    NSSet *requiredParamsSet = [NSSet setWithArray:_requiredParams];
    NSSet *paramsSet = [NSSet setWithArray:params.allKeys];
    
    if (![requiredParamsSet isEqualToSet:paramsSet]) {
        NSError *error = [NSError errorWithDomain:@"com.RNPaypal" code:-10 userInfo:@{@"Error reason": @"Invalid Input"}];
        self.reject(@"INVALID_PARAMS", @"Params are missing", error);
        return;
    }
    //
    //    if (![params.allKeys isEqualToArray:_requiredParams]) {
    //        NSError *error = [NSError errorWithDomain:@"com.RNPaypal" code:-10 userInfo:@{@"Error reason": @"Invalid Input"}];
    //        self.reject(@"INVALID_PARAMS", @"Params are missing", error);
    //    }
    //
    
    
    [self configureEnvironment:params];
    [self configurePaymentSettings:params];
    
    if(self.payment.processable) {
        PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:self.payment
                                                                                                    configuration:self.config
                                                                                                         delegate:self];
        UIViewController *visibleVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        do {
            if ([visibleVC isKindOfClass:[UINavigationController class]]) {
                visibleVC = [(UINavigationController *)visibleVC visibleViewController];
            } else if (visibleVC.presentedViewController) {
                visibleVC = visibleVC.presentedViewController;
            }
        } while (visibleVC.presentedViewController);
        dispatch_async(dispatch_get_main_queue(), ^{
            [visibleVC presentViewController:paymentViewController animated:YES completion:nil];
        });
    }
    
}


-(void)configureEnvironment:(NSDictionary *) params {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *envString = params[@"environment"];
        NSString *clientId = params[@"clientId"];
        
        [PayPalMobile initializeWithClientIdsForEnvironments:@{envString : clientId}];
        [PayPalMobile preconnectWithEnvironment:envString];
    });
}

-(void)configurePaymentSettings:(NSDictionary *) params {
    self.payment = [[PayPalPayment alloc] init];
    self.config = [[PayPalConfiguration alloc] init];

    _payment.amount = params[@"price"];
    _payment.intent = [params[@"intent"] intValue];
    _payment.currencyCode = params[@"currency"];
    _payment.shortDescription = params[@"description"];

    _config.acceptCreditCards = [params[@"acceptCreditCards"] boolValue];
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"INTENT": @{
                     @"SALE":@0,
                     @"AUTHORIZE":@1,
                     @"ORDER":@2
                     
                     },
             @"ENVIRONMENT": @{
                     @"SANDBOX": PayPalEnvironmentSandbox,
                     @"PRODUCTION":PayPalEnvironmentProduction,
                     @"NO_NETWORK":PayPalEnvironmentNoNetwork
                     }
             };
}



- (void)payPalPaymentDidCancel:(nonnull PayPalPaymentViewController *)paymentViewController {
    [paymentViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (self.reject) {
            NSError *error = [NSError errorWithDomain:@"com.RNPaypal" code:-40 userInfo:@{@"Error reason": @"Invalid Input"}];
            self.reject(@"USER_CANCELLED", @"User cancelled", error);
        }
    }];
}

- (void)payPalPaymentViewController:(nonnull PayPalPaymentViewController *)paymentViewController didCompletePayment:(nonnull PayPalPayment *)completedPayment {
    
    [paymentViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if(self.resolve) {
            self.resolve(completedPayment.confirmation);
        }
    }];
    
    
}

@end

