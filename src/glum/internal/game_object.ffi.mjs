import { Some, None } from "../../../gleam_stdlib/gleam/option.mjs";

import * as $color from "../../../gleam_community_colour/gleam_community/colour.mjs";

import * as $object from "../object.mjs";

let camera, scene;

export function init(canvas) {
	scene = new THREE.Scene();

	camera = new THREE.PerspectiveCamera(
		50,
		canvas.clientWidth / canvas.clientHeight,
		0.1,
		1000,
	);
	camera.position.set(0, 0, 10);
	camera.lookAt(0, 0, 0);
}

export function animate(renderer) {
	if (!scene || !camera) {
		return;
	}

	renderer.clear();
	renderer.render(scene, camera);
}

export function create(object) {
	let gameObject;
	switch (object.constructor) {
		case $object.Box:
			gameObject = createBox(object);
			break;
		default:
			return new None();
	}

	return new Some(gameObject);
}

function createBox(object) {
	let { position, size, rotation, material } = object;

	const geometry = new THREE.BoxGeometry(
		size.buffer.at(0),
		size.buffer.at(1),
		size.buffer.at(2),
	);

	material = createMaterial(material);

	const mesh = new THREE.Mesh(geometry, material);

	mesh.position.set(
		position.buffer.at(0),
		position.buffer.at(1),
		position.buffer.at(2),
	);

	mesh.rotation.set(
		rotation.buffer.at(0),
		rotation.buffer.at(1),
		rotation.buffer.at(2),
	);

	mesh.userData = {
		type: "Box",
		checksum: JSON.stringify(object),
	};

	return mesh;
}

function createMaterial(material) {
	switch (material.constructor) {
		case $object.Basic:
			const { color } = material;
			return new THREE.MeshBasicMaterial({
				color: new THREE.Color($color.to_rgb_hex(color)),
			});
		case $object.Normal:
			return new THREE.MeshNormalMaterial();
		default:
			console.error(
				"GameObject - invalid material type:",
				material.constructor.name,
			);
	}
}

export function add(gameObject) {
	console.log("GameObject - adding to scene:", gameObject.userData.type);
	scene.add(gameObject);
}

export function remove(gameObject) {
	console.log("GameObject - removing from scene:", gameObject.userData.type);
	scene.remove(gameObject);
}
