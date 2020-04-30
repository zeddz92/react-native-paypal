
declare module "react-native-paypal-lib" {

    export interface ENVIRONMENT {
        NO_NETWORK,
        SANDBOX,
        PRODUCTION
    }

    export interface INTENT {
        SALE,
        AUTHORIZE,
        ORDER
    }

    export interface PayPalPayment {
        environment: string,
        paypal_sdk_version: string,
        platform: string,
        product_name: string
    }

    export interface ProofOfPayment {
        create_time: string,
        id: string,
        intent: string,
        state: string
    }

    export interface PaymentConfirmation {
        client: PayPalPayment,
        response: ProofOfPayment,
        response_type: string
    }

    export interface PaymentParams {
        clientId: string,
        environment: ENVIRONMENT,
        intent: INTENT,
        price: number,
        currency: string,
        description: string,
        locale: string,
        acceptCreditCards: boolean
    }

    export class RNPaypal {
        static paymentRequest(params: PaymentParams):Promise<PaymentConfirmation>;
        static ENVIRONMENT: ENVIRONMENT;
        static INTENT: INTENT;
    }

    export default RNPaypal;
}