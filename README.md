# APE
Another Particle Editor for LÖVE2D game engine

This is a particle system editor for LÖVE2D, created for quick prototyping particle systems.
It features paged interface, runtime texture loading, code-to-clipboard generation and also 
includes interface classes for use in other projects aswell.

USAGE

In order to texture loading to work, code must not be in a .love file and must be unpacked into separate directory
with folder "particles" in it.
Every value and property of a particle system is changed with spin fields, which are controlled with mousewheel.
Pressing left shift, left ctrl or left alt will modify step, with which value is increased.
Clicking on Texture manager button will show texture manager tab, where user can set texture, offset and add quads.
To generate and copy emitter code to clipboard, click on Code button under Miscellaneous tab in the bottom. 


All particle textures are distributed under CC BY license.
