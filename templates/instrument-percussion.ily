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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Timpani

\registerTemplate lalily.instrument.timpani
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(..)) piece
     (assoc-set-all! `((name . "timpani")
                       (midi-instrument . "timpani")
                       (clef . "bass")
                       ) options)
     ))


\registerTemplate lalily.percussions.generic
#(define-music-function (piece options)(list? list?)
   (let ((instrument-name (ly:assoc-get 'instrument-name options #f))
         (short-name (ly:assoc-get 'short-name options #f))
         (line-positions (ly:assoc-get 'line-positions options '(0)))
         (staff-mods (ly:assoc-get 'staff-mods options #f))
         )
     #{
       \new DrumStaff \with {
         $(if (ly:context-mod? staff-mods) staff-mods)
         instrumentName = $instrument-name
         shortInstrumentName = $short-name
         \override StaffSymbol.line-positions = #line-positions
         %drumStyleTable = #(alist->hash-table mydrums)
       } <<
         \getMusicDeep meta
         { R1*4 | d2 d4 r16 d d d | d1 }
       >>
     #}))



