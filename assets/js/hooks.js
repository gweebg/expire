import ClipboardJS from "clipboard";

let Hooks = {}

Hooks.Flash = {
  mounted(){
    let hide = () => liveSocket.execJS(this.el, this.el.getAttribute("phx-click"))
    this.timer = setTimeout(() => hide(), 3000)
    this.el.addEventListener("phx:hide-start", () => clearTimeout(this.timer))
    this.el.addEventListener("mouseover", () => {
      clearTimeout(this.timer)
      this.timer = setTimeout(() => hide(), 3000)
    })
  },
  destroyed(){ clearTimeout(this.timer) }
}

Hooks.Clipboard = {
  mounted() {
    this.clipboard = new ClipboardJS(this.el);

    this.clipboard.on("success", (e) => {
      e.clearSelection();

      const swap = this.el.querySelector('[data-role="clipboard-swap"]');
      if (!swap) return;

      swap.checked = true;

      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        swap.checked = false;
      }, 3000);
    });
  },
  destroyed() {
    if (this.clipboard) this.clipboard.destroy();
  }
}

export default Hooks