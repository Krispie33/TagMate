import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  connect() {
    this.element.scrollTop = this.element.scrollHeight
  }

  messagesChanged() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
