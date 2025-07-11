import * as $event from "../event.mjs";
import * as $emitter from "./emitter.mjs";

export { register, unregister } from "../event.ffi.mjs";

export function name(cond) {
	switch (cond.constructor) {
		case $emitter.Gesture:
			return $event.Gesture.name;
		default:
			throw new Error("UNIMPLEMENTED");
	}
}
