// app/javascript/controllers/camera_controller.js
//
// Usage: one controller instance per camera block.
// Connect it with data-controller="camera" on each .camera-block div.
// Set data-camera-field-value to the name of the hidden file input (e.g. "tag_image").

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "startbtn", "retakebtn", "canvas", "preview", "input"]
  static values = { field: String }

  connect() {
    this.width = 400
    this.height = 0
    this.streaming = false

    this.videoTarget.addEventListener("canplay", () => {
      if (!this.streaming) {
        this.height = this.videoTarget.videoHeight / (this.videoTarget.videoWidth / this.width)
        this.videoTarget.setAttribute("width", this.width)
        this.videoTarget.setAttribute("height", this.height)
        this.canvasTarget.setAttribute("width", this.width)
        this.canvasTarget.setAttribute("height", this.height)
        this.streaming = true
      }
    })

    // Auto-start back camera (falls back to any camera on desktop)
    this.startStream({ facingMode: { ideal: "environment" } })
  }

  async startStream(videoConstraints) {
    // Stop previous stream (required on iPhone)
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
    }

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: videoConstraints,
        audio: false
      })

      this.videoTarget.srcObject = this.stream
      this.videoTarget.play()
      this.videoTarget.style.display = "block"

      // Reset UI
      this.previewTarget.style.display = "none"
      this.retakebtnTarget.style.display = "none"
      this.startbtnTarget.style.display = "inline-block"
      this.startbtnTarget.dataset.action = "click->camera#capture"

    } catch (err) {
      console.error("Camera error:", err)
      alert("Unable to access this camera on your device.")
    }
  }

  capture() {
    const context = this.canvasTarget.getContext("2d")
    context.drawImage(this.videoTarget, 0, 0, this.width, this.height)

    this.canvasTarget.toBlob((blob) => {
      const file = new File([blob], `${this.fieldValue}.jpg`, { type: "image/jpeg" })
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      this.inputTarget.files = dataTransfer.files

      this.previewTarget.src = URL.createObjectURL(blob)
      this.previewTarget.style.display = "block"
      this.videoTarget.style.display = "none"
      this.startbtnTarget.style.display = "none"
      this.retakebtnTarget.style.display = "inline-block"
    }, "image/jpeg")
  }

  retake() {
    this.previewTarget.src = ""
    this.previewTarget.style.display = "none"
    this.inputTarget.value = ""
    this.retakebtnTarget.style.display = "none"
    this.videoTarget.style.display = "block"
    this.startbtnTarget.style.display = "inline-block"
  }
}
