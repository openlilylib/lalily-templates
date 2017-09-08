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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generic

\registerTemplate generic
#(define-music-function (piece options)(list? list?)
   (let ((tmpl (assoc-get '_template options #f)))
     (if (list? tmpl)
         (callTemplate #t tmpl #t piece options)
         (get-music piece))
     ))

\registerTemplate NOTFOUND
#(define-music-function (piece options)(list? list?)
   (let ((tmpl (assoc-get '_template options #f)))
     (if (list? tmpl)
         (callTemplate #t tmpl #t piece options)
         (begin
          (ly:input-warning (*location*) "No template specified for [~A]!" (glue-list piece "."))
          (get-music piece))
         )))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% init contexts

\registerTemplate init.Voice
#(define-music-function (piece options)(list? list?)
   (let* ((localsym (assoc-get 'init-path options '(initVoice) #f))
          (deepsym (assoc-get 'deepsym options 'initVoice #f))
          (deepdef (assoc-get 'deepdef options #{ #}))
          (deepm #{ \getMusicDeep $deepdef #deepsym #}))
     #{
       \getMusic $deepm $localsym
     #}))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% deprecate template

deprecateTemplate =
#(define-void-function (parser location)()
   (ly:input-warning location "template [~A] is deprecated!" (glue-list (get-current-template) ".")))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% create a group
\registerTemplate group
#(define-music-function (options)(list?)
   (let* ((elms
           (let ((order (ly:assoc-get '_order options #f #f)))
             (if (and (list? order)(> (length order) 0))
                 (map (lambda (p)
                        (cons p (ly:assoc-get p options '() #f))) order)
                 (filter
                  (lambda (p)
                    (and
                     (pair? p)
                     (not (string-startswith (format "~A" (car p)) "_"))))
                  options)))) ; (assoc-get 'part options (assoc-get 'element options '())))
          (group (assoc-get '_group options #f))
          (group-mods (assoc-get '_group-mods options #f))
          (remove-tags (assoc-get '_remove-tags options #f))
          (parts (if (> (length elms) 0)
                     (make-music 'SimultaneousMusic 'elements
                       (map
                        (lambda (p)
                          (let* ((opts (cdr p))
                                 (music (assoc-get '_music opts (create-music-path #f (list (car p)))))
                                 (opts (assoc-set-all! (get-default-options music) opts))
                                 (template (assoc-get '_template opts (get-default-template music)))
                                 (path (assoc-get '_music opts (list (car p))))
                                 (part #{ \callTemplate ##t #template #path #opts #})
                                 )
                            (if (and (list? remove-tags)(> (length remove-tags) 0))
                                (removeWithTag remove-tags part)
                                part)
                            )) elms))
                     (make-music 'SimultaneousMusic 'void #t)))
          )
     (if (symbol? group)
         #{
           \new $group \with {
             $(if (ly:context-mod? group-mods) group-mods)
           } $parts
         #}
         parts
         )
     ))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Transpose

\registerTemplate transpose
#(define-music-function (piece options)(list? list?)
   (let ((template (ly:assoc-get '_template options #f #f))
         (opts (let ((pce (ly:assoc-get '_piece options #f #f))) (if pce (get-default-options pce) options)))
         (pce (ly:assoc-get '_piece options piece #f))
         (pdiff (ly:assoc-get '_transpose options piece #f) )
         (natpit (get-option '_naturalize options #f))
         )
     (define (naturalize-pitch p)
       (let ((o (ly:pitch-octave p))
             (a (* 4 (ly:pitch-alteration p)))
             ;; alteration, a, in quarter tone steps,
             ;; for historical reasons
             (n (ly:pitch-notename p)))
         (cond
          ((and (> a 1) (or (eq? n 6) (eq? n 2)))
           (set! a (- a 2))
           (set! n (+ n 1)))
          ((and (< a -1) (or (eq? n 0) (eq? n 3)))
           (set! a (+ a 2))
           (set! n (- n 1))))
         (cond
          ((> a 2) (set! a (- a 4)) (set! n (+ n 1)))
          ((< a -2) (set! a (+ a 4)) (set! n (- n 1))))
         (if (< n 0) (begin (set! o (- o 1)) (set! n (+ n 7))))
         (if (> n 6) (begin (set! o (+ o 1)) (set! n (- n 7))))
         (ly:make-pitch o n (/ a 4))))
     (define (naturalize music)
       (let ((es (ly:music-property music 'elements))
             (e (ly:music-property music 'element))
             (p (ly:music-property music 'pitch)))
         (if (pair? es)
             (ly:music-set-property!
              music 'elements
              (map (lambda (x) (naturalize x)) es)))
         (if (ly:music? e)
             (ly:music-set-property!
              music 'element
              (naturalize e)))
         (if (ly:pitch? p)
             (begin
              (set! p (naturalize-pitch p))
              (ly:music-set-property! music 'pitch p)))
         music))
     (if (not (list? pce))(set! pce (list pce)))
     (let ((transp
            (ly:music-transpose
             (ly:music-deep-copy
              (call-template template pce options)
              ) pdiff)
            ))
       (if natpit (naturalize transp) transp))
     ))
setTransposedTemplate =
#(define-void-function (t1 t2 piece tmpl options)
   (ly:pitch? ly:pitch? list? list? list?)
   (set-default-template piece '(transpose)
     (assoc-set-all! options
       `((_transpose . ,(ly:pitch-diff t2 t1))
         (_template . ,tmpl)))))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mirror another music-folder

% needs option 'mirror-path
% may set other options fo the inherited templated
\registerTemplate lalily.mirror
#(define-music-function (options)(list?)
   (let ((path (assoc-get 'mirror-path options #f #f)))
     (if (not (list? path))
         (begin
          (ly:input-warning location "no mirror-path! (~A | ~A)" path piece)
          (set! path '(..))
          ))
     #{
       \createScoreWithOptions #path #options
     #}))

