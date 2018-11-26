declare

fun {Filtre Args}
  case Args
  of nil then nil
  [] reverse() then {Reverse {Mix P2T .....}}
  end
end

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
  local
    fun {Clip2 L1}
      case L1
      of nil then nil
      [] H|T then
        if H>High then
          High|{Clip2 T}
        elseif H<Low then
          Low|{Clip2 T}
        else
          H|{Clip2 T}
        end
      end
    end
  in
    {Clip2 Music}
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% !!!!!!!!!!!!!!!!!!!!!!! fadeout doit etre egal a 0 a la fin + take drop marche pas
fun {Fade Music Start Out}
   local
      fun {FadeIn Start Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}<44100.0*Start then
             {Int.toFloat H}*{Float.'/' {Int.toFloat Acc} Start*44100.0}|{FadeIn Start T Acc+1}
          else nil
          end
        end
      end
      L =  {List.drop Music {List.length Music}-{Float.toInt Out*44100.0}}
      fun {FadeOut Out Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}>0.0 then
             {Int.toFloat H}*{Float.'/' {Int.toFloat Acc} Out*44100.0}|{FadeOut Out T Acc-1}
          else nil
          end
        end
      end
   in
      {Flatten [{FadeIn Start Music 0} {List.drop {List.take Music {Float.toInt Out*5.0}} {Float.toInt Start*5.0}} {FadeOut Out L {Float.toInt 5.0*Out}}]}
   end
end

X = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]


fun {Cut Start Finish Music}
  if Finish>{Int.toFloat {List.length Music}}/44100.0 then
    local
       L = {List.drop Music {Float.toInt Start*44100.0}}
       Length = 44100.0*(Finish-Start)-{Int.toFloat {List.length L}}
    in
      {Flatten [L {List0 {Float.toInt Length}}]}
    end
  else
    local
      X = {List.drop Music {Float.toInt Start*44100.0}}
    in
      {List.take X {Float.toInt Finish*44100.0}}
    end
  end
end

fun {List0 T}
   if T==0 then
      nil
   else
      0|{List0 T-1}
   end
end














































fun {Fade Music Start Out}
   local
      fun {FadeIn Start Music Acc}
        case Music of nil then nil
        [] H|T then
          if {Int.toFloat Acc}<5.0*Start then
             {Int.toFloat H}*{Float.'/' {Int.toFloat Acc} Start*5.0}|{FadeIn Start T Acc+1}
          else nil
          end
        end
      end
      L =  {List.drop Music {List.length}-{Float.toInt Out*5.0}}
      fun {FadeOut Out Music Acc}
	 case Music
	 of nil then nil
	 [] H|T then
	    if {Int.toFloat Acc}>0.0 then
	       {Int.toFloat H}*{Float.'/' {Int.toFloat Acc} Out*5.0}|{FadeOut Out T Acc-1}
	    else nil
	    end
	 end
      end
   in
      {Flatten [{FadeIn Start Music 0} {List.drop {List.take Music Out*5.0} Start*5.0} {FadeOut Out L 5.0*Out}] }
   end
end

X = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
{Browse {Fade X 1.0 1.0}}
