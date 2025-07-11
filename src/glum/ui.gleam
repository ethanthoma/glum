import gleam/list
import gleam/option.{type Option}

import glum/element.{type Element}
import glum/event
import glum/gesture
import glum/internal/attribute
import glum/internal/util

// ** ELEMENT CONSTRUCTORS **

pub fn none() {
  element.Element(
    tag: "",
    shape: element.Rect,
    attributes: attribute.new(),
    on: option.None,
    children: element.None,
  )
}

pub fn text(content content: String) -> Element(msg) {
  element.Element(
    tag: "text",
    shape: element.Text(content:),
    attributes: attribute.new(),
    on: option.None,
    children: element.None,
  )
}

pub fn button(on_tap msg: msg) -> Element(msg) {
  element.Element(
    tag: "button",
    shape: element.Rect,
    attributes: attribute.new(),
    on: option.Some({
      use gesture <- util.param

      case gesture {
        gesture.Tap(..) -> event.Custom(msg:)
      }
    }),
    children: element.None,
  )
}

// ** ELEMENT COMBINERS **

pub fn has(
  element element: Element(msg),
  children children: fn() -> Element(msg),
) {
  element.Element(..element, children: element.One(children()))
}

pub fn wrap(element children: fn() -> Element(msg)) {
  let children = children()

  element.Element(
    tag: "wrap",
    shape: element.Rect,
    attributes: attribute.new(),
    on: option.None,
    children: element.One(children),
  )
}

pub opaque type Done(msg) {
  Done(List(Element(msg)))
}

pub fn list(
  f: fn(fn(Element(msg), fn() -> Done(msg)) -> Done(msg), Done(msg)) ->
    Done(msg),
) -> element.Element(msg) {
  let Done(elements) = {
    use first, done <- f(_, Done([]))
    let Done(rest) = done()
    Done([first, ..rest])
  }
  group(elements)
}

pub fn before(rest rest: Element(msg), this first: fn() -> Element(msg)) {
  let first = first()

  case first, rest {
    element.Element(
      attributes: attributes_first,
      on: on_first,
      children: element.Many(children_first),
      ..,
    ),
      element.Element(
        attributes: attributes_rest,
        on: on_rest,
        children: element.Many(children_rest),
        ..,
      )
    ->
      element.Element(
        tag: "group",
        shape: element.Rect,
        attributes: attribute.union(attributes_first, attributes_rest),
        on: merge_on(on_first, on_rest),
        children: element.Many(list.append(children_first, children_rest)),
      )

    element.Element(attributes:, on:, children: element.Many(children), ..), _ ->
      element.Element(
        tag: "group",
        shape: element.Rect,
        attributes:,
        on:,
        children: element.Many(list.append(children, [rest])),
      )

    _, element.Element(attributes:, on:, children: element.Many(children), ..) ->
      element.Element(
        tag: "group",
        shape: element.Rect,
        attributes:,
        on:,
        children: element.Many([first, ..children]),
      )

    _, _ -> group([first, rest])
  }
}

pub fn after(
  this first: Element(msg),
  rest rest: fn() -> Element(msg),
) -> Element(msg) {
  before(rest(), util.func(first))
}

pub fn group(elements children: List(Element(msg))) {
  element.Element(
    tag: "group",
    shape: element.Rect,
    attributes: attribute.new(),
    on: option.None,
    children: element.Many(children),
  )
}

// ** UTIL **

fn merge_on(a: Option(element.On(msg)), b: Option(element.On(msg))) {
  case a, b {
    option.Some(a), option.Some(b) ->
      option.Some(fn(gesture) { event.Sequence([a(gesture), b(gesture)]) })
    option.Some(_), _ -> a
    _, option.Some(_) -> b
    _, _ -> option.None
  }
}
