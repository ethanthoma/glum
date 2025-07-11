import gleam/list
import gleam/option.{type Option}

import glum/event
import glum/gesture
import glum/internal/attribute.{type Attributes}

pub type Element(msg) {
  Element(
    tag: String,
    shape: Shape,
    attributes: Attributes,
    on: Option(On(msg)),
    children: Children(msg),
  )
}

pub type On(msg) =
  fn(gesture.Gesture) -> event.Event(msg)

pub type Children(msg) {
  None
  One(Element(msg))
  Many(List(Element(msg)))
}

pub type Shape {
  Rect
  Text(content: String)
}

pub fn map(
  element element: Element(msg1),
  with with: fn(msg1) -> msg2,
) -> Element(msg2) {
  case element {
    Element(on:, children:, ..) ->
      Element(
        ..element,
        on: option.map(on, fn(on) {
          fn(gesture) { on(gesture) |> event.map(with:) }
        }),
        children: map_loop(children:, with:),
      )
  }
}

fn map_loop(children children, with with) {
  case children {
    Many(elements) -> list.map(elements, map(_, with:)) |> Many
    One(element) -> element |> map(with:) |> One
    None -> None
  }
}
