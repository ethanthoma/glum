<h1 align="center">Glum</h1>
<p align="center">
  A lightweight, Gleam-powered game engine for building cross-platform mobile games with NativeScript.
</p>

<p align="center">
    <img src="https://img.shields.io/github/last-commit/ethanthoma/glum/main?style=for-the-badge&labelColor=%231f1d2e&color=%23c4a7e7">
    <a href="https://hex.pm/packages/glum"><img src="https://img.shields.io/hexpm/v/glum?style=for-the-badge&labelColor=%231f1d2e&color=%239ccfd8"></a>
    <a href="https://hexdocs.pm/glum"><img src="https://img.shields.io/badge/hex-docs?style=for-the-badge&labelColor=%231f1d2e&color=%23ebbcba"></a>
</p>

## About

Glum is a mobile game engine designed to bring the safety and expressiveness of
Gleam to mobile game development. It uses NativeScript and ThreeJs for rendering
on mobile devices.

## Getting Started

To use the library, you will need the
[NativeScript CLI](https://docs.nativescript.org/start/quick-setup).

Setup NativeScript for pure a JS project following their docs and using their
CLI.

Create a Gleam in the same directory.

Simply add this library to your Gleam project via `gleam add glum`

Copy over the files in the template directory to your project.

You will need to update the `id` in `nativescript.config.ts` to match typical
android package names (i.e. `com.company.something`).

You will also have to add the project name to the `package.json` if you replaced
the one NativeScript gave you.
