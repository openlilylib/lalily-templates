# lalily-templates

This provides a template package for openLilyLib. It is taken from [lalily](https://github.com/jpvoigt/lalily) and adapted for openLilyLib.

Right now the basic engine is working and a few templates are working.
It requires the latest development version and is intended for the upcoming version 2.20 of LilyPond.

Maintainer: Jan-Peter Voigt
Licence: GPL V3

## Example

```lilypond
\version "2.19.65"
% lalily-templates are include via the current plugin-mechanism of openLilyLib (https://github.com/openlilylib/oll-core)
\include "oll-core/package.ily"
\loadPackage lalily-templates

% a variable to prepare the score
opts = #'()
% the parts of this score are A and B
opts."_order" = A.B
% A is played by trumpet in B flat
opts.A."_template" = lalily.instrument.trumpet
% B is played by trombone in C
opts.B."_template" = lalily.instrument.trombone

% register template and options at mymusic/piece/42
\setDefaultTemplate mymusic.piece.42 group #opts
% set the title of this piece
\setTitle "Hello World"

% store the music
% first collect the overall information of all parts
\putMusic meta { \time 4/4 \key f \major s1 \bar "|." }
% store the music of the trumpet (here in concert pitch)
\putMusic A \relative { c''4 b a g }
% store the music of the trombone
\putMusic B \relative { c4 d e c }

% typeset the music, but only if this file is compiled directly -- not included
\lalilyTest
```

