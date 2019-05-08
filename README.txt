libmpython

This project is intended to produce a static library version of micropython for use with Arduino build environments
such as the Arduino IDE, Visual Micro, (others?).

The main target is currently the Teensy 3.1 ARM development board.
http://www.pjrc.com/teensy/

Main micropython site:
http://www.micropython.org/

Getting started:

The micropython source must first be downloaded the git repostitory:
https://github.com/micropython/micropython

WARNING: The micropython source is under active development.  
This build was working on the latest micropython master as at 2014-02-11 22:30

Makefile will need to be modified to set the path to the micropython source as well as paths to various tools needed for the build.

The Makefile is designed for use with GNU make (such as MinGW mingw32-make.exe).

The ARM build tools are contained in the Teensduino package:
https://www.pjrc.com/teensy/teensyduino.html

Teensyduino 1.18 Release Candidate #2 or later is recommended for > 128k (50%) programs with teensy loader 
(hex unreadable errors)
http://forum.pjrc.com/threads/24796-Teensyduino-1-18-Release-Candidate-2-Available

Using libmypthon in an arduino project:

The teensypy example program demonstrates a simple example sketch project:
https://github.com/10bulls/teensypy


Issues / TODO:

Many arduino libraries may not yet be supported of have limited / cut down implementations.

TODO: Add some test to determine what is and isn't working as well as to test for breaking changes in micropython.

TODO: Investigate using vdprintf to get Print.cpp fully working.
(I think only string and integers are working at present).


