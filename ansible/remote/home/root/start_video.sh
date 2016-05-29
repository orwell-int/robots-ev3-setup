#!/bin/sh

source ./setenv

./capture -o | nc -l -p5000
