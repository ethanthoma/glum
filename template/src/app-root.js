// NativeScript init
import { init } from "../glum/glum.ffi.mjs";

// Gleam entry point
import { main } from "./app.mjs";

export function canvasReady(args) {
	let canvas = args.object;
	init(canvas, main);
}
