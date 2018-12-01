

declare


fun{Lissage partition samples}   %%% !!! appeler lissage et mix de partition    !!!!! chord !!!!!
  case partition 
  of nil then nil 
  [H|T] then 
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
        H * ((atan(3*(Acc/4410*dureenote))/2) +1/2) | {LissIN T Acc+1} 
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
    {List.drop {List.take samples 44100*dureenote} 8820} 
  else
    {List.drop {List.take samples 44100*dureenote} 8820*dureenote} 
  end
end

fun{SampOut dureenote samples}
  if dureenote >= 1 then 
    {List.drop {List.take samples 44100*dureenote - 8820} 8820} 
  else
    {List.drop {List.take samples 44100*dureenote - 8820*dureenote} 8820*dureenote}
