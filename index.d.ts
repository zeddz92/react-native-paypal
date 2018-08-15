
declare module "react-native-paypal" {

    export interface ENVIRONMENT {
        NO_NETWORK: number,
        SANDBOX: number,
        PRODUCTION: number
    }

    export interface INTENT {
        SALE: number,
        AUTHORIZE: number,
        ORDER: number
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
        acceptCreditCards: boolean
    }

    export class RNPaypal {
        static paymentRequest(params: PaymentParams):Promise<PaymentConfirmation>;
        static ENVIRONMENT: ENVIRONMENT;
        static INTENT: INTENT;
    }

    export default RNPaypal;

}