import * as $event from "./event.mjs";
import * as $gesture from "./gesture.mjs";

let queue = [];

export function dispatch(event) {
	queue.push(event);
}

export function flush(withFn) {
	while (queue.length > 0) {
		const event = queue.shift();
		withFn(event);
	}
}

const listener = new Map();

export function eventGestureTap({ clientX, clientY }) {
	const tap = new $gesture.Tap(clientX, clientY);

	const event = new $event.Gesture(tap);

	emit($event.Gesture.name, event);
	dispatch(event);
}

function emit(name, event) {
	if (!listener.has(name)) return;

	listener.get(name).forEach((fn) => dispatch(fn(event)));
}

export function register(name, key, callback) {
	if (listener.has(name)) {
		listener.get(name).set(key, callback);
	} else {
		const map = new Map();
		map.set(key, callback);
		listener.set(name, map);
	}
}

export function unregister(name, key) {
	if (!listener.has(name)) return;

	listener.get(name).delete(key);
}
