import gleam_community/colour.{type Color}

import glum/internal/cache
import glum/vec.{type Two, type Vector}

pub type Scheme {
  Text(
    id: String,
    position: Vector(Two),
    font_size: Int,
    color: Color,
    content: String,
  )
  Rect(id: String, position: Vector(Two), size: Vector(Two), color: Color)
}

pub type Component

pub type Checksum

pub fn create(scheme scheme: Scheme) -> Component {
  use cache <- cache.create

  use <- cache.get_or_set(cache, checksum(Scheme(scheme:)))

  do_create(scheme:)
}

@external(javascript, "./component.ffi.mjs", "create")
fn do_create(scheme scheme: Scheme) -> Component

@external(javascript, "./component.ffi.mjs", "add")
pub fn add(component component: Component) -> Nil

@external(javascript, "./component.ffi.mjs", "remove")
pub fn remove(component component: Component) -> Nil

pub type Type {
  Scheme(scheme: Scheme)
  Component(component: Component)
}

@external(javascript, "./component.ffi.mjs", "checksum")
pub fn checksum(type_: Type) -> Checksum

@external(javascript, "./component.ffi.mjs", "getSize")
pub fn get_size(component component: Component) -> #(Int, Int)

@external(javascript, "./component.ffi.mjs", "canvasSize")
pub fn canvas_size() -> #(Int, Int)
