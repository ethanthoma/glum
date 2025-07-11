import gleam/dict.{type Dict}
import gleam/function
import gleam/option.{type Option}

import given

pub type Cache(key, value)

@external(javascript, "./cache.ffi.mjs", "create")
pub fn create(scope scope: fn(Cache(key, value)) -> any) -> any

@external(javascript, "./cache.ffi.mjs", "has")
pub fn has(cache cache: Cache(key, value), key key: key) -> Bool

@external(javascript, "./cache.ffi.mjs", "get")
pub fn get(cache cache: Cache(key, value), key key: key) -> Option(value)

pub fn get_or_set(
  cache cache: Cache(key, value),
  key key: key,
  or or: fn() -> value,
) -> value {
  let value = get(cache:, key:)

  use <- given.none(value, function.identity)

  use value <- function.tap(or())

  set(cache:, key:, value:)
}

@external(javascript, "./cache.ffi.mjs", "set")
pub fn set(
  cache cache: Cache(key, value),
  key key: key,
  value value: value,
) -> Nil

@external(javascript, "./cache.ffi.mjs", "unset")
pub fn unset(cache cache: Cache(key, value), key key: key) -> Nil

@external(javascript, "./cache.ffi.mjs", "all")
pub fn all(cache cache: Cache(key, value)) -> Dict(key, value)
