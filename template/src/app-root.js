// NativeScript init
import { init } from "../ns/ns.ffi.mjs";

// Gleam entry point
import { main } from "./app.mjs";

export function canvasReady(args) {
	let canvas = args.object;
	init(canvas, main);
}
