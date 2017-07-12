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

; TODO should be in oll-core

(define-module (lalily-templates scheme registry))

(use-modules
 (lily)
 (oll-core tree))

(define-public (get-registry-val key . def) #f)
(define-public (set-registry-val key val) #f)
(define-public (display-registry) #f)
(let ((vals (tree-create 'registry)))
  (set! get-registry-val (lambda (key . def)
                           (let ((ret (tree-get vals (if (list? key) key (list key)))))
                             (if ret ret (if (> (length def) 0)(car def) #f)))))
  (set! set-registry-val (lambda (key val) (tree-set! vals (if (list? key) key (list key)) val)))
  (set! display-registry (lambda () (tree-display vals
                                      `(vformat .
                                         ,(lambda (v)
                                            (let ((str (if (markup? v)
                                                           (markup->string v)
                                                           (format "~A" v)
                                                           )))
                                              (if (> (string-length str) 79)
                                                  (string-append
                                                   (substring/read-only str 0 76) " ...") str)) )))))
  )

(define (not-null? val)(if val #t #f))

(define-public getRegistryVal (define-scheme-function (parser location key def)(list? not-null?)
                                (get-registry-val key def)))
(define-public setRegistryVal (define-music-function (parser location key val)(list? not-null?)
                                (set-registry-val key val)
                                (make-music 'SequentialMusic 'void #t)))
