// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// 既存の自動ロード
eagerLoadControllersFrom("controllers", application)

// --- 追加: SortableJS用 Stimulus Controller ---
import SortableController from "./sortable_controller"
application.register("sortable", SortableController)
