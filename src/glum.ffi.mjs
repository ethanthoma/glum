import { Screen } from "@nativescript/core";

import * as $list from "../gleam_stdlib/gleam/list.mjs";

import * as $event from "./glum/event.mjs";
import * as $eventFfi from "./glum/event.ffi.mjs";
import * as $gestureFfi from "./glum/gesture.ffi.mjs";
import * as render from "./glum/internal/render.ffi.mjs";
import * as $render from "./glum/internal/render.mjs";

////////// Global state //////////

let canvas;

let currentModel = null;
let updateFn = null;
let uiViewFn, gameViewFn;

const FIXED_DELTA = 1000 / 60;
let lastTime = 0;
let deltaTime = 0;
let accumulator = 0;
let animationFrameId = null;

let counterUps = 0;
let counterFps = 0;
let currentFps = 0;
let currentUps = 0;
let lastDisplayTime = 0;

////////// Init //////////

let initialized = false;

export function init(_canvas, main) {
	if (initialized) return;

	console.log("Initializing...");

	canvas = _canvas;

	// Scale canvas
	const scale = Screen.mainScreen.scale;

	canvas.width = canvas.clientWidth * scale;
	canvas.height = canvas.clientHeight * scale;

	// Event listener
	const gestureHandler = $gestureFfi.init(canvas);
	$gestureFfi.listen(gestureHandler, $eventFfi.eventGestureTap);

	initialized = true;
	console.log("Initialized.");

	main();
}

////////// Start //////////

export function start({ init, update, ui_view, game_view }, flags) {
	try {
		console.log("Starting app...");

		updateFn = update;
		uiViewFn = ui_view;
		gameViewFn = game_view;

		const [initialModel, initialEvent] = init(flags);

		currentModel = initialModel;

		if (initialEvent) {
			handleEvent(initialEvent);
		}

		startGameLoop();

		console.log("App started successfully.");
		return null;
	} catch (error) {
		console.error("Error starting application:", error);
		return null;
	}
}

////////// Game Loop //////////

let started = false;
let cancelled = false;

function startGameLoop() {
	started = true;
	console.log("Starting loop...");

	render.init(canvas);

	renderFrame(0);

	animationFrameId = requestAnimationFrame(gameLoop);
}

function gameLoop(timestamp) {
	if (!started || cancelled) {
		return;
	}

	const now = timestamp;
	const frameTime = now - (lastTime || now);
	lastTime = now;

	const maxFrameTime = 250;
	const clampedFrameTime = Math.min(frameTime, maxFrameTime);

	accumulator += clampedFrameTime;

	try {
		if (now - lastDisplayTime >= 1000) {
			currentFps = counterFps;
			currentUps = counterUps;

			console.log(`FPS: ${currentFps}, UPS: ${currentUps}`);

			counterFps = 0;
			counterUps = 0;
			lastDisplayTime = now;
		}

		while (accumulator >= FIXED_DELTA) {
			$eventFfi.dispatch(new $event.Tick(FIXED_DELTA));

			$eventFfi.flush(processEvent);

			accumulator -= FIXED_DELTA;
			counterUps++;
		}

		const alpha = accumulator / FIXED_DELTA;

		counterFps++;
		renderFrame(alpha);

		animationFrameId = requestAnimationFrame(gameLoop);
	} catch (error) {
		console.error("Error in animation loop:", error, "continuing anyway");
		animationFrameId = requestAnimationFrame(gameLoop);
	}
}

export function getDeltaTime() {
	return (deltaTime * 60) / 1000;
}

////////// Render //////////

function renderFrame(_deltaTime) {
	if (!render.isInitialized()) return;

	try {
		const object = gameViewFn(currentModel);
		$render.render_game(object);

		const element = uiViewFn(currentModel);
		$render.render_ui(element);

		render.animate();
	} catch (error) {
		console.error("Error rendering frame:", error);
	}
}

////////// Event //////////

function processEvent(event) {
	if (!currentModel || !updateFn) return;

	const [nextModel, nextEvent] = updateFn(currentModel, event);

	currentModel = nextModel;

	handleEvent(nextEvent);
}

function handleEvent(event) {
	if (!event) return;

	if (event instanceof $event.NoOp) {
	} else if (event instanceof $event.Quit) {
		if (animationFrameId) {
			cancelAnimationFrame(animationFrameId);
		}
		console.log("Application quit requested");
		cancelled = true;
	} else if (event instanceof $event.Sequence) {
		$list.each(event[0], (e) => handleEvent(e));
	} else if (event instanceof $event.Effect) {
		event[0]($event.dispatch);
	} else {
		$event.dispatch(event);
	}
}

////////// Util //////////

export function print(dyn) {
	console.log(dyn);
}
