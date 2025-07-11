import * as THREE from "@nativescript/canvas-three";
import { Canvas } from "@nativescript/canvas";
import * as $color from "../../../gleam_community_colour/gleam_community/colour.mjs";

import * as $component from "./component.mjs";
import * as render from "./render.ffi.mjs";

let scene, camera;

export function init(canvas) {
	scene = new THREE.Scene();
	camera = new THREE.OrthographicCamera(
		-canvas.clientWidth / 2,
		canvas.clientWidth / 2,
		canvas.clientHeight / 2,
		-canvas.clientHeight / 2,
		1,
		1000,
	);
	camera.position.z = 10;
}

export function animate(renderer) {
	if (!scene || !camera) {
		return;
	}

	renderer.clearDepth();
	renderer.render(scene, camera);
}

export function add(component) {
	console.log("Component - adding to scene:", component.userData.id);
	scene.add(component);
}

export function remove(component) {
	console.log("Component - removing from scene:", component.userData.id);
	scene.remove(component);
}

export function getSize(component) {
	return [component.userData.width, component.userData.height];
}

export function create(object) {
	switch (object.constructor) {
		case $component.Text:
			return createText(object);
		case $component.Rect:
			return createRect(object);
		default:
			console.error("Component - creating failed.");
	}
}

export function checksum(type) {
	switch (type.constructor) {
		case $component.Scheme:
			return JSON.stringify(type["scheme"]);
		case $component.Component:
			return type["component"].userData.checksum;
		default:
			console.error("Component - Invalid type passed to checksum");
	}
}

function createText(object) {
	const { id, position, font_size, color, content } = object;
	const fontSize = font_size;

	const lineHeight = 1.2;
	const renderScale = 3;

	// bitmap + ctx
	const { textWidth, textHeight } = measure(
		content,
		fontSize,
		lineHeight,
		renderScale,
	);

	const bitmap = new Canvas();

	bitmap.width = textWidth;
	bitmap.height = textHeight;

	const context = bitmap.getContext("2d");
	context.translate(0, bitmap.height);
	context.scale(1, -1);

	// draw text
	context.font = `${fontSize * renderScale}px sans-serif`;
	context.fillStyle = $color.to_css_rgba_string(color);
	context.textBaseline = "top";
	content.split("\n").forEach((line, index) => {
		const x = 0;
		const y = index * fontSize * renderScale * lineHeight;

		context.fillText(line, x, y, textWidth);
	});

	// make texture
	const texture = new THREE.CanvasTexture(bitmap);
	texture.minFilter = THREE.LinearFilter;
	texture.generateMipmaps = false;
	texture.needsUpdate = true;

	const material = new THREE.SpriteMaterial({
		map: texture,
		depthTest: false,
		transparent: true,
	});

	const sprite = new THREE.Sprite(material);
	sprite.scale.set(bitmap.width / renderScale, bitmap.height / renderScale, 1);
	sprite.center.set(0, 1);

	const pixelX = position.buffer.at(0);
	const pixelY = position.buffer.at(1);

	const [screenWidth, screenHeight] = canvasSize();

	const orthoX = -screenWidth / 2 + pixelX;
	const orthoY = screenHeight / 2 - pixelY;

	sprite.position.set(orthoX, orthoY, 2);

	sprite.userData = {
		type: "Text",
		id: id,
		checksum: JSON.stringify(object),
		width: bitmap.width,
		height: bitmap.height,
	};

	return sprite;
}

const measureContext = new Canvas().getContext("2d");
function measure(content, fontSize, lineHeight, renderScale) {
	measureContext.font = `${fontSize * renderScale}px sans-serif`;
	measureContext.textBaseline = "top";

	const lines = content.split("\n");
	const textWidth = Math.max(
		...lines.map((line) => measureContext.measureText(line).width),
	);
	const textHeight = fontSize * renderScale * lines.length * lineHeight;

	return { textWidth, textHeight };
}

function createRect(object) {
	const { id, position, size, color } = object;

	const bitmap = new Canvas();

	bitmap.width = size.buffer.at(0);
	bitmap.height = size.buffer.at(1);

	const context = bitmap.getContext("2d");
	context.fillStyle = $color.to_css_rgba_string(color);
	context.fillRect(0, 0, bitmap.width, bitmap.height);

	const texture = new THREE.CanvasTexture(bitmap);
	texture.minFilter = THREE.LinearFilter;
	texture.generateMipmaps = false;
	texture.needsUpdate = true;

	const material = new THREE.SpriteMaterial({
		map: texture,
		depthTest: false,
		transparent: true,
	});

	const sprite = new THREE.Sprite(material);
	sprite.scale.set(bitmap.width, bitmap.height, 1);
	sprite.center.set(0, 1);

	const pixelX = position.buffer.at(0);
	const pixelY = position.buffer.at(1);

	const [screenWidth, screenHeight] = canvasSize();

	const orthoX = -screenWidth / 2 + pixelX;
	const orthoY = screenHeight / 2 - pixelY;

	sprite.position.set(orthoX, orthoY, 2);

	sprite.userData = {
		type: "Rect",
		id: id,
		checksum: JSON.stringify(object),
		width: bitmap.width,
		height: bitmap.height,
	};

	return sprite;
}

export function canvasSize() {
	return render.canvasSize();
}
