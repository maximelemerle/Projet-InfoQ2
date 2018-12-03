

declare

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun{Echo2 delay decay repeat music ListM}
  if repeat <= 0 then    %!!!!! aux negations autres fonctions !!!!!
    {Merge ListM}
  else
    {Echo2 delay+delay decay*decay repeat-1 music {List.append ListM Decay#{Append L{Float.toInt Delay*44100}} Music}}
  end

          %% cut !!!!!
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun{LowPass samples a b c d e f}
  case samples of nil
  then nil
  [] H|T then
    {Lowpass2 H b c d e f} | {LowPass T a H b c d e}
  end
end

fun{LowPass2 a b c d e f}
  a*0.1169 + b*0.1746 + c*0.2084 + d*0.2084 + e*0.1746 + f*0.1169
end


% appeler {cut {LowPass samples 0 0 0 0 0 0}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun{crossfade seconds music1 music2}
  {cut music1 0 ({List.length Music1}/44100)} | {Merge 1#{Fade 0 seconds {List.take music2 seconds*44100}} 1#{Fade seconds 0 {List.drop {List.length Music1}-seconds*44100)}}} | {List.drop music2 seconds*44100}
end
