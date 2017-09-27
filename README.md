# lalily-templates

This provides a template package for openLilyLib. It is taken from
[lalily](https://github.com/jpvoigt/lalily) and adapted for
openLilyLib.

Right now the basic engine is working and a few templates are working.
It requires the latest development version and is intended for the
upcoming version 2.20 of LilyPond.

Maintainer: Jan-Peter Voigt

Licence: GPL V3

## How it works

To understand how the template engine works it might be helpful to
read my article about "Trees, Music and LilyPond".  The music is
organized hierarchically and is accessed by path. A template is a
music-function that is called with a current path set.

To typeset a score a template and an a-list with properties has to be
assigned to the path dedicated to the music. Then `\lalilyCreate`
calls the template functions for the current music-path with the
configuration stored in the a-list. A global current path is used
inside this engine to address the music.

## Example

```lilypond
\version "2.19.65"
% lalily-templates are include via the current plugin-mechanism of openLilyLib (https://github.com/openlilylib/oll-core)
\include "oll-core/package.ily"
\loadPackage lalily-templates

% a variable to prepare the score
opts = #'()
% we use the core-template 'group'
% the parts of this score are A and B and are defined as '_order'
opts."_order" = A.B
% the '_template' option defines the template to use for this part: A is played by trumpet in B flat
opts.A."_template" = lalily.instrument.trumpet
% B is played by trombone in C
opts.B."_template" = lalily.instrument.trombone

% the function \setDefaultTemplate sets the current folder, assigns the template and the options
% register template and options at mymusic/piece/42
\setDefaultTemplate mymusic.piece.42 group #opts
% set the title for this piece
\setTitle "Hello World"

% the current folder is mymusic/piece/42
% any call to putMusic stores at the relative path
% so \putMusic meta {} stores at mymusic/piece/42/meta

% first collect the overall information of all parts
\putMusic meta { \time 4/4 \key f \major s1 \bar "|." }
% store the music of the trumpet (here in concert pitch)
\putMusic A \relative { c''4 b a g }
% store the music of the trombone
\putMusic B \relative { c4 d e c }

% the current folder is still mymusic/piece/42 so any call to \getMusic uses paths relative to this:
% \getMusic meta retrieves mymusic/piece/42/meta
% typeset the music, but only if this file is compiled directly
% if you include this file all music is stored, but is not typeset and can be used elsewhere
\lalilyTest
```

