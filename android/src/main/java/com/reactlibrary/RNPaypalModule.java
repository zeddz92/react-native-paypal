
package com.reactlibrary;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.paypal.android.sdk.payments.PayPalConfiguration;
import com.paypal.android.sdk.payments.PayPalPayment;
import com.paypal.android.sdk.payments.PayPalService;
import com.paypal.android.sdk.payments.PaymentActivity;
import com.paypal.android.sdk.payments.PaymentConfirmation;

import org.json.JSONException;
import org.json.JSONObject;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import com.reactlibrary.utils.BundleJSONConverter;


public class RNPaypalModule extends ReactContextBaseJavaModule  {

  private final ReactApplicationContext reactContext;
  private Promise mPromise;

  private static final int PAYPAL_REQUEST = 209;
  private static final String ERROR_USER_CANCELLED = "USER_CANCELLED";
  private static final String ERROR_INVALID_CONFIG = "INVALID_CONFIG";
  private static final String E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST";
  private static final String E_INVALID_JSON = "E_INVALID_JSON";

  private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
      handleActivityResult(activity, requestCode, resultCode, intent);
    }
  };


  public RNPaypalModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    reactContext.addActivityEventListener(mActivityEventListener);
  }

  @Override
  public String getName() {
    return "RNPaypal";
  }

  @ReactMethod
  public void paymentRequest(final ReadableMap payPalParameters, final Promise promise) {
    Activity currentActivity = getCurrentActivity();

    mPromise = promise;

    if (currentActivity == null) {
      promise.reject(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist");
      return;
    }

    final String environment = payPalParameters.getString("environment");
    final String intent = payPalParameters.getString("intent");
    final String clientId = payPalParameters.getString("clientId");
    final double price = payPalParameters.getDouble("price");
    final String currency = payPalParameters.getString("currency");
    final String description = payPalParameters.getString("description");
    final boolean acceptCreditCards = payPalParameters.getBoolean("acceptCreditCards");

    PayPalConfiguration config =
            new PayPalConfiguration().environment(environment).clientId(clientId);

    config.acceptCreditCards(acceptCreditCards);

    startPayPalService(config);

    PayPalPayment thingToBuy =
            new PayPalPayment(new BigDecimal(price), currency, description,
                    intent);

    Intent paypalIntent =
            new Intent(reactContext.getBaseContext(), PaymentActivity.class)
                    .putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config)
                    .putExtra(PaymentActivity.EXTRA_PAYMENT, thingToBuy);

    reactContext.startActivityForResult(paypalIntent, PAYPAL_REQUEST, new Bundle());


  }

  private void startPayPalService(PayPalConfiguration config) {
    Intent intent = new Intent(reactContext, PayPalService.class);
    intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config);


    reactContext.startService(intent);

  }

  @Nullable
  @Override
  public Map<String, Object> getConstants() {
    Log.v("getConstants", "handleActivityResult");
    final Map<String, Object> constants = new HashMap<>();

    final Map<String, Object> environment = new HashMap<>();
    final Map<String, Object> intent = new HashMap<>();

    intent.put("SALE", PayPalPayment.PAYMENT_INTENT_SALE);
    intent.put("AUTHORIZE", PayPalPayment.PAYMENT_INTENT_AUTHORIZE);
    intent.put("ORDER", PayPalPayment.PAYMENT_INTENT_ORDER);

    environment.put("NO_NETWORK", PayPalConfiguration.ENVIRONMENT_NO_NETWORK);
    environment.put("SANDBOX", PayPalConfiguration.ENVIRONMENT_SANDBOX);
    environment.put("PRODUCTION", PayPalConfiguration.ENVIRONMENT_PRODUCTION);

    constants.put("ENVIRONMENT", environment);
    constants.put("INTENT", intent);

    return constants;
  }

  public void handleActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    Log.v("onActivityResult", "handleActivityResult");
    if (requestCode != PAYPAL_REQUEST) {
      return;
    }

    if (resultCode == Activity.RESULT_OK) {
      PaymentConfirmation confirm =
              data.getParcelableExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION);
      if (confirm != null) {
        try {
            Bundle bundle = BundleJSONConverter.convertToBundle(confirm.toJSONObject());
            WritableMap map = Arguments.fromBundle(bundle);
            mPromise.resolve(map);
        } catch (JSONException e) {
          mPromise.reject(E_INVALID_JSON, "Invalid json");
        }
      }
    } else if (resultCode == Activity.RESULT_CANCELED) {
      mPromise.reject(ERROR_USER_CANCELLED, "User cancelled");
    } else if (resultCode == PaymentActivity.RESULT_EXTRAS_INVALID) {
      mPromise.reject(ERROR_INVALID_CONFIG, "Invalid config");
    }
  }

  public static Bundle jsonToBundle(JSONObject jsonObject) throws JSONException {
    Bundle bundle = new Bundle();
    Iterator iter = jsonObject.keys();
    while(iter.hasNext()){
      String key = (String)iter.next();
      String value = jsonObject.getString(key);
      bundle.putString(key,value);
    }
    return bundle;
  }

}