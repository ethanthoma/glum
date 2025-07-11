pub fn func(value: a) -> fn() -> a {
  fn() { value }
}

pub fn identity(value value: a) -> a {
  value
}

pub const param: fn(fn(a) -> b) -> fn(a) -> b = identity

pub fn defer(a: fn() -> b, b: fn() -> a) -> a {
  let r = b()
  a()
  r
}

pub fn apply(to a: fn(a) -> b, with b: a) {
  a(b)
}

pub fn apply_with(to a: fn(a) -> b, with b: fn() -> a) -> b {
  a(b())
}
