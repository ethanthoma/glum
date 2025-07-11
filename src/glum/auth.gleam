import gleam/option.{type Option}

import glum/event.{type Event}

pub opaque type Provider {
  Apple
  Google
}

pub type User {
  User(uid: String, email: String, display_name: String)
}

pub type AuthEvent {
  SignedIn(user: User)
  SignedOut
  Failed(AuthError)
}

pub type AuthError {
  FailedSigningIn(message: String)
}

@external(javascript, "./auth.ffi.mjs", "getUser")
pub fn get_user() -> Option(User)

pub fn google() -> Provider {
  do_add_google()
  Google
}

@external(javascript, "./auth.ffi.mjs", "addGoogle")
fn do_add_google() -> Nil

pub fn sign_in(provider provider: Provider) -> Event(AuthEvent) {
  use dispatch <- event.effect

  use user <-
    case provider {
      Apple -> panic
      Google -> do_sign_in_google
    }

  case user {
    Ok(user) -> SignedIn(user)
    Error(message) -> FailedSigningIn(message:) |> Failed
  }
  |> event.Custom
  |> dispatch
}

@external(javascript, "./auth.ffi.mjs", "signInGoogle")
fn do_sign_in_google(callback: fn(Result(User, String)) -> any) -> Nil

pub fn sign_out() -> Event(AuthEvent) {
  do_sign_out()
  SignedOut |> event.Custom
}

@external(javascript, "./auth.ffi.mjs", "signOut")
fn do_sign_out() -> Nil
