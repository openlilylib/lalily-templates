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
%%% woodwind

\registerTemplate lalily.instrument.piccolo
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(..)) piece
     (assoc-set-all! options `((name . "piccolo")
                               (transposition . ,(ly:make-pitch 1 0 0))
                               (midi-instrument . "piccolo")
                               ))))

\registerTemplate lalily.instrument.flute
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(..)) piece
     (assoc-set-all! options `((name . "flute")
                               (midi-instrument . "flute")
                               ))))

\registerTemplate lalily.instrument.oboe
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(..)) piece
     (assoc-set-all! options `((name . "oboe")
                               (midi-instrument . "oboe")
                               ))))

\registerTemplate lalily.instrument.english-horn
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(..)) piece
     (assoc-set-all! options `((name . "english-horn")
                               (transposition . ,(ly:make-pitch -1 3 0))
                               (midi-instrument . "english horn")
                               ))))

\registerTemplate lalily.instrument.bassoon
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(..)) piece
     (assoc-set-all! options `((name . "bassoon")
                               (midi-instrument . "bassoon")
                               (clef . "bass")
                               ))))


\registerTemplate lalily.instrument.sax.sop
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(.. ..)) piece
     (assoc-set-all! options `((name . "saxsop")
                               (transposition . ,(ly:make-pitch -1 6 -1/2)) ; b
                               (midi-instrument . "soprano sax")
                               ))))
\registerTemplate lalily.instrument.sax.alt
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(.. ..)) piece
     (assoc-set-all! options `((name . "saxalt")
                               (transposition . ,(ly:make-pitch -1 2 -1/2)) ; ees
                               (midi-instrument . "alto sax")
                               ))))

\registerTemplate lalily.instrument.sax.ten
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(.. ..)) piece
     (assoc-set-all! options `((name . "saxten")
                               (transposition . ,(ly:make-pitch -2 6 -1/2)) ; b
                               (midi-instrument . "tenor sax")
                               ))))
\registerTemplate lalily.instrument.sax.bar
#(define-music-function (piece options)(list? list?)
   (call-template (create-template-path #f '(.. ..)) piece
     (assoc-set-all! options `((name . "saxbar")
                               (transposition . ,(ly:make-pitch -2 2 -1/2)) ; ees
                               (midi-instrument . "baritone sax")
                               ))))


