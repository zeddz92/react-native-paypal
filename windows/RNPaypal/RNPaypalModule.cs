using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Paypal.RNPaypal
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNPaypalModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNPaypalModule"/>.
        /// </summary>
        internal RNPaypalModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNPaypal";
            }
        }
    }
}
