import gleam/dict
import gleam/function
import gleam/int
import gleam/list
import gleam/set

import given

import glum/element.{type Element}
import glum/gesture.{type Gesture}
import glum/internal/cache
import glum/internal/component
import glum/internal/emitter.{type Emitter}
import glum/internal/game_object
import glum/internal/layout
import glum/internal/util
import glum/object.{type Object}

pub fn render_game(object object: Object) -> Nil {
  use cache <- cache.create

  use <- util.apply_with(fn(checksums) {
    use checksum, game_object <- dict.each(cache.all(cache:))

    use <- given.that(set.contains(in: checksums, this: checksum), fn() { Nil })

    cache.unset(cache:, key: checksum)
    game_object.remove(game_object:)
  })

  let checksum = object.checksum(object:)
  let checksums = set.new() |> set.insert(this: checksum)

  // TODO: we can update position + rotation, no need to delete
  use <- given.that(cache.has(cache:, key: checksum), fn() { checksums })

  let game_object = game_object.create(object:)

  use game_object <- given.some(game_object, fn() { checksums })

  cache.set(cache:, key: checksum, value: game_object)
  game_object.add(game_object:)

  checksums
}

pub fn render_ui(element element: Element(msg)) -> Nil {
  use cache <- cache.create

  let #(x, y) = #(0.0, 0.0)
  let #(width, height) = component.canvas_size()
  let width = int.to_float(width)
  let height = int.to_float(height)
  let bounds = layout.Bounds(width:, height:, x:, y:)

  let #(schemes, emitters) = layout.layout(element:, bounds:, id: "root")

  handle_emitters(emitters)

  use <- util.apply_with(fn(checksums) {
    use checksum, component <- dict.each(cache.all(cache:))

    use <- given.that(set.contains(in: checksums, this: checksum), fn() { Nil })

    cache.unset(cache:, key: checksum)
    component.remove(component:)
  })

  use checksums, scheme <- list.fold(schemes, set.new())

  let checksum = component.checksum(component.Scheme(scheme:))

  use _ <- function.tap(set.insert(into: checksums, this: checksum))

  use <- cache.get_or_set(cache:, key: checksum)

  use component <- function.tap(component.create(scheme:))
  component.add(component:)
}

fn handle_emitters(emitters emitters: List(Emitter(Gesture, msg))) -> Nil {
  use cache <- cache.create

  use <- util.apply_with(fn(ids) {
    use id, emitter <- dict.each(cache.all(cache:))

    use <- given.that(set.contains(in: ids, this: id), fn() { Nil })

    cache.unset(cache:, key: id)
    emitter.unregister(emitter.Gesture(emitter))
  })

  use ids, emitter <- list.fold(over: emitters, from: set.new())

  use _ <- function.tap(set.insert(into: ids, this: emitter.id))

  use <- cache.get_or_set(cache:, key: emitter.id)

  use emitter <- function.tap(emitter)
  emitter.register(emitter.Gesture(emitter))
}
