local
   % See project statement for API details.
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   % Note : Une note a transformer                                              [<note> ou <extended note>]
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

   % Chord : Un accord a transformer                                              [<chord> ou <extended chord>]
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

   % Partition : Partition a modifier                                           [<partition>]
   % Seconds : Duree totale de la partition                                     [float]
   % Fixe la duree de la partition en adaptant la duree de chaque note
   fun {Duration Partition Seconds}
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
      {Stretch Partition {DRatio Partition Seconds 0.0}}  % Utilise la fonction stretch pour changer la duree des notes
     end
  end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Partition : Partition a modifier                                           [<partition>]
   % Facteur : Facteur qui modifie la duree de chaque note                      [float]
   % Etire la duree de la partition par le facteur indique
   fun {Stretch Partition Facteur}
       case Partition
       of nil then nil
       [] H|T then
          case H
          of H1|T1 then
             {Stretch H Facteur}|{Stretch T Facteur}
          [] silence(duration:D) then
             silence(duration:D*Facteur)|{Stretch T Facteur}
         else
             note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration*Facteur instrument:H.instrument)|{Stretch T Facteur}
         end
       end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % NoteOrChord : Note ou accord a repeter                                     [<extended note> ou <extended chord>]
   % Amount : Nbre de repetition totale (0 retourne nil)                        [Integer]
   % Repete une note/accord identique autant de fois qu'indique par l entier
   fun {Drone NoteOrChord Amount}
     if Amount<1 then nil
     else
      NoteOrChord|{Drone NoteOrChord Amount-1}
     end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Note : Une note donnee                                                     [<extended note>]
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

   % Octave : Octave d'une note                                                 [Integer [~1 10]]
   % Retourne la colonne en fonction de la note
   fun {GetColumn Octave}
     Octave+1
   end

   % Integer : Nbre de demi-tons                                                [Integer]
   % Partition : Partition a modifier                                           [<partition>]
   % Retourne la partition transpose d'un d'un certains nombre de demi-tons
   % Retrouve le numero en fonction de la note, ajoute l entier et retrouve la note en fonction du numero
   fun {Transpose Integer Partition}
     local
       % Number : Numero correspond a la note                                   [Integer]
       % Retourne la note en fonctiondu numero de la note, cf tableau
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

       % Number : Numero correspond a la note                                   [Integer]
       % Retourne l'octave en fonction du numero de la note, cf tableau
       fun {GetOctave Number}
          Number div 12 -1
       end

       % Integer : Nbre de demi-tons                                            [Integer]
       % Partition : Partition a modifier                                       [<partition>]
       % Parcours la partition, pour chaque note, la transforme en chiffre, y additionne le nbres de demi-tons.
       % Retourne une liste composee de toute les notes et accords resultant de la transformation
       fun {Transpose2 Integer Partition}
         case Partition
         of nil then nil
         [] H|T then
            case H
            of nil then nil
            [] H1|T1 then
                {PartitionToTimedList [transpose(semitones:Integer {PartitionToTimedList H})]}|{Transpose2 Integer T}
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

   % Partition : Partition a etendre                                            [<partition>]
   % Parcours la partition, etend les notes ainsi que applique les differantes transformations
   % Retourne une liste de note et accord etendu
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
       [] instrument(name:Name P) then
          {Append {Instrument Name {PartitionToTimedList P}} {PartitionToTimedList T}}
       else
          {NoteToExtended H}|{PartitionToTimedList T}
       end
      else
          {NoteToExtended Partition}
     end
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Mix   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % P2T : Fonction PartitionToTimedList utilie lors de l'echantillonage
   % Music : Liste de <part> a transformer                                      [<music>]
   % Retourne une liste de samples
   fun {Mix P2T Music}
      local
        % P2T : Fonction PartitionToTimedList utilie lors de l'echantillonage
        % Music : Liste de <part> a transformer                                 [<music>]
        % Lissage : Variable gerant le lissage des samples                      [boolean] (Extension)
        fun {Mix2 P2T Music Lissage Extension}
          case Music
          of nil then nil
          [] H|T then
            case H
            of samples(Samples) then Samples|{Mix2 P2T T Lissage Extension}
            [] partition(Partition) then {Echantillon {P2T Partition} Lissage}|{Mix2 P2T T Lissage Extension}
            [] wave(File) then {Project.readFile File}|{Mix2 P2T T Lissage Extension}
            [] merge(MusicsList) then {Merge {MusicToList MusicsList P2T}}|{Mix2 P2T T Lissage Extension}
            [] reverse(Music) then {Reverse {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            [] repeat(amount:Integer Music) then {Repeat Integer {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            [] loop(duration:Duration Music) then {Loop Duration {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            [] clip(low:Low high:High Music) then {Clip Low High {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            [] echo(delay:Delay decay:Decay Music) then {Echo Delay Decay {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            [] fade(start:Start out:Out Music) then {Fade Start Out {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            [] cut(start:Start finish:End Music) then {Cut Start End {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
            else
              if Extension then
                case H
                of echo(delay:Delay decay:Decay repeat:Repeat Music) then {MultipleEcho Delay Decay Repeat {Mix P2T Music}}|{Mix2 P2T T Lissage Extension}
                [] crossfade(seconds:Seconds Music1 Music2) then {Crossfade Seconds {Mix P2T Music1} {Mix P2T Music2}}|{Mix2 P2T T Lissage Extension}
                else nil
                end
              else
                nil
              end
            end
          else nil
          end
        end
      in
        {Clip ~1.0 1.0 {Flatten {Mix2 P2T Music true false}}}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Partition : Partition a echantilloner                                      [<partition>]
   % ExtensionLissage : Variable gerant le lissage des samples                  [boolean] (Extension)
   % Renvoie la liste d echantillon correspondant a la partition
   fun {Echantillon Partition ExtensionLissage}
       local
         % Note : Note a examiner                                               [<extended note>]
         % Retourne 2^Hauteur/12
         fun {HauteurPow Note}
            {Pow 2.0 {Int.toFloat {GetRow Note}+{GetColumn Note.octave}*12-69}/12.0}
         end
         % Note : Note a examiner                                               [<extended note>]
         % Constant : Constante liee a chaque note                              [float]
         %            correspond a 2pi * f / 44100
         % Retourne la liste des samples de Note
         fun {Echantillon2 Note Constant I} % Parcours la partition
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
              if ExtensionLissage then
                {Lissage H1 {Merge {ListToListWithIntensities 1.0/{Int.toFloat {List.length H}} {Echantillon H ExtensionLissage}}}}|{Echantillon T ExtensionLissage}
              else
                {Merge {ListToListWithIntensities 1.0/{Int.toFloat {List.length H}} {Echantillon H ExtensionLissage}}}|{Echantillon T ExtensionLissage}
              end
            [] silence(duration:D) then
                {ListeNulle {Float.toInt D*44100.0}}|{Echantillon T ExtensionLissage}
            else
              case H.instrument
              of none then
                  if ExtensionLissage then
                     {Lissage H {Echantillon2 H {HauteurPow H}*0.06268937721 1}}|{Echantillon T ExtensionLissage}
                  else
                     {Echantillon2 H {HauteurPow H}*0.06268937721 1}|{Echantillon T ExtensionLissage}
                  end
              else
                nil
              end
            end
         end
       end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % MusicsList : Liste de tuples composes d'un facteur et de <music>           <musics with intenities>
   % P2T : Fonction PartitionToTimedList utilie lors de l'echantillonage        [fonction]
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

   % Facteur : Intensite de chaque element de <musics with intenities>          [float]
   % L : Liste de samples                                                       [<samples>]
   % Retourne une liste de tuples composes d'un facteur et d'une liste de samples
   fun {ListToListWithIntensities Facteur L}
     case L
     of nil then nil
     [] H|T then
       Facteur#H|{ListToListWithIntensities Facteur T}
     end
   end

   % MusicsList : Liste de tuples composes d'un facteur et de <music>           <musics with intenities>
   % Retourne la somme des listes de samples multiplie par le facteur
   fun {Merge MusicsList}
     local
       % MusicsList : Liste de tuples composes d'un facteur et de <music>         <musics with intenities>
       % L : Accumulateur contenant la somme des listes deja effectuee          [<samples>]
       fun {Merge2 MusicsList L}
         case MusicsList
         of nil then L
         [] H|T then
           case H
           of Facteur#List then
             {Merge2 T {SumMult L List Facteur}}
           end
         end
       end
     in
       {Merge2 MusicsList nil}
     end
   end

   % List1 : Liste de samples                                                   [<samples>]
   % List2 : Liste de samples                                                   [<samples>]
   % Retourne la somme des deux listes avec la seconde multiplie par Facteur,
   % si l'une est plus petite que considere les elements manquants comme des O
   fun {SumMult L1 L2 Facteur}
     case L1
     of nil then {Map L2 fun {$ A} Facteur*A end}
     [] H|T then
       case L2
       of nil then L1
       [] H|T then
          L1.1+Facteur*L2.1|{SumMult L1.2 L2.2 Facteur}
       end
     end
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Music : Liste de samples                                                      [<samples>]
% Renverse la liste des echantillons
fun {Reverse Music}
  {List.reverse Music}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Integer : Nbre de fois que Music doit etre repeter                            [Integer]
% Music : Liste de samples                                                      [<samples>]
% Repete la liste le nombre de fois indique
fun {Repeat Integer Music}
  if Integer==0 then
    nil
  else
    Music|{Repeat Integer-1 Music}
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Duration : Nbre de secondes que Music doit etre joue                          [float]
% Music : Liste de samples                                                      [<samples>]
% Repete la liste pour une certaine et tronque si necessaire
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

% Low : Limite basse pour les samples                                           [float]
% High : Limite haute pour les samples                                          [float]
% Music : Liste de samples                                                      [<samples>]
% Retourne Music en modifiant pour que tout soit compris entre Low et High
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

% Delay : Delay en seconde pour l'echo                                          [float]
% Decay : Facteur diminuant en intensite l'echo                                 [float]
% Music : Liste de samples                                                      [<samples>]
% Retourne la liste de samples avec un echo
fun {Echo Delay Decay Music}
  {Merge [1.0#Music Decay#{Append {ListeNulle {Float.toInt Delay*44100.0}} Music}]}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start : Nbre de seconde du fade a l'entree                                    [float]
% Out :  Nbre de seconde du fade a la sortie                                    [float]
% Music : Liste de samples                                                      [<samples>]
% Cree un fondu pour adoucir les samples
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
      {Flatten [{FadeIn Start Music 0} {Cut Start {Int.toFloat {List.length Music}}/44100.0-Out Music} {FadeOut Out L {Float.toInt 44100.0*Out-1.0}}]}
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start : Nbre de seconde du a ne pas inclure du debut                          [float]
% Finish : Nbre de seconde du a ne pas inclure de la fin                        [float]
% Music : Liste de samples                                                      [<samples>]
% Coupe Music au temps de debut et de fin desire
fun {Cut Start Finish Music}
  if Finish>{Int.toFloat {List.length Music}}/44100.0 then
    local
       L = {List.drop Music {Float.toInt Start*44100.0}}
       Length = 44100.0*(Finish-Start)-{Int.toFloat {List.length L}}
    in
      {Flatten [L {ListeNulle {Float.toInt Length}}]}
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

% T :  Taille da la liste                                                       [Integer]
% Cree une liste de 0 de taille T
fun {ListeNulle T}
   if T==0 then
      nil
   else
      0.0|{ListeNulle T-1}
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Extension%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note : Note a lisser                                                          [<extended note>]
% Music : Liste de samples correspondant a Note                                 [<samples>]
% Retourne Music en Lissant les samples grace a la fonction -x*x +1 de [-1 1]
fun{Lissage Note Samples}
    local
      Length = {Min 8820.0 0.2*Note.duration*44100.0}                           % Nbre de samples a lisser en debut
      OutLength = Note.duration*44100.0-Length                                  % Nbre de samples avant de lisser la fin
      FrontSection = {List.take Samples {Float.toInt Length}}
      MidSection = {List.drop {List.take Samples {Float.toInt OutLength}} {Float.toInt Length}}
      EndSection = {List.drop Samples {Float.toInt OutLength}}
    in
      {Flatten {LissIn Length FrontSection}|MidSection|{LissOut Length EndSection}}
    end
end

% Length : Nbre de samples a lisser en debut                              [Integer]
% Samples : Liste de samples                                              [<samples>]
% Retourne Samples lisser en utilisant la fonction -x*x + 1
% et le changement de variable de [-1 0] a [-Length 0]
fun {LissIn Length Samples}
  local
    LengthSquared = Length*Length
    fun{LissIn2 Samples LengthSquared Acc}
      case Samples
      of nil then nil
      [] H|T then
          if Acc=<0 then
            H*(~{Int.toFloat Acc*Acc}/LengthSquared + 1.0)|{LissIn2 T LengthSquared Acc+1}
          else nil
          end
      end
    end
  in
    {LissIn2 Samples LengthSquared {Float.toInt ~Length}}
  end
end

% Length : Nbre de samples a lisser en debut                              [Integer]
% Samples : Liste de samples                                              [<samples>]
% Retourne Samples lisser en utilisant la fonction -x*x + 1
% et le changement de variable de [0 Length] a [0 Length]
fun {LissOut Length Samples}
  local
    LengthSquared = Length*Length
    fun{LissOut2 Length Samples LengthSquared Acc}
      case Samples
      of nil then nil
      [] H|T then
          if Acc=<Length then
            H*(~{Int.toFloat Acc*Acc}/LengthSquared + 1.0)|{LissOut2 Length T LengthSquared Acc+1}
          else nil
          end
      end
    end
  in
    {LissOut2 {Float.toInt Length} Samples LengthSquared 0}
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delay : Delai en sec necessaire entre chaque              [float]
% Decay : Facteur diminuant l'intensite entre chaque echo   [float]
% Repeat : Nbre de repetition de l'echo                     [Integer]
% Music : List de Samples                                   [<samples>]
% Echo Multiple avec intensite decroissante
fun {MultipleEcho Delay Decay Repeat Music}
  local
    fun {Echo2 Delay Decay Repeat Music L Acc}
      if Repeat<1 then
        {Merge L.2}
      else
        {Echo2 Delay Decay Repeat-1 Music L|{Pow Decay Acc}#{Append {ListeNulle {Float.toInt Delay*Acc*44100.0}} Music} Acc+1}
      end
    end
  in
    {Echo2 Delay Decay Repeat Music nil 1}
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Samples : List de Samples                                  [<samples>]
% Filtre Passe-Bas
% Facteur calcule avec Matlab pour un filtre d'ordre 5
% et une frequence de coupure de 5000Hz
fun{LowPass Samples a b c d e f} %{LowPass Samples 0 0 0 0 0 0}
  case Samples of nil
  then nil
  [] H|T then
    {LowPass2 H b c d e f}|{LowPass T a H b c d e}
  end
end

fun{LowPass2 a b c d e f}
  a*0.1169 + b*0.1746 + c*0.2084 + d*0.2084 + e*0.1746 + f*0.1169
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Seconds : Nbre de seconde du fade a l'entree                                  [float]
% Music1 : List de Samples                                                      [<samples>]
% Music2 : List de Samples                                                      [<samples>]
% Applique un fade de sortie a Music1 et d'entree a Music2 puis les supperpose
fun{Crossfade Seconds Music1 Music2}
  {Cut Music1 0 ({List.length Music1}/44100.0)-Seconds}|{Merge
    [
    1.0#[samples({Fade 0 Seconds {List.drop {List.length Music1}-{Float.toInt Seconds*44100.0}}})]
    1.0#[samples({Fade Seconds 0 {List.take Music2 {Float.toInt Seconds*44100.0}}})]
    ]
  }|{List.drop Music2 Seconds*44100.0}
end

% Name : Nom de l'Intstrument
% Partition : Partition a modifier, deja etendue                                [<partition>]
% Change l'instrument de toute les notes n'ayant pas d'instrument
fun {Instrument Name Partition}
  case Partition
  of nil then nil
  [] H|T then
      case H
      of nil then nil
      [] H1|T1 then {Instrument Name {PartitionToTimedList H}}|{Instrument Name T}
      else case H.instrument
           of none then note(name:H.name octave:H.octave sharp:H.sharp duration:H.duration instrument:Name)|{Instrument Name T}
           else H|{Instrument Name T}
           end
      end
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   Music = {Project.load 'PiratV4T.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   %\insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   {Property.put print print(width:1000)}
   {Property.put print print(depth:1000)}
   % Uncomment next line to run your tests.
   %{Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   %{ForAll [NoteToExtended Music] Wait}

   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'Test.wav'}}
   %{Browse {List.length {Mix PartitionToTimedList Music}}}
   %{Browse {PartitionToTimedList [instrument(name:piano [a instrument(name:guitar [[note(duration:1.0 instrument:none name:a octave:4 sharp:false) note(duration:2.0 instrument:none name:b octave:5 sharp:false)]])])]}}
   %{Browse {List.length {Echantillon {PartitionToTimedList [duration(seconds:5.0 [a])]}}.1}}
   %{Browse Music}




   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
