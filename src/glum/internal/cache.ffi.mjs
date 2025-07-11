import { Some, None } from "../../../gleam_stdlib/gleam/option.mjs";
import Dict from "../../../gleam_stdlib/dict.mjs";

let caches = new Map();

export function create(scope) {
	if (typeof scope !== "function") {
		console.error("Cache - create requires the scope to be a function");
	}

	const key = scope.toString();

	let cache;
	if (caches.has(key)) {
		cache = caches.get(key);
	} else {
		console.log("Cache - created for", checksum(key));
		cache = new Map();
		caches.set(key, cache);
	}

	return scope(cache);
}

// https://stackoverflow.com/questions/811195/fast-open-source-checksum-for-small-strings
function checksum(s) {
	var chk = 0x12345678;
	var len = s.length;
	for (var i = 0; i < len; i++) {
		chk += s.charCodeAt(i) * (i + 1);
	}

	return (chk & 0xffffffff).toString(16);
}

export function get(cache, key) {
	let value = cache.get(key);
	if (value !== undefined) {
		return new Some(value);
	} else {
		return new None();
	}
}

export function has(cache, key) {
	return cache.has(key);
}

export function set(cache, key, value) {
	cache.set(key, value);
}

export function unset(cache, key) {
	cache.delete(key);
}

export function all(cache) {
	return Dict.fromMap(cache);
}
