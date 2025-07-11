import glum/element.{type Element}
import glum/event.{type Event}
import glum/internal/util
import glum/object.{type Object}

pub opaque type App(flags, model, msg) {
  App(
    init: InitFn(flags, model, msg),
    update: UpdateFn(model, msg),
    ui_view: UIViewFn(model, msg),
    game_view: GameViewFn(model),
  )
}

pub type InitFn(flags, model, msg) =
  fn(flags) -> #(model, Event(msg))

pub type UpdateFn(model, msg) =
  fn(model, Event(msg)) -> #(model, Event(msg))

pub type UIViewFn(model, msg) =
  fn(model) -> Element(msg)

pub type GameViewFn(model) =
  fn(model) -> Object

pub type Error =
  String

pub fn application(
  init init: InitFn(flags, model, msg),
  update update: UpdateFn(model, msg),
  ui_view ui_view: UIViewFn(model, msg),
  game_view game_view: GameViewFn(model),
) -> App(flags, model, msg) {
  App(init:, update:, ui_view:, game_view:)
}

pub fn start(app app: App(flags, model, msg), with flags: flags) -> Nil {
  do_start(app:, flags:)
}

@external(javascript, "./glum.ffi.mjs", "start")
fn do_start(app app: App(flags, model, msg), flags flags: flags) -> Nil

pub type Tick {
  Tick
}

@external(javascript, "./glum.ffi.mjs", "getDeltaTime")
pub fn get_delta_time() -> Float

// ** UTILS ** //

pub const param = util.param

pub const defer = util.defer

pub const apply = util.apply

pub const apply_with = util.apply_with

pub const func = util.func

pub const identity = util.identity

@external(javascript, "./glum.ffi.mjs", "print")
pub fn print(dyn: any) -> Nil
