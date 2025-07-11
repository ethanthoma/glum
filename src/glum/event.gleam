import gleam/list

import glum/gesture.{type Gesture}

pub type Event(msg) {
  // Basic events
  NoOp
  Quit

  // Game Loop events
  Tick(delta: Float)
  Gesture(Gesture)

  // Msg Events
  Custom(msg: msg)
  Effect(fn(fn(Event(msg)) -> Nil) -> Nil)
  Sequence(List(Event(msg)))
}

pub fn none() -> Event(msg) {
  NoOp
}

pub fn tick(delta: Float) -> Event(msg) {
  Tick(delta: delta)
}

pub fn effect(handler: fn(fn(Event(msg)) -> Nil) -> Nil) -> Event(msg) {
  Effect(handler)
}

pub fn sequence(list: List(Event(msg))) -> Event(msg) {
  Sequence(list)
}

pub fn map(event event: Event(a), with f: fn(a) -> b) -> Event(b) {
  case event {
    NoOp -> NoOp
    Quit -> Quit
    Tick(delta) -> Tick(delta)
    Gesture(g) -> Gesture(g)
    Custom(msg) -> Custom(f(msg))
    Effect(handler) ->
      Effect(fn(dispatch) {
        handler(fn(inner_event) { dispatch(map(inner_event, f)) })
      })
    Sequence(events) -> Sequence(list.map(events, map(_, f)))
  }
}

pub fn append(to list: Event(msg), this item: fn() -> Event(msg)) -> Event(msg) {
  [item(), list] |> Sequence
}

@external(javascript, "./event.ffi.mjs", "dispatch")
pub fn dispatch(event event: Event(msg)) -> Nil
