#!/bin/bash

day=$1
cp "src/template.jl"  "src/d${day}.jl"
sed -i "s/DAYCODE/d${day}/g" "src/d${day}.jl"
sed -i "s/days = \[\(.*\)\]/days = \[\1, ${day}\]/g" "src/AdventOfCode.jl"
aocd "${day}" > "data/d${day}.txt"
