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
  constructor() {
  }
  isEnabled() {
    console.log("Enabled");
    return true;
  }
};
//# sourceMappingURL=time_travel.cjs.js.map
