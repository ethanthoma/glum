import gleam/result

import gleam_community/colour as color

import glum/element.{type Element, Element}
import glum/internal/attribute.{type Attributes}
import glum/vec.{type Two, type Vector}

pub type Orientation {
  Horizontal
  Vertical
}

pub type Position {
  Relative
  Absolute(Vector(Two))
}

pub type Side {
  // NO SIDE
  None

  // ONE SIDE
  Top
  Right
  Bottom
  Left

  // TWO SIDES
  Block
  Inline

  // FOUR SIDES
  All
}

pub type Colorable {
  Background
  Border
  Text
}

pub fn style(
  style style: fn(Attributes) -> Attributes,
  element element: fn() -> Element(msg),
) {
  let element = element()

  case element {
    Element(attributes:, ..) ->
      Element(..element, attributes: style(attributes))
  }
}

fn add(
  attribute attribute: attribute.Attribute,
  element element: fn() -> Element(msg),
) {
  let element = element()

  case element {
    Element(attributes:, ..) ->
      Element(..element, attributes: attribute.add(attributes:, attribute:))
  }
}

pub fn gap(
  gap gap: Float,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  add(attribute.Gap(gap:), element)
}

pub fn orient(
  orientation orientation: Orientation,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  let orientation = case orientation {
    Vertical -> attribute.Vertical
    Horizontal -> attribute.Horizontal
  }

  add(attribute.Orientation(orientation: orientation), element)
}

pub fn pad(
  side side: Side,
  amount amount: Float,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  let element = element()

  case element {
    Element(attributes:, ..) -> {
      let padding =
        attribute.Padding(
          top: attribute.Top(0.0),
          right: attribute.Right(0.0),
          bottom: attribute.Bottom(0.0),
          left: attribute.Left(0.0),
        )

      let padding =
        attribute.get(attribute.Padding, attributes)
        |> result.unwrap(padding)

      let assert attribute.Padding(..) = padding

      let padding = case side {
        None -> padding

        Top -> attribute.Padding(..padding, top: attribute.Top(amount:))
        Right -> attribute.Padding(..padding, right: attribute.Right(amount:))
        Bottom ->
          attribute.Padding(..padding, bottom: attribute.Bottom(amount:))
        Left -> attribute.Padding(..padding, left: attribute.Left(amount:))

        Block ->
          attribute.Padding(
            ..padding,
            top: attribute.Top(amount:),
            bottom: attribute.Bottom(amount:),
          )
        Inline ->
          attribute.Padding(
            ..padding,
            right: attribute.Right(amount:),
            left: attribute.Left(amount:),
          )

        All ->
          attribute.Padding(
            top: attribute.Top(amount:),
            right: attribute.Right(amount:),
            bottom: attribute.Bottom(amount:),
            left: attribute.Left(amount:),
          )
      }

      add(padding, fn() { element })
    }
  }
}

pub fn place(
  position position: Position,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  let position = case position {
    Relative -> attribute.Relative
    Absolute(vec) -> attribute.Absolute(vec)
  }

  add(attribute.Position(position:), element)
}

pub fn color(
  colorable colorable: Colorable,
  color color: color.Color,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  let attribute = case colorable {
    Background -> attribute.ColorBackground(color)
    Border -> attribute.ColorBorder(color)
    Text -> attribute.ColorText(color)
  }

  add(attribute:, element:)
}

pub fn font_size(
  font_size font_size: Int,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  add(attribute.FontSize(font_size:), element:)
}

pub fn content(
  content content: String,
  element element: fn() -> Element(msg),
) -> Element(msg) {
  add(attribute.Content(content:), element:)
}
