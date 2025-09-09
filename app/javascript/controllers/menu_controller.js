import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]

  connect() {
    this.boundOutside = this.handleOutside.bind(this)
    this.boundEscape  = this.handleEscape.bind(this)
    document.addEventListener("click", this.boundOutside)
    document.addEventListener("keydown", this.boundEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.boundOutside)
    document.removeEventListener("keydown", this.boundEscape)
  }

  toggle(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    // PCでは panel に md:hidden が効いているため、そもそも開かない仕様
    this.panelTarget.classList.toggle("hidden")
    this.updateAria()
  }

  handleOutside(e) {
    // メニュー外をクリックしたら閉じる（モバイル時のみ意味がある）
    if (!this.element.contains(e.target)) {
      if (!this.panelTarget.classList.contains("hidden")) {
        this.panelTarget.classList.add("hidden")
        this.updateAria()
      }
    }
  }

  handleEscape(e) {
    if (e.key === "Escape" && !this.panelTarget.classList.contains("hidden")) {
      this.panelTarget.classList.add("hidden")
      this.updateAria()
    }
  }

  updateAria() {
    const expanded = !this.panelTarget.classList.contains("hidden")
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", expanded.toString())
    }
  }
}
