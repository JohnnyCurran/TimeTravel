var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// js/time_travel/index.js
var time_travel_exports = {};
__export(time_travel_exports, {
  TimeTravel: () => TimeTravel
});
module.exports = __toCommonJS(time_travel_exports);

// js/time_travel/time_travel.js
var TimeTravel = class {
  constructor(Socket) {
    let socketId = document.querySelector("div[data-phx-main]").getAttribute("id");
    let timeTravelSocket = new Socket("/socket");
    timeTravelSocket.connect();
    let channel = timeTravelSocket.channel("lvdbg:" + socketId);
    channel.join().receive("ok", ({ messages }) => console.log("catching up", messages)).receive("error", ({ reason }) => console.log("failed join", reason)).receive("timeout", () => console.log("Networking issue. Still waiting..."));
    channel.on("SaveAssigns", (payload) => {
      console.log("SaveAssigns", payload);
      window.dispatchEvent(new CustomEvent("SaveAssigns", { detail: payload }));
    });
    window.addEventListener("RestoreAssigns", (e) => {
      console.log("restore", e.detail);
      channel.push("restore-assigns", { ...e.detail, socketId });
    });
    window.addEventListener("ClearAssigns", (_e) => {
      channel.push("clear-assigns", {});
    });
  }
};
//# sourceMappingURL=time_travel.cjs.js.map
