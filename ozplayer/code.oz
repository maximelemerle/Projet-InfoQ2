local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   % Recois une note en argument
   % Transforme une note en note etendue

   fun {NoteToExtended Note}
      case Note
      of note(duration:D instrument:I name:N octave:O sharp:S) then
         note(name:N octave:O sharp:S duration:D instrument:I)
      [] silence(duration:D) then
         silence(duration:D)
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
         [] [N O A] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O A]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Recois un accord en argument
   % Transforme un accord en accord etendu

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

   % Recois une partition et une duree en argument
   % Fixe la durée de la partition en adaptant la duree de chaque note

   fun {Duration P S}
     local
       fun {DRatio P S Acc}  % Trouve le ratio necessaire pour executer la fonction stretch
         case P
         of nil then {Float.'/' S Acc}
         [] H|T then
            case H
            of H1|T1 then {DRatio T S Acc+H1.duration}%peut etre {DRatio T S Acc+{DRatio H S Acc}}
            else {DRatio T S Acc+H.duration}
            end
         end
       end
     in
      {Stretch P {DRatio P S 0.0}}  % Utilise la fonction stretch pour changer la duree des notes
     end
  end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Recois une partition et un facteur en argument
   % Etire la duree de la partition par le facteur indique

   fun {Stretch Partition Facteur}
       case Partition
       of nil then nil
       [] H|T then
          case H
          of H1|T1 then
             {Stretch {PartitionToTimedList H} Facteur}|{Stretch T Facteur}
          [] silence(duration:D) then
             silence(duration:D*Facteur)|{Stretch T Facteur}
         else
             note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Facteur instrument:H.instrument)|{Stretch T Facteur}
         end
       end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Recois un(e) note/accord ainsi qu un entier en argument
   % Repete une note/accord identique autant de fois qu indique par l entier

   fun {Drone NoteOrChord Amount}
     if Amount<1 then nil
     else
      NoteOrChord|{Drone NoteOrChord Amount-1}
     end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Recois une note en argument
   % Se base sur le tableau des notes: https://en.wikipedia.org/wiki/Scientific_pitch_notation
   % Retourne la ligne en fonction de la note

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

   % Recois une octave en argument
   % Retourne la colonne en fonction de la note
   fun {GetColumn Octave}
     Octave+1
   end

   % Recois un entier et une partition en argument
   % Retrouve le numero en fonction de la note, ajoute l entier et retrouve la note en fonction du numero
   fun {Transpose Integer Partition}
     local
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

       % Recois le numero de la note en argument
       % Retrouve l octave en fonction de ce numero
       fun {GetOctave Number}
          Number div 12 -1
       end

       % Recois un entier et une partition en argument
       % apelle les autres fonctions et additionne le numero de la note avec l entier
       fun {Transpose2 Integer Partition}
         case Partition
         of nil then nil
         [] H|T then
            case H
            of nil then nil
            [] H1|T1 then
                {PartitionToTimedList [transpose(semitones:Integer H)]}|{Transpose2 Integer T}
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
       {Transpose2 Integer Partition}
     end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Recois une partition en argument
   % Parcours la partition et apelle NoteToExtendedNote
   fun {PartitionToTimedList Partition}
     case Partition
     of nil then nil
     [] H|T then
       case H
       of nil then nil
       [] H1|T1 then
          {PartitionToTimedList H}|{PartitionToTimedList T}
       [] duration(seconds:S L) then
          {Append {Duration {PartitionToTimedList L} S} {PartitionToTimedList T}}
       [] stretch(factor:F L) then
          {Append {Stretch {PartitionToTimedList L} F} {PartitionToTimedList T}}
       [] drone(amount:A note:N) then
          {Append {Drone {PartitionToTimedList N} A} {PartitionToTimedList T}}
       [] transpose(semitones:S L) then
          {Append {Transpose S {PartitionToTimedList L}} {PartitionToTimedList T}}
       else
          {NoteToExtended H}|{PartitionToTimedList T}
       end
      else
          {NoteToExtended Partition}
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

   % Recois une musique et une fonction qui satisfait la spécification de PartitionToTimedList en argument
   % Retourne une liste d echantillons
   fun {Mix P2T Music}
      local
        fun {Mix2 P2T Music}
          case Music
          of nil then nil
          [] H|T then
            case H
            of samples(Samples) then Samples|{Mix2 P2T T}
            [] partition(Partition) then {Echantillon {P2T Partition}}|{Mix2 P2T T}
            [] wave(File) then {Project.load File}|{Mix2 P2T T}
            [] merge(MusicsList) then {Merge {MusicToList MusicsList P2T}}|{Mix2 P2T T}
            else {Filtre P2T Music}|{Mix2 P2T T}
            end
          [] samples(Samples) then Samples
          [] partition(Partition) then {Echantillon {P2T Partition}}
          [] wave(File) then {Project.load File}
          [] merge(MusicsList) then {Merge {MusicToList MusicsList P2T}}
          else {Filtre P2T Music}
          end
        end
      in
        {Clip ~1.0 1.0 {Flatten {Mix2 P2T Music}}}
      end
      %{Project.readFile 'wave/animaux/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Idem Mix...
   % Apelle une des fonction filtre     !!! Les arguments des filtres sont des musiques deja echantilonnee !!!
   fun {Filtre P2T Music}
      case Music
      of nil then nil
      [] H|T then
        case H
        of reverse(Music) then                 {Reverse {Mix P2T Music}}|{Mix P2T T}
        [] repeat(amount:Integer Music) then   {Repeat Integer {Mix P2T Music}}|{Mix P2T T}
        [] loop(duration:Duration Music) then  {Loop Duration {Mix P2T Music}}|{Mix P2T T}
        [] clip(low:Low high:High Music) then  {Clip Low High {Mix P2T Music}}|{Mix P2T T}
        [] echo(delay:Delay decay:Decay Music) then {Echo Delay Decay {Mix P2T Music}}|{Mix P2T T}
        [] fade(start:Start out:Out Music) then   {Fade Start Out {Mix P2T Music}}|{Mix P2T T}
        [] cut(start:Start finish:End Music) then {Cut Start End {Mix P2T Music}}|{Mix P2T T}
        end
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

   % Prend une partition composee uniquement de note etendue en argument
   % Renvoie la liste d echantillon correspondant a la partition
   fun {Echantillon Partition}
       local
         fun {HauteurPow Note}   % trouve la hauteur de la note
             case Note
             of silence(duration:D) then
                0.0
             else
                {Pow 2.0 {Int.toFloat {GetRow Note}+{GetColumn Note.octave}*12-69}/12.0}
             end
         end
         fun {Echantillon2 Note Constant I} % Parcours la partition  Constant = 2^h/12 * Note.duration * 2pi * f / 44100  !!!!!!!!!!!!!!!OPTI!!!!!!!!!!!!!!!!
           if {Int.toFloat I}=<44100.0*Note.duration then
             local
                  X = Constant*{Int.toFloat I}
               in
                  {Float.sin X}/2.0|{Echantillon2 Note Constant I+1}
             end
           else nil
           end
         end
       in
         case Partition
         of nil then nil
         [] H|T then
            case H
            of H1|T1 then
              {Merge {ListToListWithIntensitiesOne {Echantillon H}}}|{Echantillon T}
            else
              {Echantillon2 H {HauteurPow H}*H.duration*0.06268937721 1}|{Echantillon T}
            end
         end
       end
   end

   fun {ListToListWithIntensitiesOne L}   % MASKIM TU DIRRAS A QUOI SERT CETRTE MERDE TOI MEME
     case L
     of nil then nil
     [] H|T then
       1.0#H|{ListToListWithIntensitiesOne T}
     end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Recois une liste de tuples composes d'un facteur et d'une musique
   % Retourne une liste de tuples composes d'un facteur et d'une liste de samples
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
       {Merge2 MusicsList nil}
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

% Recois une musique en argument
% Renverse la liste des echantillons
fun {Reverse Music}
  {List.reverse Music}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Recois une musique et un entier en argument
% Repete la liste le nombre de fois indique
fun {Repeat Integer Music}
  if Integer==0 then
    nil
  else
    Music|{Repeat Integer-1 Music}
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Recois une musique et une duree en argument
% Joue la musique en boucle pour le nombre de secondes indiquees
fun {Loop Duration Music}
  local
    Taille = {List.length Music}
    X Y
  in
    if Taille<{Float.toInt Duration*44100.0} then   % Si la musique dépasse la duree on calcule le nombre de fois et la duree du dernier bout a rajouter
      X = {Float.toInt Duration*44100.0} mod Taille
      Y = {Float.toInt Duration*44100.0} div Taille
      {Flatten {Repeat Y Music}|{List.take Music X}}
    else
      {List.take Music {Float.toInt Duration*44100.0}}
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Recoi une musique et un entier en argument
% Repete la liste le nombre de fois indique
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

% Recois un delai une intensite (dacay) et une musique
   % Cree un double de la musique et merge avec la musique de depart
fun {Echo Delay Decay Music}
  {Merge [1.0#Music Decay#{Append {L {Float.toInt Delay*44100.0}} Music}]}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Recois une duree d entree , de sortie et une musique
% Cree un fondu pour adoucir les transition d un morceau en faisant
% varier l intensite de 0 a 1 ou inversement sur le temps voulu
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

% Recois un temps de depart et de fin ainsi qu une musique
% Recupere une portion de musique
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
      T = Finish-Start
    in
      {List.take X {Float.toInt T*44100.0}}
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Recois une taille en argument
% Cree une liste de 0 de taille T
fun {L T}
   if T==0 then
      nil
   else
      0.0|{L T-1}
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   Music = {Project.load 'Interstellar.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}

   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   %{Browse {List.length {Mix PartitionToTimedList Music}}}
   %{Browse {PartitionToTimedList Music}}
   %{Browse {List.length {Echantillon {PartitionToTimedList [duration(seconds:5.0 [a])]}}.1}}
   %{Browse Music}




   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
