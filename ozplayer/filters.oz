declare

% Transforme music en samples puis renverse
% Mettre fct custom%%%%%%%%%%%%%%%%%%%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
fun {Reverse Music}
  {List.reverse Music}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Repeat Integer Music}
  if Integer==0 then
    nil
  else
    Music|{Repeat Integer-1 Music}
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Loop Duration Music}
  local
    Taille = {List.length Music}
    X Y
  in
    if Taille<Duration then
      X = Duration mod Taille
      Y = Duration div Taille
      {Flatten {Repeat Y Music}|{List.take Music X*44100}}
    else
      {List.take Music X*44100}
    end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Clip Low High Music}
    case Music
    of nil then nil
    [] H|T then
      if H>High then
        High|{Clip Low High T}
      elseif H<Low then
        Low|{Clip Low High T}
      else
        H|{Clip Low High T}
      end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Echo Delay Decay Music}
  {Merge [1.0#Music Decay#{Append {L {Float.toInt Delay*1.0}} Music}]}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {Fade Start Out Music}   % pb a la fin je pense !!!!!!!!%
   local
      fun {FadeIn Start Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}<44100.0*Start then
             H*{Float.'/' {Int.toFloat Acc} Start*44100.0}|{FadeIn Start T Acc+1}
          else nil
          end
        end
      end
      L =  {List.drop Music {List.length Music}-{Float.toInt Out*44100.0}}
      fun {FadeOut Out Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}>=0.0 then
             H*{Float.'/' {Int.toFloat Acc} Out*44100.0}|{FadeOut Out T Acc-1}
          else nil
          end
        end
      end
   in
      {Flatten [{FadeIn Start Music 0} {Cut Start Out Music} {FadeOut Out L {Float.toInt 44100.0*Out-1.0}}]}  % pas cut star et out !!!!%
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Cut Start Finish Music}
  if Finish>{Int.toFloat {List.length Music}}/44100.0 then
    local
       L = {List.drop Music {Float.toInt Start*44100.0}}
       Length = 44100.0*(Finish-Start)-{Int.toFloat {List.length L}}
    in
      {Flatten [L {L {Float.toInt Length}}]}
    end
  else
    local
      X = {List.drop Music {Float.toInt Start*44100.0}}
    in
      {List.take X {Float.toInt Finish*44100.0}}
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
