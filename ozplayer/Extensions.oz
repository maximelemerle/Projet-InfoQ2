declare


fun{Lissage Note Samples}   %%% !!! appeler lissage et mix de partition    !!!!! chord !!!!!
    local
      Length = {Min 8820.0 0.2*Note.duration*44100.0}
      OutLength = Note.duration*44100.0-Length
      FrontSection = {List.take Samples {Float.toInt Length}}
      MidSection = {List.drop {List.take Samples {Float.toInt OutLength}} {Float.toInt Length}}
      EndSection = {List.drop Samples {Float.toInt OutLength}}
    in
      {LissIn Length FrontSection}|MidSection|{LissOut Length EndSection}|
    end
end

fun {LissIn Length Samples}
  local
    LengthSquared = Length*Length
    fun{Liss Length Samples LengthSquared Acc}  % apeler avec note.duree
      case samples
      of nil then nil
      [] H|T then
          if Acc<0 then
            ~H*{Int.toFloat Acc*Acc}/LengthSquared + 1|{Liss Length T Acc+1}
          else nil
          end
      end
    end
  in
    {LissIn Length Samples LengthSquared {Float.toInt ~Length}}
  end
end

fun {LissOut Length Samples}
  local
    LengthSquared = Length*Length
    fun{Liss Length Samples LengthSquared Acc}  % apeler avec note.duree
      case samples
      of nil then nil
      [] H|T then
          if Acc<Length then
            ~H*{Int.toFloat Acc*Acc}/LengthSquared + 1|{Liss Length T Acc+1}
          else nil
          end
      end
    end
  in
    {LissOut Length Samples LengthSquared 0}
  end
end

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
