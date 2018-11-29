local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
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
         of nil then nil
         [] H1|T1 then {ChordToExtended H}|{ChordToExtended T}
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
     if Amount==0 then nil
     else
     {ChordToExtended NoteOrChord}|{Drone NoteOrChord Amount-1}
     end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
       fun {Transpose2 Integer Partition}
         case Partition
         of nil then nil
         [] H|T then
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
          {Append2 {NoteToExtended H} {PartitionToTimedList T}}
       end
     end
   end

   fun {Append2 L1 L2}
      case L1
      of nil then nil
      [] H|T then
          {Append L1 L2}
      else
          {Append L1|nil L2}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Filtre P2T Music}
      case Music
      of nil then nil
      [] reverse(Music) then                 {Reverse {Mix P2T Music}}
      [] repeat(amount:Integer Music) then   {Repeat Integer {Mix P2T Music}}
      [] loop(duration:Duration Music) then  {Loop Duration {Mix P2T Music}}
      [] clip(low:Low high:High Music) then  {Clip Low High {Mix P2T Music}}
      [] echo(delay:Delay decay:Decay Music) then {Echo Delay Decay {Mix P2T Music}}
      [] fade(start:Start out:Out Music) then   {Fade Start Out {Mix P2T Music}}
      [] cut(start:Start finish:End Music) then {Cut Start End {Mix P2T Music}}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Partition deja extended
   fun {Echantillon Partition}
       local
         fun {Hauteur Note}
            {GetRow Note}+{GetColumn Note.octave}*12-69
         end
         fun {Echantillon2 Note I}
           local
           	    X = 3.14159265359*{Pow 2.0 {Float.'/' {Int.toFloat {Hauteur Note}} 12.0}}*{Float.'/' Note.duration*{Int.toFloat I}*44.0 2205.0}
           	 in
           	    {Float.sin X}/2.0
           end
         end
         fun {Echantillon3 Note I}
           if Note.duration*{Int.toFloat I}<44100.0 then
             {Echantillon2 Note I}|{Echantillon3 Note I+1}
           else nil
           end
         end
       in
         case Partition
         of nil then nil
         [] H|T then
            case H
            of nil then nil
            [] H1|T1 then
              {Merge {ListToListWithIntensitiesOne {Echantillon H}}}
            else
              {Echantillon3 H 1}|{Echantillon T}
            end
         end
       end
   end

   fun {ListToListWithIntensitiesOne L}
     case L
     of nil then nil
     [] H|T then
       1.0#H|{ListToListWithIntensitiesOne T}
     end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {MusicToList MusicsList P2T}
      case MusicsList
      of nil then nil
      [] H|T then
        case H
        of nil then nil
        [] Facteur#Music then
           Facteur#{Mix P2T Music}|{MusicToList T P2T}
        end
      end
   end

   fun {Merge MusicsList}
     local
       fun {Merge2 MusicsList L}
         case MusicsList
         of nil then L
         [] H|T then
           case H
           of Facteur#List then
             {Merge2 T {Sum L {Mult Facteur List}}}
           end
         end
       end
     in
       {Clip ~1.0 1.0 {Merge2 MusicsList nil}}
     end
   end

   fun {Sum List1 List2}
     local
       fun {Sum2 L1 L2}
         case L1
         of nil then L2
         [] H|T then
           L1.1+L2.1|{Sum2 L1.2 L2.2}
         end
       end
     in
       if {List.length List1}<{List.length List2} then {Sum2 List1 List2}
       else {Sum2 List2 List1}
       end
     end
   end

   fun {Mult Facteur L}
     case L
     of nil then nil
     [] H|T then
       H*Facteur|{Mult Facteur T}
     end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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
  {Merge [1.0#Music Decay#{Append {L {Float.toInt Delay*44100.0}} Music}]}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {Fade Start Out Music}
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
      {Flatten [{FadeIn Start Music 0} {Cut Start Out Music} {FadeOut Out L {Float.toInt 44100.0*Out-1.0}}]}
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


   Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}

   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   %{Browse {Mix PartitionToTimedList Music}}


   % Shows the total time to run your code.
   %{Browse {IntToFloat {Time}-Start} / 1000.0}
end
