import flatpickr from "../vendor/flatpickr";
import PhoneNumber from "./PhoneNumberHook";
import Clipboard from "./ClipboardHook";

let Hooks = {
  PhoneNumber,
  Clipboard,
};

Hooks.Calendar = {
  mounted() {
    console.log("Calendar HOOK mounted", this.el);
    this.pickr = flatpickr(this.el, {
      inline: true,
      mode: "range",
      showMonths: 2,
      // disable: JSON.parse(this.el.dataset.unavailableDates),
      onChange: (selectedDates) => {
        if (selectedDates.length != 2) return;
        // selectedDates = selectedDates.map((date) => this.utcStartOfDay(date));
        this.pushEvent("dates-picked", selectedDates);
      },
    });

    this.handleEvent("add-unavailable-dates", (dates) => {
      this.pickr.set("disable", [dates, ...this.pickr.config.disable]);
    });

    this.pushEvent("unavailable-dates", {}, (reply, ref) => {
      this.pickr.set("disable", reply.dates);
    });
  },
  destroyed() {
    this.pickr.destroy();
  },
  updated() {
    console.log("CALENDAR HOOK updated");
  },
  utcStartOfDay(date) {
    const newDate = new Date(date);
    // important to set it in descending order, smaller time units
    // can shift bigger ones, if those are not already set in UTC.
    newDate.setUTCFullYear(date.getFullYear());
    newDate.setUTCMonth(date.getMonth());
    newDate.setUTCDate(date.getDate());
    newDate.setUTCHours(0, 0, 0, 0);
    return newDate;
  },
};

export default Hooks;
