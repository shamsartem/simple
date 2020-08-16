// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

let Hooks = {}
Hooks.Autocomplete = {
  mounted() {
    this.el.addEventListener('input', (e) => {
      if (Array.from(e.target.list.options).map(o => o.value).includes(e.target.value)) {
        const allInputs = document.querySelectorAll('#transaction-form input')
        setTimeout(() => {
          const nextInput = allInputs[Array.from(allInputs).findIndex((el) => el === e.target) + 1]
          if (nextInput) {
            nextInput.focus()
          } else {
            document.querySelector('#transaction-form button[type="submit"]').focus()
          }
        });
      }
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

// function keepAlive() {
//   fetch('/keep-alive')
//     .then(() => new Promise(resolve => setTimeout(resolve, 60000)))
//     .then(keepAlive)
// }

// keepAlive()
