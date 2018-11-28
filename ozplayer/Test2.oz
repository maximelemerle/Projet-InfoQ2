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

declare
fun {Fade Start Out Music}
   local
      fun {FadeIn Start Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}<5.0*Start then
             H*{Float.'/' {Int.toFloat Acc} Start*5.0}|{FadeIn Start T Acc+1}
          else nil
          end
        end
      end
      L =  {List.drop Music {List.length Music}-{Float.toInt Out*5.0}}
      fun {FadeOut Out Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}>=0.0 then
             H*{Float.'/' {Int.toFloat Acc} Out*5.0}|{FadeOut Out T Acc-1}
          else nil
          end
        end
      end
   in
      {Flatten [{FadeIn Start Music 0} {Cut Start Out Music} {FadeOut Out L {Float.toInt 5.0*Out-1.0}}]}
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Cut Start Finish Music}
  if Finish>{Int.toFloat {List.length Music}}/5.0 then
    local
       L = {List.drop Music {Float.toInt Start*5.0}}
       Length = 5.0*(Finish-Start)-{Int.toFloat {List.length L}}
    in
      {Flatten [L {L {Float.toInt Length}}]}
    end
  else
    local
      X = {List.drop Music {Float.toInt Start*5.0}}
    in
      {List.take X {Float.toInt Finish*5.0}}
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {L T}
   if T==0 then
      nil
   else
      0.0|{L T-1}
   end
end
X = [1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
{Browse {Fade 1.0 1.0 X}}
