 declare
 fun {NoteToExtended Note}
    case Note
    of note(duration:D instrument:I name:N octave:O sharp:S) then
       note(name:N octave:O sharp:S duration:D instrument:I)
    [] silence(duration:D) then
       silence(duration:D)
    [] duration(seconds:S L) then
       {Duration L S}
    [] stretch(factor:F L) then
       {Stretch L F}
    [] drone(amount:A note:N) then
       {Drone N A}
    [] transpose(semitones:S L) then
       {Transpose S L}
    [] silence then
       silence(duration:1.0)
    [] Name#Octave then
       note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
    [] Atom then
       case {AtomToString Atom}
       of [_] then
          note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
       [] [N O] then
          note(name:{StringToAtom [N]}
               octave:{StringToInt [O]}
               sharp:false
               duration:1.0
               instrument: none)
       end
    end
 end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {ChordToExtended Chord}
  case Chord
  of nil then nil
  [] H|T then
      case H
      of H1|T1 then {ChordToExtended H}|{ChordToExtended T}
      else {NoteToExtended H}|{ChordToExtended T}
      end
  else nil
  end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 fun {Duration P S}
   local
     fun {DRatio P S Acc}
       case P
       of nil then {Float.'/' S Acc}
       [] H|T then
          case H
          of nil then S/Acc
          [] H1|T1 then {DRatio H S Acc}
          else {DRatio T S Acc+H.duration}
          end
       end
     end
     Partition = {ChordToExtended P}
   in
    {Stretch Partition {DRatio Partition S 0.0}}
   end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 fun {Stretch Partition Facteur}
   local
       fun {Str Partition Facteur}
         local
           X
         in
           case Partition
           of nil then nil
           [] H|T then
              case H
              of H1|T1 then
                {Str H Facteur}
              else
                 X = {Record.clone H}
                 X.name = H.name
                 X.duration = H.duration*Facteur
                 X.octave = H.octave
                 X.sharp = H.sharp
                 X.instrument = H.instrument
                 X|{Str T Facteur}
              end
           end
         end
       end
  in
    {Str {ChordToExtended Partition} Facteur}
  end
 end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {Drone NoteOrChord Amount}
  if Amount==0 then
    nil
  else
    NoteOrChord|{Drone NoteOrChord Amount-1}
  end
end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 fun {Transpose Integer Partition}
   local
     P = {ChordToExtended Partition}
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
     fun {GetRow Note}
       case Note
       of note(name:c octave:_ sharp:false duration:_ instrument:none) then 0
       [] note(name:c octave:_ sharp:true duration:_ instrument:none) then 1
       [] note(name:d octave:_ sharp:false duration:_ instrument:none) then 2
       [] note(name:d octave:_ sharp:true duration:_ instrument:none) then 3
       [] note(name:e octave:_ sharp:false duration:_ instrument:none) then 4
       [] note(name:f octave:_ sharp:false duration:_ instrument:none) then 5
       [] note(name:f octave:_ sharp:true duration:_ instrument:none) then 6
       [] note(name:g octave:_ sharp:false duration:_ instrument:none) then 7
       [] note(name:g octave:_ sharp:true duration:_ instrument:none) then 8
       [] note(name:a octave:_ sharp:false duration:_ instrument:none) then 9
       [] note(name:a octave:_ sharp:true duration:_ instrument:none) then 10
       [] note(name:b octave:_ sharp:false duration:_ instrument:none) then 11
       end
     end
     fun {GetColumn Octave}
       Octave+1
     end
     fun {Transpose2 Integer Partition}
       case Partition
       of nil then nil
       [] H|T then
          local
            X
          in
            X = {GetLetter {GetRow H}+{GetColumn H.octave}*12+Integer}
            X.octave = {GetOctave Number}
            X.duration = H.duration
            X|{Transpose2 Integer T}
          end
       end
     end
   in
     {Transpose2 Integer P}
   end
 end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {PartitionToTimedList Partition}
  case Partition
  of nil then nil
  [] H|T then
     case H
     of nil then nil
     [] H1|T1 then
        {ChordToExtended H}|{PartitionToTimedList T}
     else
        {NoteToExtended H}|{PartitionToTimedList T}
     end
  end
end
%Partition = [silence b c d#2 b4 [e f5 g8]]

{Browse {PartitionToTimedList Partition}}
