import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// controllers 配下の *_controller.js を自動登録（これだけでOK）
eagerLoadControllersFrom("controllers", application)

// ★手動 register は削除（重複登録になり得ます）
// import SortableController from "./sortable_controller"
// import MenuController     from "./menu_controller"
// application.register("sortable", SortableController)
// application.register("menu", MenuController)
