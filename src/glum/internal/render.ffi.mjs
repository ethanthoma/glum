import * as THREE from "@nativescript/canvas-three";

import * as $component from "./component.ffi.mjs";
import * as $gameObject from "./game_object.ffi.mjs";

let context, canvas, renderer;

let initialized = false;
export function init(_canvas) {
	if (initialized) return;

	console.log("Renderer initializing...");
	canvas = _canvas;

	renderer = new THREE.WebGPURenderer({
		canvas: canvas,
		antialias: false,
	});
	renderer.setPixelRatio(1.5);
	//renderer.autoClear = false; // TODO: we need autoClear false for rendering objects + UI

	renderer
		.init()
		.then(() => {
			renderer.setPixelRatio(window.devicePixelRatio);
			renderer.setSize(canvas.clientWidth, canvas.clientHeight, false);

			$gameObject.init(canvas);
			$component.init(canvas);

			context = canvas.getContext("webgpu");
			initialized = true;

			console.log("Renderer initialized.");
		})
		.catch((error) => {
			console.error(error);
		});
}

export function isInitialized() {
	return initialized;
}

export function animate() {
	if (!initialized) return;

	$gameObject.animate(renderer);
	$component.animate(renderer);

	if (context) {
		context.presentSurface();
	}
}

export function canvasSize() {
	return [canvas.clientWidth, canvas.clientHeight];
}
