var TimeTravel = (() => {
  var __defProp = Object.defineProperty;
  var __defProps = Object.defineProperties;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getOwnPropSymbols = Object.getOwnPropertySymbols;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __propIsEnum = Object.prototype.propertyIsEnumerable;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __spreadValues = (a, b) => {
    for (var prop in b || (b = {}))
      if (__hasOwnProp.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    if (__getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(b)) {
        if (__propIsEnum.call(b, prop))
          __defNormalProp(a, prop, b[prop]);
      }
    return a;
  };
  var __spreadProps = (a, b) => __defProps(a, __getOwnPropDescs(b));
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

  // js/time_travel/time_travel.js
  var TimeTravel = class {
    constructor(Socket) {
      let socketId = document.querySelector("div[data-phx-main]").getAttribute("id");
      let timeTravelSocket = new Socket("/socket");
      timeTravelSocket.connect();
      let channel = timeTravelSocket.channel("lvdbg:" + socketId);
      channel.join().receive("ok", ({ messages }) => console.log("catching up", messages)).receive("error", ({ reason }) => console.log("failed join", reason)).receive("timeout", () => console.log("Networking issue. Still waiting..."));
      channel.on("lv_event", (payload) => {
        window.dispatchEvent(new CustomEvent("SaveAssigns", { detail: payload }));
      });
      window.addEventListener("RestoreAssigns", (e) => {
        channel.push("restore-assigns", __spreadProps(__spreadValues({}, e.detail), { socketId }));
      });
      window.addEventListener("ClearAssigns", (_e) => {
        channel.push("clear-assigns", {});
      });
    }
  };
  return __toCommonJS(time_travel_exports);
})();
