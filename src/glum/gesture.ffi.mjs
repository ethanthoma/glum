class GestureHandler {
	constructor(canvas) {
		this.canvas = canvas;
		this.isTouching = false;
	}
}

export function init(canvas) {
	return new GestureHandler(canvas);
}

export function listen(gestureHandler, onTapEvent) {
	gestureHandler.canvas.addEventListener("touchstart", (args) => {
		if (!gestureHandler.isTouching) {
			gestureHandler.isTouching = true;
			const touch = args.touches.item(0);
			onTapEvent(touch);
		}
	});

	gestureHandler.canvas.addEventListener("touchmove", (args) => {
		const touches = args.changedTouches;

		if (Array.isArray(touches)) {
			const touch = touches[0];
			//onTapEvent(touch);
		}
	});

	gestureHandler.canvas.addEventListener("touchend", (args) => {
		gestureHandler.isTouching = false;
	});
}
