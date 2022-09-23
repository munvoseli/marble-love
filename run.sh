#!/bin/sh

# luacheck is unnecessary for running
luacheck main.lua | grep -v variable.*love | grep -v unused

# love is necessary
love ./
