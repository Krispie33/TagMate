// app/javascript/controllers/camera_controller.js
//
// Usage: one controller instance per camera block.
// Connect it with data-controller="camera" on each .camera-block div.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startbutton",
    "video"
  ]


connect() {
  const video = this.videoTarget;
  console.log(this.videoTarget)
    this.width = 400
    this.height = 0
    this.streaming = false

    this.canvas = document.createElement("canvas")

    navigator.mediaDevices.getUserMedia({ video: true, audio: false })
    .then(function(stream) {
        this.video.srcObject = stream;
        this.video.play();
    })
    .catch(function(err) {
        console.log("An error occurred: " + err);
    });
}


}
