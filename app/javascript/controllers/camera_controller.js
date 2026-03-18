// app/javascript/controllers/camera_controller.js
//
// Usage: one controller instance per camera block.
// Connect it with data-controller="camera" on each .camera-block div.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startButton",
    "video",
    "captureButton",
    "canvas",
    "preview",
    "retakeButton",
    "status",
    "hiddenInput"
  ]

  // data-camera-filename-value="tag_image.jpg"
  static values = {
    filename: String
  }

  stream = null

  // ── 1. Start camera ──────────────────────────────────────────────────────
  async start() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" }
      })
      this.videoTarget.srcObject = this.stream

      this.startButtonTarget.hidden  = true
      this.videoTarget.hidden        = false
      this.captureButtonTarget.hidden = false
      this.statusTarget.textContent  = ""
    } catch (err) {
      this.statusTarget.textContent = "⚠️ Could not access camera. Please allow camera permissions."
      console.error("Camera error:", err)
    }
  }

  // ── 2. Capture photo ─────────────────────────────────────────────────────
  capture() {
    const { videoTarget, canvasTarget, previewTarget } = this

    canvasTarget.width  = videoTarget.videoWidth
    canvasTarget.height = videoTarget.videoHeight
    canvasTarget.getContext("2d").drawImage(videoTarget, 0, 0)

    previewTarget.src    = canvasTarget.toDataURL("image/jpeg")
    previewTarget.hidden = false

    this.#stopStream()

    videoTarget.hidden         = true
    this.captureButtonTarget.hidden = true
    this.retakeButtonTarget.hidden  = false
    this.statusTarget.textContent   = "✅ Photo captured."

    // Bridge: canvas → File → hidden input
    canvasTarget.toBlob((blob) => {
      const file = new File([blob], this.filenameValue || "photo.jpg", { type: "image/jpeg" })
      const dt   = new DataTransfer()
      dt.items.add(file)
      this.hiddenInputTarget.files = dt.files
    }, "image/jpeg", 0.92)
  }

  // ── 3. Retake ─────────────────────────────────────────────────────────────
  async retake() {
    this.previewTarget.src          = ""
    this.previewTarget.hidden       = true
    this.retakeButtonTarget.hidden  = true
    this.hiddenInputTarget.value    = ""
    this.statusTarget.textContent   = ""

    await this.start()
  }

  // ── Cleanup on disconnect (e.g. Turbo navigation) ────────────────────────
  disconnect() {
    this.#stopStream()
  }

  // ── Private ───────────────────────────────────────────────────────────────
  #stopStream() {
    this.stream?.getTracks().forEach(track => track.stop())
    this.stream = null
  }
}
