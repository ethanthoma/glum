const webpack = require("@nativescript/webpack");
const { resolve } = require("path");

module.exports = (env) => {
	webpack.init(env);

	webpack.chainWebpack((config) => {
		config.resolve.alias.set("three", "three/webgpu");
		config.resolve.alias.set("three/tsl", "three/tsl");

		config.resolve.alias.set(
			"three",
			resolve("node_modules", "three", "build", "three.webgpu.js"),
		);
	});

	return webpack.resolveConfig();
};
