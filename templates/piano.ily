%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of openLilyLib,                                           %
%                      ===========                                            %
% the community library project for GNU LilyPond                              %
% (https://github.com/openlilylib)                                            %
%              -----------                                                    %
%                                                                             %
% Library: lalily-templates                                                   %
%          ================                                                   %
%                                                                             %
% openLilyLib is free software: you can redistribute it and/or modify         %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% openLilyLib is distributed in the hope that it will be useful,              %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU General Public License for more details.                                %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
%                                                                             %
% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
% lalily-templates is maintained by Jan-Peter Voigt, jp.voigt@gmx.de          %
% and others.                                                                 %
%       Copyright Jan-Peter Voigt, Urs Liska, 2017                            %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.19.60"

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
         \editionID ##f $piece
         $(if (ly:context-mod? mods) mods)
       } <<
         \new Staff = $right-name \with {
           \editionID right
           $(if (ly:context-mod? smods) smods)
           $(if (ly:context-mod? rmods) rmods)
         } <<
           \keepWithTag #'piano-right \getMusicDeep {} #'meta
           \keepWithTag #'piano-right { \getMusic {} global \clef $rclef \getMusic right }
         >>
         \new Dynamics \with {
           \editionID dynamics
           \override DynamicText.padding = #1
           $(if (ly:context-mod? dmods) dmods)
         } { \getMusic {} dynamics }
         \new Staff = $left-name \with {
           \editionID left
           $(if (ly:context-mod? smods) smods)
           $(if (ly:context-mod? lmods) lmods)
         } <<
           \keepWithTag #'piano-left \getMusicDeep {} #'meta
           \keepWithTag #'piano-left { \getMusic {} global \clef $lclef \getMusic left }
         >>
         \new Dynamics \with {
           \editionID pedal
           $(if (ly:context-mod? pmods) pmods)
         } \getMusic {} pedal
       >>
     #}))

