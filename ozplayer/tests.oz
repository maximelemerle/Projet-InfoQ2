PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 4 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
end

proc {Assert Cond Msg}
   TotalTests := @TotalTests + 1
   if {Not Cond} then
      {System.show Msg}
   else
      PassedTests := @PassedTests + 1
   end
end

proc {AssertListEqual Liste1 Liste2 Msg MsgFailed}
  local
    fun {AssertListEquals2 L1 L2}
      case L1
      of nil then
          if L2==nil then
            true
          end
      [] H|T then
          case H
          of H1|T1 then
              {AssertListEquals2 H L2.1}andthen{AssertListEquals2 T L2.2}
          else
              case L2
              of nil then false
              [] H2|T2 then
                  if H==H2 then
                    {AssertListEquals2 T T2}
                  else
                    {Browse H}
                    {Browse H2}
                    false
                  end
              end
          end
      end
    end
  in
    if {List.length Liste1}=={List.length Liste2} then
        if {AssertListEquals2 Liste1 Liste2} then
            {Browse Msg}
        else
          {Browse 'Liste1'}
          {Browse Liste1}
          {Browse 'Liste2'}
          {Browse Liste2}
          {Browse MsgFailed}
        end
    else
      {Browse 'Liste1'}
      {Browse Liste1}
      {Browse 'Liste2'}
      {Browse Liste2}
      {Browse MsgFailed}
    end
  end
end

