import { NativeScriptConfig } from "@nativescript/core";

export default {
	id: "",
	appPath: "src",
	appResourcesPath: "App_Resources",
	android: {
		v8Flags: "--expose_gc",
		markingMode: "none",
	},
	hooks: [{ type: "before-prepare", script: "./scripts/build-gleam.js" }],
} as NativeScriptConfig;
