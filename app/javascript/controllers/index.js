// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import CameraController from "./camera_controller"
import MachineSelectController from "./machine_select_controller"
import LoadingController from "./loading_controller"

application.register("camera", CameraController)
application.register("machine-select", MachineSelectController)
application.register("loading", LoadingController)
