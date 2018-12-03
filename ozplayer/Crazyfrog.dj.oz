local
   Part = [stretch(factor:0.75 [d stretch(factor:0.75 [f]) stretch(factor:0.25 [d d d]) stretch(factor:0.5 [g d c])])]
   PartBis = [stretch(factor:0.75 [d stretch(factor:0.75 [a]) stretch(factor:0.25 [d d d]) stretch(factor:0.5 [a#4 a f d a d]) stretch(factor:0.25 [d c c c])])]
   PartBisBis = [stretch(factor:0.75 [stretch(factor:0.5 [a e d]) stretch(factor:2.0 [d]) silence c c])]
   Partition = {Flatten [Part PartBis PartBisBis]}
in
   % This is a music :)
   [partition(Partition)]
end

%   Part = [stretch(factor:0.5 [d]) stretch(factor:0.75 [f]) duration(seconds:0.75 [d d d])]
%   PartBis = [stretch(factor:0.5 [g]) duration(seconds:0.666 [d c]) stretch(factor:0.5 [d]) stretch(factor:0.75 [a])]
%   PartBisBis = [duration(seconds:0.75 [d d d]) stretch(factor:0.5 [a]) duration(seconds:0.666 [a f]) duration(seconds:0.666 [d a])]
%   Partition = {Flatten [Part PartBis PartBisBis]}
