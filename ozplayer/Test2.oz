declare

fun {Mix P2T Music}
   local
     fun {Mix2 P2T Music}
       case Music
       of nil then nil
       [] H|T then
         case H
         of samples(Samples) then Samples|{Mix P2T T}
         [] partition(Partition) then {Echantillon {P2T Partition}|{Mix2 P2T T}
         [] wave(File) then {Project.load File}|{Mix P2T T}
         [] merge(MusicsList) then {Merge {MusicToList MusicsList P2T}}|{Mix P2T T}
         else {Filtre P2T Music}|{Mix P2T T}
         end
       end
     end
   in
    {Flatten {Mix2 P2T Music}}
   end
   %{Project.readFile 'wave/animaux/cow.wav'}
end



%ancien
fun {Mix P2T Music}
   case Music
   of nil then nil
   [] H|T then
     case H
     of samples(Samples) then Samples|{Mix P2T T}
     [] partition(Partition) then {Append {Echantillon {P2T Partition}} {Mix P2T T}}
     [] wave(File) then {Project.load File}|{Mix P2T T}
     [] merge(MusicsList) then {Merge {MusicToList MusicsList P2T}}|{Mix P2T T}
     else {Filtre P2T Music}|{Mix P2T T}
     end
   end
   %{Project.readFile 'wave/animaux/cow.wav'}
end


[] [N O A] then
   note(name:{StringToAtom [N]}
        octave:{StringToInt [O A]}
        sharp:false
        duration:1.0
        instrument: none)
end
