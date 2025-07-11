import gleam/option.{type Option}
import gleam/string

import glum/internal/cache
import glum/object.{type Object}

pub type GameObject

pub fn create(object object: Object) -> Option(GameObject) {
  use cache <- cache.create

  use <- cache.get_or_set(cache:, key: string.inspect(object))

  do_create(object:)
}

@external(javascript, "./game_object.ffi.mjs", "create")
fn do_create(object object: Object) -> Option(GameObject)

@external(javascript, "./game_object.ffi.mjs", "add")
pub fn add(game_object game_object: GameObject) -> Nil

@external(javascript, "./game_object.ffi.mjs", "remove")
pub fn remove(game_object game_object: GameObject) -> Nil
