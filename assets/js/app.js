// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

let Hooks = {};
Hooks.GuessedPrice = {
  mounted() {
    this.el.addEventListener("input", (event) => {
      let value = event.target.value;
      let validValue = value.match(/^\d+(\.\d{0,2})?/)?.[0] || "";

      // Strip unnecessary leading zeros unless it's just "0" or starts with "0."
      if (
        validValue.startsWith("0") &&
        !validValue.startsWith("0.") &&
        validValue.length > 1
      ) {
        validValue = validValue.replace(/^0+/, "");
        if (validValue === "") validValue = "0";
      }

      if (value !== validValue) {
        event.target.value = validValue;
      }
    });
  },
};

Hooks.ScoreAnimation = {
  mounted() {
    this.handleEvent("animate_score", () => {
      let elem = document.getElementById("score-flash");

      // Remove opacity and reset position
      elem.classList.remove("opacity-0");

      // Force a reflow to restart animation
      void elem.offsetWidth;

      // Apply animation (float up) duration-500 tailwind
      elem.classList.add("opacity-100", "-translate-y-6");

      // Make it disappear
      setTimeout(() => {
        elem.classList.remove("opacity-100", "-translate-y-6");
        elem.classList.add("opacity-0");
      }, 500);
    });
  },
};

Hooks.CountdownTimer = {
  mounted() {
    const totalTime = 30;
    const countdownElement = this.el.querySelector("span");
    const progressBar = this.el.querySelector("#progress-bar");
    const endTime = Date.now() + totalTime * 1000;

    // Update the countdown every second
    const updateCountdown = () => {
      const remainingMs = endTime - Date.now();
      const countdownValue = Math.max(0, Math.ceil(remainingMs / 1000));

      countdownElement.innerHTML = countdownValue;
      const progress = (countdownValue / totalTime) * 100;
      progressBar.style.width = `${progress}%`;
      if (countdownValue > 0) {
        setTimeout(updateCountdown, 1000);
      } else {
        // Once the countdown finishes, push an event to LiveView (if necessary)
        this.pushEvent("countdown_completed", {});
      }
    };

    // Start the countdown
    updateCountdown();
  },
};

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
