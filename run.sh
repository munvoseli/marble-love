#!/bin/sh
luacheck main.lua | grep -v variable.*love
love ./
