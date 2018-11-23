fun {Mix P2T Music}
   % TODO
   case Music
   of nil then nil
   [] samples(S) then samples(S)
   [] partition(P) then {Echantillon {P2T P}}
   [] wave(F) then
   [] merge(M) then
   else {Filtre }
   end
   {Project.readFile 'wave/animaux/cow.wav'}
end

fun {Echantillon Partition}
    local
      fun {Hauteur Note}
         {GetRow Note}+{GetColumn Note.octave}-69
      end
      fun {Echantillon2 Note I}
        local
        	    X = 3.14159265359*{Pow 2.0 {Float.'/' {Int.toFloat {Hauteur Note}} 12.0}}*{Float.'/' {Int.toFloat Note.duration}*{Int.toFloat I}*44.0 2205.0}
        	 in
        	    {Float.sin X}/2.0
        end
      end
      fun {Echantillon3 Note I Acc}
          if I<44100 then
            {Echantillon3 Note I+1 Acc|{Echantillon2 Note I}}
          else
            Acc.2|nil
          end
      end
    in
      case Partition
      of nil then nil
      [] H|T then
          {Echantillon3 H 1 1}|{Echantillon T}
      end
    end
end








































declare

fun {GetRow Note}
   case Note
   of note(name:c octave:_ sharp:false duration:1.0 instrument:none) then 0
   [] note(name:c octave:_ sharp:true duration:1.0 instrument:none) then 1
   [] note(name:d octave:_ sharp:false duration:1.0 instrument:none) then 2
   [] note(name:d octave:_ sharp:true duration:1.0 instrument:none) then 3
   [] note(name:e octave:_ sharp:false duration:1.0 instrument:none) then 4
   [] note(name:f octave:_ sharp:false duration:1.0 instrument:none) then 5
   [] note(name:f octave:_ sharp:true duration:1.0 instrument:none) then 6
   [] note(name:g octave:_ sharp:false duration:1.0 instrument:none) then 7
   [] note(name:g octave:_ sharp:true duration:1.0 instrument:none) then 8
   [] note(name:a octave:_ sharp:false duration:1.0 instrument:none) then 9
   [] note(name:a octave:_ sharp:true duration:1.0 instrument:none) then 10
   [] note(name:b octave:_ sharp:false duration:1.0 instrument:none) then 11
   end
end
fun {GetColumn Octave}
   Octave+1
end

fun {Echantillon Partition}

      local
        fun {Hauteur Note}
           {GetRow Note}+{GetColumn Note.octave}-69
        end
        fun {Echantillon2 Note}
          {Float.sin 3.1459265359*{Pow 2 {Hauteur Note}/12}*Note.duration*44/2205}/2
        end
      in
         case Partition
         of nil then nil
         [] H|T then
             {Echantillon2 H}|{Echantillon T}
         end
      end
end

{Browse {Echantillon [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:a octave:10 sharp:false duration:1.0 instrument:none) note(name:b octave:4 sharp:false duration:1.0 instrument:none)]}}
