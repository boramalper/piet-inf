#!/usr/bin/env bash

shopt -s globstar
for f in src/**/*.hs; do
	stylish-haskell -i "$f"
done
