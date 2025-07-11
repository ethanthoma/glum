import glum
import glum/element.{type Element}
import glum/event.{type Event}
import glum/object.{type Object}
import glum/style
import glum/ui

pub type Model {
  Model(count: Int)
}

pub type Msg {
  Incr
  Decr
}

pub fn main() {
  glum.application(init:, update:, ui_view:, game_view:) |> glum.start(Nil)
}

fn init(_) -> #(Model, Event(Msg)) {
  #(Model(count: 0), event.none())
}

fn update(model model: Model, event event: Event(Msg)) -> #(Model, Event(Msg)) {
  let Model(count:) = model

  let count = case event {
    event.Custom(Incr) -> count + 1
    event.Custom(Decr) -> count - 1
    _ -> count
  }

  #(Model(count:), event.none())
}

fn ui_view(model model: Model) -> Element(Msg) {
  let Model(count:) = model

  use <- ui.wrap
  use append, done <- ui.list

  use <- append({
    use <- ui.has(ui.button(Incr))
    ui.text(" + ")
  })

  use <- append({ ui.text(int.to_string(count)) })

  use <- append({
    use <- ui.has(ui.button(Decr))
    ui.text(" - ")
  })

  done
}

fn game_view(model _: Model) -> Object {
  object.None
}
