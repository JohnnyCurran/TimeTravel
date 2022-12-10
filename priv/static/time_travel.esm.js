// js/time_travel/time_travel.js
var TimeTravel = class {
  constructor(Socket, socketId) {
    let timeTravelSocket = new Socket("/socket");
    timeTravelSocket.connect();
    let channel = timeTravelSocket.channel("lvdbg:" + socketId);
    channel.join().receive("ok", ({ messages }) => console.log("catching up", messages)).receive("error", ({ reason }) => console.log("failed join", reason)).receive("timeout", () => console.log("Networking issue. Still waiting..."));
    channel.on("lv_event", (payload) => {
      window.dispatchEvent(new CustomEvent("SaveAssigns", { detail: payload }));
    });
    window.addEventListener("RestoreAssigns", (e) => {
      console.log("restore", e);
      channel.push("restore-assigns", { ...e.detail, socketId });
    });
    window.addEventListener("ClearAssigns", (_e) => {
      console.log("clear");
      channel.push("clear-assigns", {});
    });
  }
  isEnabled() {
    console.log("Enabled");
    console.log(window);
    window.dispatchEvent(new CustomEvent("TimeTravelEvent", { detail: {} }));
    return true;
  }
};
export {
  TimeTravel
};
//# sourceMappingURL=time_travel.esm.js.map
