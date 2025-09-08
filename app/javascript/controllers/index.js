import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// controllers/*_controller.js は自動で登録されます
eagerLoadControllersFrom("controllers", application)
