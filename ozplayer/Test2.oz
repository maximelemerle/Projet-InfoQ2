declare
fun {Mix P2T Music}
   case Music
   of nil then nil
   [] samples(Samples) then Samples
   [] partition(Partition) then {Echantillon {P2T Partition}}
   [] wave(File) then {Project.load File}
   [] merge(MusicsList) then {Merge {MusicToList MusicsList P2T}}
   else {Filtre P2T Music}
   end
   {Project.readFile 'wave/animaux/cow.wav'}
end

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


fun {Filtre P2T Music}
   case Music
   of nil then nil
   [] reverse(Music) then                 {Reverse {Mix P2T Music}}
   [] repeat(amount:Integer Music) then   {Repeat Integer {Mix P2T Music}}
   [] loop(duration:Duration Music) then  {Loop Duration {Mix P2T Music}}
   [] clip(low:Low high:High Music) then  {Clip Low High {Mix P2T Music}}
   [] echo(delay:Delay Music) then        {Echo Delay {Mix P2T Music}}
   [] fade(in:Start out:Out Music) then   {Fade Start Out {Mix P2T Music}}
   [] cut(start:Start end:End Music) then {Cut Start End {Mix P2T Music}}
   end
end
