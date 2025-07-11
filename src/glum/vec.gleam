import gleam/float
import gleam/result

import glum/internal/util

pub type One =
  fn() -> Nil

pub type Two =
  fn() -> fn() -> Nil

pub type Three =
  fn() -> fn() -> fn() -> Nil

pub opaque type Vector(f) {
  Vector(buffer: Buffer, get: fn(Int) -> Float)
}

pub fn scalar(x x: Float) -> Vector(One) {
  let buffer = init(1) |> set(0, x)
  Vector(buffer, get(buffer, _))
}

pub fn vec2(x x: Float, y y: Float) -> Vector(Two) {
  let buffer = init(2) |> set(0, x) |> set(1, y)
  Vector(buffer, get(buffer, _))
}

pub fn vec3(x x: Float, y y: Float, z z: Float) -> Vector(Three) {
  let buffer =
    init(3)
    |> set(0, x)
    |> set(1, y)
    |> set(2, z)

  Vector(buffer, get(buffer, _))
}

pub fn x(vec: Vector(fn() -> f)) -> Float {
  vec.get(0)
}

pub fn y(vec: Vector(fn() -> fn() -> f)) -> Float {
  vec.get(1)
}

pub fn z(vec: Vector(fn() -> fn() -> fn() -> f)) -> Float {
  vec.get(2)
}

pub fn add(base a: Vector(n), offset b: Vector(m)) -> Vector(n) {
  let Vector(a, _) = a
  let Vector(b, _) = b

  use <- util.apply_with(fn(buffer) { Vector(buffer, get(buffer, _)) })

  use a, b <- combine(a, b)

  a +. b
}

pub fn sub(base a: Vector(n), offset b: Vector(m)) -> Vector(n) {
  let Vector(a, _) = a
  let Vector(b, _) = b

  use <- util.apply_with(fn(buffer) { Vector(buffer, get(buffer, _)) })

  use a, b <- combine(a, b)

  a -. b
}

pub fn mul(base a: Vector(n), offset b: Vector(m)) -> Vector(n) {
  let Vector(a, _) = a
  let Vector(b, _) = b

  use <- util.apply_with(fn(buffer) { Vector(buffer, get(buffer, _)) })

  use a, b <- combine(a, b)

  a *. b
}

pub fn div(base a: Vector(n), offset b: Vector(m)) -> Vector(n) {
  let Vector(a, _) = a
  let Vector(b, _) = b

  use <- util.apply_with(fn(buffer) { Vector(buffer, get(buffer, _)) })

  use a, b <- combine(a, b)

  a /. b
}

pub fn normalize(a: Vector(n)) -> Vector(n) {
  let length = length(a)

  let Vector(a, _) = a

  use <- util.apply_with(fn(buffer) { Vector(buffer, get(buffer, _)) })

  use a <- map(a)

  a /. length
}

pub fn cross(a: Vector(Three), b: Vector(Three)) -> Vector(Three) {
  let x = { a.get(1) *. b.get(2) } -. { a.get(2) *. b.get(1) }
  let y = { a.get(2) *. b.get(0) } -. { b.get(0) *. b.get(2) }
  let z = { a.get(0) *. b.get(1) } -. { a.get(1) *. b.get(0) }

  vec3(x:, y:, z:)
}

pub fn append(a: Vector(a), b: Float) -> Vector(fn() -> a) {
  let Vector(buffer, _) = a

  let buffer = buffer |> set(len(buffer), b)

  Vector(buffer, get(buffer, _))
}

pub fn invert(vec: Vector(f)) -> Vector(f) {
  let Vector(buffer, _) = vec

  let buffer = map(buffer, fn(value) { -1.0 *. value })

  Vector(buffer, get(buffer, _))
}

pub fn length(vec: Vector(f)) -> Float {
  let Vector(buffer, _) = vec

  use <- util.apply_with(fn(len) {
    len
    |> float.square_root()
    |> result.unwrap(0.0)
  })

  use acc, value <- fold(buffer, 0.0)

  let value = float.absolute_value(value)

  acc +. { value *. value }
}

// ** Buffer **

type Buffer

@external(javascript, "./buffer.ffi.mjs", "init")
fn init(size: Int) -> Buffer

@external(javascript, "./buffer.ffi.mjs", "set")
fn set(buffer: Buffer, key: Int, value: Float) -> Buffer

@external(javascript, "./buffer.ffi.mjs", "get")
fn get(buffer: Buffer, index: Int) -> Float

@external(javascript, "./buffer.ffi.mjs", "len")
fn len(buffer: Buffer) -> Int

@external(javascript, "./buffer.ffi.mjs", "combine")
fn combine(a: Buffer, b: Buffer, f: fn(Float, Float) -> Float) -> Buffer

@external(javascript, "./buffer.ffi.mjs", "map")
fn map(buffer: Buffer, f: fn(Float) -> Float) -> Buffer

@external(javascript, "./buffer.ffi.mjs", "fold")
fn fold(buffer: Buffer, init: any, f: fn(any, Float) -> any) -> f
