import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    // listen to form submission
    document.addEventListener("turbo:submit-start", this.show.bind(this))
    document.addEventListener("turbo:load", this.hide.bind(this))
    document.addEventListener("turbo:before-cache", this.hide.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:submit-start", this.show.bind(this))
    document.removeEventListener("turbo:load", this.hide.bind(this))
    document.removeEventListener("turbo:before-cache", this.hide.bind(this))
  }

  show() {
    this.overlayTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden" // no scrfolling while loading
  }

  hide() {
    this.overlayTarget.classList.add("hidden")
    document.body.style.overflow = "auto" // reset scrolling
  }
}
