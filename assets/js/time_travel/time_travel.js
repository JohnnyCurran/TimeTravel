export default class TimeTravel {
  // Socket is {Socket} from "phoenix"
  constructor(Socket) {
    let socketId = document.querySelector('div[data-phx-main]').getAttribute("id");
    let timeTravelSocket = new Socket("/socket")
    timeTravelSocket.connect();
    let channel = timeTravelSocket.channel('lvdbg:' + socketId);
    channel.join()
      .receive("ok", ({messages}) => console.log("catching up", messages) )
      .receive("error", ({reason}) => console.log("failed join", reason) )
      .receive("timeout", () => console.log("Networking issue. Still waiting..."))

    channel.on('SaveAssigns', payload => {
      console.log('SaveAssigns', payload);
      window.dispatchEvent(new CustomEvent('SaveAssigns', {detail: payload}));
    });

    window.addEventListener('RestoreAssigns', e => {
      console.log('restore', e.detail);
      channel.push("restore-assigns", {...e.detail, socketId: socketId});
    });

    window.addEventListener('ClearAssigns', _e => {
      channel.push("clear-assigns", {});
    });
  }
}
