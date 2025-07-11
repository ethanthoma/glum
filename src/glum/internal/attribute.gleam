import gleam/dict.{type Dict}

import gleam_community/colour as color

import glum/vec.{type Two, type Vector}

pub opaque type Attributes {
  Attributes(Dict(String, Attribute))
}

pub type Attribute {
  Width(width: Float)
  Height(height: Float)
  Gap(gap: Float)
  Orientation(orientation: Orientation)
  Padding(top: Top, right: Right, bottom: Bottom, left: Left)
  Position(position: Position)
  FontSize(font_size: Int)
  ColorBackground(color: color.Color)
  ColorBorder(color: color.Color)
  ColorText(color: color.Color)
  Content(content: String)
}

pub type Orientation {
  Horizontal
  Vertical
}

pub type Position {
  Relative
  Absolute(Vector(Two))
}

pub type Top {
  Top(amount: Float)
}

pub type Right {
  Right(amount: Float)
}

pub type Bottom {
  Bottom(amount: Float)
}

pub type Left {
  Left(amount: Float)
}

pub fn new() -> Attributes {
  Attributes(dict.new())
}

pub fn union(of a: Attributes, and b: Attributes) -> Attributes {
  let Attributes(a) = a
  let Attributes(b) = b

  let #(a, b) = case dict.size(a) < dict.size(b) {
    True -> #(a, b)
    False -> #(b, a)
  }

  dict.fold(over: a, from: b, with: dict.insert) |> Attributes
}

pub fn add(
  attributes attributes: Attributes,
  attribute attribute: Attribute,
) -> Attributes {
  let Attributes(attributes) = attributes
  let key = add_key(attribute)
  dict.insert(attributes, key, attribute)
  |> Attributes
}

@external(javascript, "./attribute.ffi.mjs", "add_key")
fn add_key(any: any) -> String

pub fn get(attribute: any, attributes attributes: Attributes) {
  let key = get_key(attribute)
  let Attributes(attributes) = attributes
  dict.get(attributes, key)
}

@external(javascript, "./attribute.ffi.mjs", "get_key")
fn get_key(any: any) -> String
