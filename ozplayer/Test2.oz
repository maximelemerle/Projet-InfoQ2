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


fun {Transpose Integer Partition}
  local
    P = {ChordToExtended Partition}                %{PartitionToTimedList Partition}
    fun {GetLetter Number}
      case Number mod 12
      of 0 then note(name:c octave:_ sharp:false duration:_ instrument:none)
      [] 1 then note(name:c octave:_ sharp:true duration:_ instrument:none)
      [] 2 then note(name:d octave:_ sharp:false duration:_ instrument:none)
      [] 3 then note(name:d octave:_ sharp:true duration:_ instrument:none)
      [] 4 then note(name:e octave:_ sharp:false duration:_ instrument:none)
      [] 5 then note(name:f octave:_ sharp:false duration:_ instrument:none)
      [] 6 then note(name:f octave:_ sharp:true duration:_ instrument:none)
      [] 7 then note(name:g octave:_ sharp:false duration:_ instrument:none)
      [] 8 then note(name:g octave:_ sharp:true duration:_ instrument:none)
      [] 9 then note(name:a octave:_ sharp:false duration:_ instrument:none)
      [] 10 then note(name:a octave:_ sharp:true duration:_ instrument:none)
      [] 11 then note(name:b octave:_ sharp:false duration:_ instrument:none)
      end
    end
    fun {GetOctave Number}
       Number div 12 -1
    end
    fun {Transpose2 Integer Partition}
      case Partition
      of nil then nil
      [] H|T then
         case H
         of nil then nil
         [] H1|T1 then
             {ChordToExtended H}|{Transpose2 Integer T}        %{PartitionToTimedList H}|{Transpose2 Integer T}
         [] silence(duration:D) then
             H|{Transpose2 Integer T}
         else
             local
               X Number
             in
               Number = {GetRow H}+{GetColumn H.octave}*12+Integer
               X = {GetLetter Number}
               X.octave = {GetOctave Number}
               X.duration = H.duration
               X|{Transpose2 Integer T}
             end
         end
      end
    end
  in
    {Transpose2 Integer P}
  end
end



{Clip ~1.0 1.0 {Flatten {Mix2 P2T Music}}}

{Merge2 MusicsList nil} %328
