#!/bin/sh

# luacheck is unnecessary for running
luacheck main.lua | grep -v variable.*love

# love is necessary
love ./
