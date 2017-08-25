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

\include "oll-core/package.ily"
\include "oll-core/util/include-pattern.ily"
#(load-from-path "lalily-templates/scheme/bootstrap.scm")
\loadPackage edition-engraver
#(use-modules (lalily-templates scheme util))

\includePattern "templates" ".*\\.ily"

\optionsInit opts
\optionsAddL opts piano.template lalily.piano

\setDefaultTemplate song.test group #opts
\setTitle "Hallo Welt"
\putMusic piano \relative { bes'4 a c b }

%\callTemplate generic #'() #'() % OK
%\createScore #'()

#(define (add-sco-mup pre-markup score post-markup)
   (begin
    (cond ((markup? pre-markup)
           (begin
            (add-score (list pre-markup))
            (add-music #{ \noPageBreak #})))
      ((markup-list? pre-markup)
       (add-score pre-markup))
      )
    (add-score score)
    (cond ((markup? post-markup)
           (begin
            (add-music #{ \noPageBreak #})
            (add-score (list post-markup))))
      ((markup-list? post-markup)
       (add-score post-markup))
      )
    ))

% command to create one score based on the current "music folder"
lalilyCreate =
#(define-void-function ()()
   (let ((score #{
     \score {
       \createScore #'()
       \header { }
     }
           #})
         (bookpart #{
           \bookpart {
             \paper {
               $(get-music-folder-paper)
             }
             \header { }
           }
           #})
         (pre-markup (ly:assoc-get 'pre-markup (get-default-options (get-music-folder)) #f #f))
         (post-markup (ly:assoc-get 'post-markup (get-default-options (get-music-folder)) #f #f))
         (headers (assoc-get 'header (get-music-folder-options) '()))
         (copyright (get-registry-val '(lalily header copyright) #f))
         (dolayout (not (eq? (get-registry-val lalily:create #t) 'NoLayout)))
         (domidi (not (eq? (get-registry-val lalily:create #t) 'NoMidi)))
         )
     (if dolayout
         (begin
          (ly:score-add-output-def! score #{
            \layout {
              $(get-music-folder-layout)
              \context {
                \Score
                %\consists \editionEngraver ##f
                "lalily:music-folder" = $(get-music-folder)
                edition-id = $(get-music-folder)
              }
              \context {
                \Voice
                %\consists \editionEngraver ##f
              }
            }
            #})
          ))
     (if domidi (ly:score-add-output-def! score (get-music-folder-midi)))
     (if (and copyright (not (assoc-get 'copyright headers)))
         (set! headers (assoc-set! headers 'copyright copyright)))
     (set-book-headers! bookpart headers)
     (log-music-folder)
     (ly:parser-define! '$current-bookpart bookpart)
     (add-sco-mup pre-markup score post-markup)
     (collect-bookpart-for-book bookpart)
     (write-lalily-log-file)
     ))

\lalilyCreate

