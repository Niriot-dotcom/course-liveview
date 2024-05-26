import { AsYouType } from "../vendor/libphonenumber-js.min";

let PhoneNumberHook = {
  mounted() {
    console.log("Phone Number HOOK mounted", this.el);
    this.el.addEventListener("input", (e) => {
      this.el.value = new AsYouType("US").input(e.target.value);
    });
  },

  destroyed() {},
};

export default PhoneNumberHook;
