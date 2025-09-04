import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel"];
  toggle(event) {
    this.panelTargets.forEach((el) => el.classList.toggle("hidden"));
    if (event?.currentTarget) {
      const expanded = event.currentTarget.getAttribute("aria-expanded") === "true";
      event.currentTarget.setAttribute("aria-expanded", (!expanded).toString());
    }
  }
  hide(event) {
    this.panelTargets.forEach((el) => el.classList.add("hidden"));
    if (event?.currentTarget) event.currentTarget.setAttribute("aria-expanded", "false");
  }
}
