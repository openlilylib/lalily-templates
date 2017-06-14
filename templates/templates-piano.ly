;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                                             %
;% This file is part of openLilyLib,                                           %
;%                      ===========                                            %
;% the community library project for GNU LilyPond                              %
;% (https://github.com/openlilylib)                                            %
;%              -----------                                                    %
;%                                                                             %
;% Library: lalily-templates                                                   %
;%          ================                                                   %
;%                                                                             %
;% openLilyLib is free software: you can redistribute it and/or modify         %
;% it under the terms of the GNU General Public License as published by        %
;% the Free Software Foundation, either version 3 of the License, or           %
;% (at your option) any later version.                                         %
;%                                                                             %
;% openLilyLib is distributed in the hope that it will be useful,              %
;% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
;% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
;% GNU General Public License for more details.                                %
;%                                                                             %
;% You should have received a copy of the GNU General Public License           %
;% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
;%                                                                             %
;% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
;% lalily-templates is maintained by Jan-Peter Voigt, jp.voigt@gmx.de          %
;% and others.                                                                 %
;%       Copyright Jan-Peter Voigt, Urs Liska, 2017                            %
;%                                                                             %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.19.49"

#(define lalily-relincl-tmp (ly:get-option 'relative-includes))
#(ly:set-option 'relative-includes #t)
\include "../lalily.ly"
#(ly:set-option 'relative-includes lalily-relincl-tmp)

\registerTemplate lalily.piano
#(define-music-function (piece options)(list? list?)
   (let ((mods (assoc-get 'context-mods options #f #f))
         (smods (assoc-get 'staff-mods options #f #f))
         (rmods (assoc-get 'right-mods options #f #f))
         (lmods (assoc-get 'left-mods options #f #f))
         (dmods (assoc-get 'dynamic-mods options #f #f))
         (pmods (assoc-get 'pedal-mods options #f #f))
         (rclef (assoc-get 'right-clef options "G" #f))
         (lclef (assoc-get 'left-clef options "bass" #f))
         (right-name (assoc-get 'right-name options "right" #f))
         (left-name (assoc-get 'left-name options "left" #f))
         )
     #{
       \new PianoStaff \with {
         $(if (ly:context-mod? mods) mods)
         \consists \editionEngraver $piece
         \override StaffGrouper.staff-staff-spacing =
         #'((basic-distance . 6)(minimum-distance . 1)(padding . 1)(stretchability . 4))
       } <<
         \new Staff = $right-name \with {
           $(if (ly:context-mod? smods) smods)
           $(if (ly:context-mod? rmods) rmods)
           \consists \editionEngraver \musicPath right
         } <<
           \keepWithTag #'piano-right \getMusicDeep {} #'meta
           \keepWithTag #'piano-right { \getMusic {} global \getMusic right }
         >>
         \new Dynamics \with {
           $(if (ly:context-mod? dmods) dmods)
           \consists \editionEngraver $piece
           \override DynamicText.padding = #1
         } { \getMusic {} dynamics }
         \new Staff = $left-name \with {
           $(if (ly:context-mod? smods) smods)
           $(if (ly:context-mod? lmods) lmods)
           \consists \editionEngraver \musicPath left
         } <<
           \keepWithTag #'piano-left \getMusicDeep {} #'meta
           \keepWithTag #'piano-left { \getMusic {} global \clef $lclef \getMusic left }
         >>
         \new Dynamics \with {
           $(if (ly:context-mod? pmods) pmods)
           \consists \editionEngraver $piece
           \override DynamicText.padding = #1
         } \getMusic {} pedal
       >>
     #}))

