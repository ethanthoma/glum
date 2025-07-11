import gleam_community/colour.{type Color}

import glum/vec.{type Three, type Vector}

pub type Object {
  None
  Box(
    position: Vector(Three),
    size: Vector(Three),
    rotation: Vector(Three),
    material: Material,
  )
}

pub type Material {
  Basic(color: Color)
  Normal
}

pub fn none() {
  None
}

pub fn box(material material: Material) -> Object {
  Box(
    position: vec.vec3(0.0, 0.0, 0.0),
    size: vec.vec3(1.0, 1.0, 1.0),
    rotation: vec.vec3(0.0, 0.0, 0.0),
    material:,
  )
}

pub fn translate(object object: Object, by by: Vector(n)) -> Object {
  case object {
    Box(position:, ..) -> {
      let position = vec.add(position, by)
      Box(..object, position:)
    }
    _ -> object
  }
}

pub fn rotate(object object: Object, by by: Vector(n)) {
  case object {
    Box(rotation:, ..) -> {
      let rotation = vec.add(rotation, by)
      Box(..object, rotation:)
    }
    _ -> object
  }
}

pub type Checksum

@external(javascript, "./object.ffi.mjs", "checksum")
pub fn checksum(object object: Object) -> Checksum
