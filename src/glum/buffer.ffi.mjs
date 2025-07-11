export function init(length) {
	return Array.from({ length });
}

export function set(buffer, key, value) {
	const copy = [...buffer];
	copy[key] = value;
	return copy;
}

export function get(buffer, key) {
	return buffer.at(key);
}

export function len(buffer) {
	return buffer.length;
}

export function combine(a, b, f) {
	return fold(a, b, (acc, value, index) => {
		let other_value = get(acc, index);

		if (other_value !== undefined) {
			other_value = f(value, other_value);
		} else {
			other_value = value;
		}

		return set(acc, index, other_value);
	});
}

export function map(buffer, f) {
	return buffer.map(f);
}

export function fold(buffer, init, f) {
	return buffer.reduce(f, init);
}
