import { Ok, Error } from "../gleam.mjs";
import { Some, None } from "../../gleam_stdlib/gleam/option.mjs";
import { firebase } from "@nativescript/firebase-core";
import "@nativescript/firebase-auth";

// Google
import { GoogleAuthProvider } from "@nativescript/firebase-auth";
import { GoogleSignin } from "@nativescript/google-signin";

import * as $auth from "./auth.mjs";

let inAuth = false;

export function getUser() {
	let user = firebase().auth().currentUser;

	if (user) {
		user = new $auth.User(user.uid, user.email, user.displayName);
		return new Some(user);
	} else {
		return new None();
	}
}

export function addGoogle() {
	GoogleSignin.configure();
}

export function signInGoogle(callback) {
	if (inAuth) return;

	inAuth = true;

	GoogleSignin.signIn()
		.then((user) => {
			const credential = GoogleAuthProvider.credential(
				user.idToken,
				user.accessToken,
			);

			firebase()
				.auth()
				.signInWithCredential(credential)
				.then((userCredential) => {
					let user = new $auth.User(
						userCredential.user.uid,
						userCredential.user.email,
						userCredential.user.displayName,
					);

					callback(new Ok(user));
				});
		})
		.catch((err) => callback(new Error(err.toString())))
		.finally(() => {
			inAuth = false;
		});
}

export function signOut() {
	firebase().auth().signOut();
}
