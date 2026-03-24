import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.toggle()
  }

  toggle() {
    this.submitTarget.classList.toggle("d-none", !this.inputTarget.value.trim())
  }
}