proc {AssertEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A \= E then
      {System.show Msg}
      {System.show actual(A)}
      {System.show expect(E)}
   else
      PassedTests := @PassedTests + 1
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes

proc {TestNotes P2T}
    local
      X = {P2T [a#4 b c d#2 b4 [e f5 g8]]}
      Y = [note(duration:1.0 instrument:none name:a octave:4 sharp:true) note(duration:1.0 instrument:none name:b octave:4 sharp:false)
        note(duration:1.0 instrument:none name:c octave:4 sharp:false) note(duration:1.0 instrument:none name:d octave:2 sharp:true) note(duration:1.0 instrument:none name:b octave:4 sharp:false)
        [note(duration:1.0 instrument:none name:e octave:4 sharp:false) note(duration:1.0 instrument:none name:f octave:5 sharp:false) note(duration:1.0 instrument:none name:g octave:8 sharp:false)]]
    in
      {AssertListEqual X Y 'TestNotes Passed' 'TestNotes Failed'}
    end
end

proc {TestChords P2T}
   local
     X = {P2T [a#4 b [c d e5 f8] [f10 d9]]}
     Y = [note(duration:1.0 instrument:none name:a octave:4 sharp:true) note(duration:1.0 instrument:none name:b octave:4 sharp:false)
      [note(duration:1.0 instrument:none name:c octave:4 sharp:false) note(duration:1.0 instrument:none name:d octave:4 sharp:false) note(duration:1.0 instrument:none name:e octave:5 sharp:false) note(duration:1.0 instrument:none name:f octave:8 sharp:false)]
      [note(duration:1.0 instrument:none name:f octave:10 sharp:false) note(duration:1.0 instrument:none name:d octave:9 sharp:false)]]
   in
      {AssertListEqual X Y 'TestChords Passed' 'TestChords Failed'}
   end
end

proc {TestIdentity P2T}
   % test that extended notes and chord go from input to output unchanged
   local
     X = {P2T [a#4 b [c#4 d e5 f8] [f#10 d9]]}
     Y = [note(duration:1.0 instrument:none name:a octave:4 sharp:true) note(duration:1.0 instrument:none name:b octave:4 sharp:false)
     [note(duration:1.0 instrument:none name:c octave:4 sharp:true) note(duration:1.0 instrument:none name:d octave:4 sharp:false) note(duration:1.0 instrument:none name:e octave:5 sharp:false) note(duration:1.0 instrument:none name:f octave:8 sharp:false)]
     [note(duration:1.0 instrument:none name:f octave:10 sharp:true) note(duration:1.0 instrument:none name:d octave:9 sharp:false)]]
   in
      {AssertListEqual X Y 'TestIdentity Passed' 'TestIdentity Failed'}
   end
end

proc {TestDuration P2T}
  local
    X = {P2T [duration(seconds:10.0 [c d e5 f8]) duration(seconds:5.0 [f10 duration(seconds:6.0 [d9]) duration(seconds:3.0 [a7 [a b c d]])])]}
    Y = [
    note(duration:2.5 instrument:none name:c octave:4 sharp:false) note(duration:2.5 instrument:none name:d octave:4 sharp:false) note(duration:2.5 instrument:none name:e octave:5 sharp:false) note(duration:2.5 instrument:none name:f octave:8 sharp:false)
    note(duration:0.5 instrument:none name:f octave:10 sharp:false) note(duration:3.0 instrument:none name:d octave:9 sharp:false) note(duration:0.75 instrument:none name:a octave:7 sharp:false)
    [note(duration:0.75 instrument:none name:a octave:4 sharp:false) note(duration:0.75 instrument:none name:b octave:4 sharp:false) note(duration:0.75 instrument:none name:c octave:4 sharp:false) note(duration:0.75 instrument:none name:d octave:4 sharp:false)]
    ]
  in
     {AssertListEqual X Y 'TestDuration Passed' 'TestDuration Failed'}
  end
end

proc {TestStretch P2T}
  local
    X = {P2T [stretch(factor:2.5 [c d e5 f8]) stretch(factor:5.0 [f10 stretch(factor:3.0 [d9]) stretch(factor:2.0 [a7])])]}
    Y = [note(duration:2.5 instrument:none name:c octave:4 sharp:false) note(duration:2.5 instrument:none name:d octave:4 sharp:false) note(duration:2.5 instrument:none name:e octave:5 sharp:false) note(duration:2.5 instrument:none name:f octave:8 sharp:false)
     note(duration:5.0 instrument:none name:f octave:10 sharp:false) note(duration:15.0 instrument:none name:d octave:9 sharp:false) note(duration:10.0 instrument:none name:a octave:7 sharp:false)]
  in
     {AssertListEqual X Y 'TestStretch Passed' 'TestStretch Failed'}
  end
end

proc {TestDrone P2T}
  local
    X = {P2T [drone(amount:2 note:[c d e5 f8]) drone(amount:2 note:[f10 drone(amount:3 note:d9) drone(amount:2 note:[a7])])]}
    Y = [
    [note(duration:1.0 instrument:none name:c octave:4 sharp:false) note(duration:1.0 instrument:none name:d octave:4 sharp:false) note(duration:1.0 instrument:none name:e octave:5 sharp:false) note(duration:1.0 instrument:none name:f octave:8 sharp:false)]
    [note(duration:1.0 instrument:none name:c octave:4 sharp:false) note(duration:1.0 instrument:none name:d octave:4 sharp:false) note(duration:1.0 instrument:none name:e octave:5 sharp:false) note(duration:1.0 instrument:none name:f octave:8 sharp:false)]
    [note(duration:1.0 instrument:none name:f octave:10 sharp:false)
    note(duration:1.0 instrument:none name:d octave:9 sharp:false) note(duration:1.0 instrument:none name:d octave:9 sharp:false) note(duration:1.0 instrument:none name:d octave:9 sharp:false)
    [note(duration:1.0 instrument:none name:a octave:7 sharp:false)] [note(duration:1.0 instrument:none name:a octave:7 sharp:false)]]
    [note(duration:1.0 instrument:none name:f octave:10 sharp:false)
    note(duration:1.0 instrument:none name:d octave:9 sharp:false) note(duration:1.0 instrument:none name:d octave:9 sharp:false) note(duration:1.0 instrument:none name:d octave:9 sharp:false)
    [note(duration:1.0 instrument:none name:a octave:7 sharp:false)] [note(duration:1.0 instrument:none name:a octave:7 sharp:false)]]
    ]
  in
     {AssertListEqual X Y 'TestDrone Passed' 'TestDrone Failed'}
  end
end

proc {TestTranspose P2T}
   local
     X = {P2T [transpose(semitones:2 [a a#4 c [a10 g#4]])]}
     Y = [
     note(duration:1.0 instrument:none name:b octave:4 sharp:false) note(duration:1.0 instrument:none name:c octave:5 sharp:false) note(duration:1.0 instrument:none name:d octave:4 sharp:false)
     [note(duration:1.0 instrument:none name:b octave:10 sharp:false) note(duration:1.0 instrument:none name:a octave:4 sharp:true)]
     ]
   in
    {AssertListEqual X Y 'TestTranspose Passed' 'TestTranspose Failed'}
   end
end

proc {TestP2TChaining P2T}
  local
    X = {P2T [stretch(factor:2.0 [duration(seconds:5.0 [f10 duration(seconds:3.0 [transpose(semitones:10 [a8 c#5]) duration(seconds:1.0 [drone(amount:5 note:[a7 b7])])]) a#8])])]}
    Y = [
    note(duration:2.0 instrument:none name:f octave:10 sharp:false)
    note(duration:2.0 instrument:none name:g octave:9 sharp:false) note(duration:2.0 instrument:none name:b octave:5 sharp:false)
    [note(duration:0.4 instrument:none name:a octave:7 sharp:false) note(duration:0.4 instrument:none name:b octave:7 sharp:false)]
    [note(duration:0.4 instrument:none name:a octave:7 sharp:false) note(duration:0.4 instrument:none name:b octave:7 sharp:false)]
    [note(duration:0.4 instrument:none name:a octave:7 sharp:false) note(duration:0.4 instrument:none name:b octave:7 sharp:false)]
    [note(duration:0.4 instrument:none name:a octave:7 sharp:false) note(duration:0.4 instrument:none name:b octave:7 sharp:false)]
    [note(duration:0.4 instrument:none name:a octave:7 sharp:false) note(duration:0.4 instrument:none name:b octave:7 sharp:false)]
    note(duration:2.0 instrument:none name:a octave:8 sharp:true)
    ]
  in
     {AssertListEqual X Y 'TestP2TChaining Passed' 'TestP2TChaining Failed'}
  end
end

proc {TestEmptyChords P2T}
  local
    X = {P2T [ nil stretch(factor:2.5 nil) duration(seconds:10.0 nil) transpose(semitones:2 nil) drone(amount:10 nil)]}
    Y = nil
  in
   {AssertListEqual X Y 'TestEmptyChords Passed' 'TestEmptyChords Failed'}
  end
end

proc {TestP2T P2T}
   {TestNotes P2T}
   {TestChords P2T}
   {TestIdentity P2T}
   {TestDuration P2T}
   {TestStretch P2T}
   {TestDrone P2T}
   {TestTranspose P2T}
   {TestP2TChaining P2T}
   {TestEmptyChords P2T}
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix

proc {TestSamples P2T Mix}
   skip
end

proc {TestPartition P2T Mix}
   skip
end

proc {TestWave P2T Mix}
   skip
end

proc {TestMerge P2T Mix}
   skip
end

proc {TestReverse P2T Mix}
   skip
end

proc {TestRepeat P2T Mix}
   skip
end

proc {TestLoop P2T Mix}
   skip
end

proc {TestClip P2T Mix}
   skip
end

proc {TestEcho P2T Mix}
   skip
end

proc {TestFade P2T Mix}
   skip
end

proc {TestCut P2T Mix}
   skip
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
   {TestPartition P2T Mix}
   {TestWave P2T Mix}
   {TestMerge P2T Mix}
   {TestReverse P2T Mix}
   {TestRepeat P2T Mix}
   {TestLoop P2T Mix}
   {TestClip P2T Mix}
   {TestEcho P2T Mix}
   {TestFade P2T Mix}
   {TestCut P2T Mix}
   {AssertEquals {Mix P2T nil} nil 'nil music'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Test Mix P2T}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {Browse 'tests have started'}
   {TestP2T P2T}
   {Browse 'P2T tests have run'}
   %{TestMix P2T Mix}
   %{System.show 'Mix tests have run'}
   {System.show test(passed:@PassedTests total:@TotalTests)}
end
