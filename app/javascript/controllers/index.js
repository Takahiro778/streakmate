import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// 既存の自動ロード（controllers 配下の *_controller.js は自動登録）
eagerLoadControllersFrom("controllers", application)

// ← 自動ロードに乗らない(または明示登録したい)コントローラは個別登録
import SortableController from "./sortable_controller"
import MenuController     from "./menu_controller"   // ★追加

application.register("sortable", SortableController)
application.register("menu", MenuController)         // ★追加
