import glum/event.{type Event}
import glum/gesture

pub type Cond(msg) {
  Gesture(Emitter(gesture.Gesture, msg))
}

pub type Emitter(cond, msg) {
  Emitter(id: String, emitter: fn(cond) -> Event(msg))
}

type Name

pub fn register(cond cond: Cond(msg)) -> Nil {
  case cond {
    Gesture(Emitter(id: key, emitter:)) -> {
      use event <- do_register(name: name(cond:), key:)
      let assert event.Gesture(gesture) = event
      emitter(gesture)
    }
  }
}

@external(javascript, "./emitter.ffi.mjs", "register")
fn do_register(
  name name: Name,
  key key: String,
  emitter emitter: fn(Event(msg)) -> Event(msg),
) -> Nil

pub fn unregister(cond cond: Cond(msg)) -> Nil {
  case cond {
    Gesture(Emitter(id: key, ..)) -> do_unregister(name: name(cond:), key:)
  }
}

@external(javascript, "./emitter.ffi.mjs", "unregister")
fn do_unregister(name name: Name, key key: String) -> Nil

@external(javascript, "./emitter.ffi.mjs", "name")
fn name(cond cond: Cond(msg)) -> Name

pub fn dispatch(emitter emitter: Emitter(cond, msg), cond cond: cond) -> Nil {
  cond |> emitter.emitter |> event.dispatch
}
