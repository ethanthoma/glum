export function get_key(any) {
	return any(...Array(any.length).keys()).constructor.name;
}

export function add_key(any) {
	return any.constructor.name;
}
