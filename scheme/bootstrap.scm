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

(use-modules
 (lily)
 (lalily-templates scheme definitions)
 (lalily-templates scheme registry)
 )

(load-from-path "lalily-templates/scheme/store-init.scm")

(ly:message "lalily templates ~A" (lalily-version-string))
