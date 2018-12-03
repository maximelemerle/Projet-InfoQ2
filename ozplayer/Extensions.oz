

declare


fun{Lissage partition samples}   %%% !!! appeler lissage et mix de partition    !!!!! chord !!!!!
  case partition 
  of nil then nil 
  [] H|T then 
    {LissIn H.duree {SampIn H.duree samples} -4410} | {SampMid H.duree samples} | {LissOut H.duree {Sampout H.duree samples} -4410}| {Lissage T {List.drop samples 44100*H.duree}}
  end
end

                    


fun{LissIn dureenote samplesIn Acc}  % apeler avec note.duree
  case samplesIn of nil then nil
  [] H|T then 
    if dureenote >= 1 then
      if Acc < 4410 then
        H * ((atan(3*(Acc/4410))/2) +1/2) | {LissIN T Acc+1} %Acc commence à -4410 
      else nil
    else 
      if Acc < 4410*dureenote then 
        H * ((atan(3*(Acc/(4410*dureenote))/2) +1/2) | {LissIN T Acc+1} 
      else
        nil
      end
    end
  end
end


fun{LissOut dureenote samplesOut Acc}
  case samplesOut of nil then nil
  [] H|T then 
    if dureenote >= 1 then
      if Acc < 4410 then
        H * (-((atan(3*(Acc/4410))/2) -1/2)) | {LissIN T Acc+1}
      else nil
    else 
      if Acc < 4410*dureenote then 
        H * (-((atan(3*(Acc/4410*dureenote))/2) -1/2)) | {LissIN T Acc+1}
      else
        nil
      end
    end
  end
end



fun{SampIn dureenote samples}
  if dureenote >= 1 then 
    {List.take samples 8820}
  else
    {List.take samples 8820*dureenote}
  end
end


fun{SampMid dureenote samples}
  if dureenote >= 1 then
    {List.drop {List.take samples 44100*dureenote -8820} 8820} 
  else
    {List.drop {List.take samples 44100*dureenote -8820*dureenote} 8820*dureenote} 
  end
end

fun{SampOut dureenote samples}
  if dureenote >= 1 then 
    {List.drop 44100*dureenote - 8820} 
  else
    {List.drop 44100*dureenote - 8820*dureenote}
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



