export default class TimeTravel {
  // Socket is {Socket} from "phoenix"
  constructor(Socket, socketId) {
    let timeTravelSocket = new Socket("/socket")
    timeTravelSocket.connect();
    let channel = timeTravelSocket.channel('lvdbg:' + socketId);
    channel.join()
      .receive("ok", ({messages}) => console.log("catching up", messages) )
      .receive("error", ({reason}) => console.log("failed join", reason) )
      .receive("timeout", () => console.log("Networking issue. Still waiting..."))

    channel.on("lv_event", payload => {
      window.dispatchEvent(new CustomEvent('SaveAssigns', {detail: payload}));
    });

    window.addEventListener('RestoreAssigns', e => {
      console.log('restore', e);
      channel.push("restore-assigns", {...e.detail, socketId: socketId});
    });

    window.addEventListener('ClearAssigns', _e => {
      console.log('clear');
      channel.push("clear-assigns", {});
    });
  }

  isEnabled() {
    console.log('Enabled');
    console.log(window);
    window.dispatchEvent(new CustomEvent('TimeTravelEvent', {detail: {}}));
    return true;
  }
}
