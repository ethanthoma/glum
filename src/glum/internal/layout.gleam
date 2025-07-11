import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result

import gleam_community/colour as color

import glum/element.{type Element, type On, type Shape}
import glum/event
import glum/gesture.{type Gesture}
import glum/internal/attribute.{type Attributes}
import glum/internal/component.{type Scheme}
import glum/internal/emitter.{type Emitter}
import glum/internal/util
import glum/style.{type Colorable}
import glum/vec

pub type Bounds {
  Bounds(x: Float, y: Float, width: Float, height: Float)
}

// TODO: it is weird that layout produces a list of effectful functions
// we should move refactor this
pub fn layout(
  element element: Element(msg),
  bounds bounds: Bounds,
  id id: String,
) -> #(List(Scheme), List(Emitter(Gesture, msg))) {
  let element.Element(tag:, shape:, on:, attributes:, children:) = element

  let assert attribute.Position(position:) =
    attribute.get(attribute.Position, attributes)
    |> result.unwrap(attribute.Position(attribute.Relative))

  let bounds = case position {
    attribute.Relative -> bounds
    attribute.Absolute(vec2) -> {
      let #(x, y) = #(vec2 |> vec.x, vec2 |> vec.y)

      let #(width, height) = component.canvas_size()
      let width = float.min(int.to_float(width) -. x, bounds.width)
      let height = float.min(int.to_float(height) -. y, bounds.height)

      Bounds(x:, y:, width:, height:)
    }
  }

  let assert attribute.Gap(gap:) =
    attribute.get(attribute.Gap, attributes:)
    |> result.unwrap(attribute.Gap(0.0))

  let assert attribute.Orientation(orientation:) =
    attribute.get(attribute.Orientation, attributes:)
    |> result.unwrap(attribute.Orientation(attribute.Vertical))

  let scheme = create_scheme(shape:, id:, attributes:, bounds:)

  let assert attribute.Padding(top:, right:, bottom:, left:) =
    attribute.get(attribute.Padding, attributes)
    |> result.unwrap(attribute.Padding(
      attribute.Top(0.0),
      attribute.Right(0.0),
      attribute.Bottom(0.0),
      attribute.Left(0.0),
    ))

  let bounds =
    Bounds(
      x: bounds.x +. left.amount,
      y: bounds.y +. top.amount,
      width: bounds.width -. { left.amount +. right.amount },
      height: bounds.height -. { top.amount +. bottom.amount },
    )

  let #(schemes, emitters) = case children {
    element.None -> #([], [])
    element.One(element) -> layout(element:, bounds:, id: id <> "." <> tag)
    element.Many(elements) -> {
      let count_elements = list.length(elements)
      let count_gaps = count_elements - 1

      let gap_space_total = int.to_float(int.max(0, count_gaps)) *. gap

      use <- util.apply_with({
        use #(schemes, emitters) <- util.param
        let schemes = list.flatten(schemes)
        let emitters = list.flatten(emitters)
        #(schemes, emitters)
      })

      use <- util.apply_with(list.unzip)

      use element, index <- list.index_map(elements)

      let bounds = case orientation {
        attribute.Horizontal -> {
          let width =
            { bounds.width -. gap_space_total } /. int.to_float(count_elements)
          let x = bounds.x +. { { width +. gap } *. int.to_float(index) }

          Bounds(..bounds, x:, width:)
        }

        attribute.Vertical -> {
          let height =
            { bounds.height -. gap_space_total } /. int.to_float(count_elements)
          let y = bounds.y +. { { height +. gap } *. int.to_float(index) }

          Bounds(..bounds, y:, height:)
        }
      }

      let id = id <> "[" <> int.to_string(index) <> "]"
      layout(element:, bounds:, id:)
    }
  }

  let schemes =
    scheme
    |> option.map(list.prepend(schemes, _))
    |> option.unwrap(schemes)

  let emitters =
    create_emitter(on:, bounds:, id:)
    |> option.map(list.prepend(emitters, _))
    |> option.unwrap(emitters)

  #(schemes, emitters)
}

fn create_scheme(
  shape shape: Shape,
  id id: String,
  attributes attributes: Attributes,
  bounds bounds: Bounds,
) -> Option(Scheme) {
  case shape {
    element.Rect -> {
      let id = id <> ".rect"
      let color = get_color(attributes:, colorable: style.Background)
      use color <- option.map(option.from_result(color))

      component.Rect(
        id:,
        position: vec.vec2(bounds.x, bounds.y),
        size: vec.vec2(bounds.width, bounds.height),
        color:,
      )
    }

    element.Text(content:) -> {
      let id = id <> ".text"
      let assert attribute.FontSize(font_size:) =
        attribute.get(attribute.FontSize, attributes)
        |> result.unwrap(attribute.FontSize(20))
      let color =
        get_color(attributes:, colorable: style.Text)
        |> result.unwrap(color.black)

      component.Text(
        id:,
        position: vec.vec2(bounds.x, bounds.y),
        font_size:,
        color:,
        content:,
      )
      |> option.Some
    }
  }
}

fn get_color(
  attributes attributes: Attributes,
  colorable colorable: Colorable,
) -> Result(color.Color, Nil) {
  case colorable {
    style.Background -> {
      use color <- result.map(attribute.get(
        attribute.ColorBackground,
        attributes,
      ))
      let assert attribute.ColorBackground(color:) = color
      color
    }
    style.Border -> {
      use color <- result.map(attribute.get(attribute.ColorBorder, attributes))
      let assert attribute.ColorBorder(color:) = color
      color
    }
    style.Text -> {
      use color <- result.map(attribute.get(attribute.ColorText, attributes))
      let assert attribute.ColorText(color:) = color
      color
    }
  }
}

fn create_emitter(
  on on: Option(On(msg)),
  bounds bounds: Bounds,
  id id: String,
) -> Option(Emitter(Gesture, msg)) {
  use on <- option.map(on)

  use <- util.apply_with(emitter.Emitter(id:, emitter: _))

  use gesture <- util.param

  case gesture {
    gesture.Tap(x:, y:) ->
      case in_bounds(bounds:, x:, y:) {
        True -> on(gesture)
        False -> event.none()
      }
  }
}

fn in_bounds(bounds bounds: Bounds, x x: Float, y y: Float) -> Bool {
  x >=. bounds.x
  && x <=. bounds.x +. bounds.width
  && y >=. bounds.y
  && y <=. bounds.y +. bounds.height
}
