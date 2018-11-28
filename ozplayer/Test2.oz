declare
% fun {Mix P2T Music}
%    % TODO
%    case Music
%    of nil then nil
%    [] samples(S) then samples(S)
%    [] partition(P) then {Echantillon {P2T P}}
%    [] wave(F) then
%    [] merge(M) then
%    else {Filtre }
%    end
%    {Project.readFile 'wave/animaux/cow.wav'}
% end

fun {Echo Delay Decay Music}
  {Merge [1.0#Music Decay#{Append {L {Float.toInt Delay*1.0}} Music}]}
end

fun {L T}
   if T==0 then
      nil
   else
      0.0|{L T-1}
   end
end
