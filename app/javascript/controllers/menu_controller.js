import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]

  connect() {
    this.boundOutside = this.handleOutside.bind(this)
    this.boundEscape  = this.handleEscape.bind(this)

    document.addEventListener("click", this.boundOutside)
    document.addEventListener("keydown", this.boundEscape)

    // Turbo遷移のたびに閉じる
    document.addEventListener("turbo:before-visit", () => this.close())
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

    const isHidden = this.panelTarget.classList.toggle("hidden")
    this.updateAria(!isHidden)
  }

  close() {
    if (!this.panelTarget.classList.contains("hidden")) {
      this.panelTarget.classList.add("hidden")
      this.updateAria(false)
    }
  }

  handleOutside(e) {
    if (!this.element.contains(e.target)) {
      this.close()
    }
  }

  handleEscape(e) {
    if (e.key === "Escape") {
      this.close()
    }
  }

  updateAria(expanded) {
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", expanded.toString())
    }
  }
}
