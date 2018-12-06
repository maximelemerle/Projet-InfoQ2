local
  Main1 = [
  silence(duration:0.6)
  transpose(semitones:1 [duration(seconds:0.1 [c5])]) duration(seconds:0.1 [b]) duration(seconds:0.4 [c#5]) duration(seconds:1.0 [f#4]) duration(seconds:0.1 [d5]) duration(seconds:0.1 [c#5]) duration(seconds:0.2 [d5]) duration(seconds:0.2 [c#5]) duration(seconds:1.0 [b])
  duration(seconds:0.1 [d5]) duration(seconds:0.1 [c#5]) duration(seconds:0.4 [d5]) duration(seconds:1.0 [f#4]) duration(seconds:0.1 [b]) duration(seconds:0.1 [a]) duration(seconds:0.2 [b]) duration(seconds:0.2 [a]) duration(seconds:0.2 [g#4]) duration(seconds:0.2 [b])
  duration(seconds:0.6[a]) duration(seconds:0.1 [c#5]) duration(seconds:0.1 [b]) duration(seconds:0.4 [c#5]) duration(seconds:1.0 [f#4]) duration(seconds:0.1 [d5]) duration(seconds:0.1 [c#5]) duration(seconds:0.2 [d5]) duration(seconds:0.2 [c#5]) duration(seconds:1.0 [b])
  duration(seconds:0.1 [d5]) duration(seconds:0.1 [c#5]) duration(seconds:0.4 [d5]) duration(seconds:1.0 [f#4]) duration(seconds:0.1 [b]) duration(seconds:0.1 [a]) duration(seconds:0.2 [b]) duration(seconds:0.2 [a]) duration(seconds:0.2 [g#4]) duration(seconds:0.2 [b])
  duration(seconds:0.6[a]) duration(seconds:0.1 [g#4]) duration(seconds:0.1 [a]) duration(seconds:0.6[b]) duration(seconds:0.1 [a]) duration(seconds:0.1 [b]) duration(seconds:0.2 [c#5]) duration(seconds:0.2 [b]) duration(seconds:0.2 [a]) duration(seconds:0.2 [g#4])
  duration(seconds:0.4 [f#4]) duration(seconds:0.4 [d5]) duration(seconds:1.0 [c#5])
  ]


  Main2 = [
  stretch(factor:0.1 [f#2 c#3 f#3 a3 c#4 f#4 c#4 a3 f#3 c#3 f#2 c#3 f#3 a3 c#4]) silence(duration:0.1)
  stretch(factor:0.1 [d2 a2 d3 f#3 a3 d a3 f#3 d3 a2 d2 a2 d3 f#3 a3]) silence(duration:0.1)
  stretch(factor:0.1 [b1 f#2 b2 d3 f#3 b3 f#3 d3 b2 f#2 b1 f#2 b2 d3 f#3]) silence(duration:0.1)
  stretch(factor:0.1 [e2 b2 e3 g#3 b3 e b3 g#3 e3 b2 e2 b2 e3 g#3 b3]) silence(duration:0.1)
  stretch(factor:0.1 [f#2 c#3 f#3 a3 c#4 f#4 c#4 a3 f#3 c#3 f#2 c#3 f#3 a3 c#4]) silence(duration:0.1)
  stretch(factor:0.1 [d2 a2 d3 f#3 a3 d a3 f#3 d3 a2 d2 a2 d3 f#3 a3]) silence(duration:0.1)
  stretch(factor:0.1 [b1 f#2 b2 d3 f#3 b3 f#3 d3 b2 f#2 b1 f#2 b2 d3 f#3]) silence(duration:0.1)
  stretch(factor:0.1 [e2 b2 e3 g#3 b3 e b3 g#3 e3 b2 e2 b2 e3 g#3 b3]) silence(duration:0.1)
  stretch(factor:0.1332 [f#2 c#3 f#3]) silence(duration:0.4) stretch(factor:0.1332 [g#2 e3 g#3]) silence(duration:0.4) stretch(factor:0.1 [g#3 e3 g#2 e3])
  stretch(factor:0.1 [a3 e3 g#2 e3 a3 e3]) silence(duration:0.2) stretch(factor:0.2 [d2 a2 f#3 a2])
  ]

  Vache = 'wave/animals/cow.wav'
in
  [
  crossfade(
    seconds:4.0
    [merge([
      1.0#[partition([stretch(factor:1.15 Main1)])] 1.0#[partition([stretch(factor:1.15 Main2)])]
      ]
    )]
      [merge([
        1.0#[cut(start:0.0 finish:8.0
                [reverse(
                    [merge( [ 1.0#[partition([stretch(factor:1.15 Main1)])] 1.0#[partition([stretch(factor:1.15 Main2)])] ])]
                 )]
              )]
        1.0#[
            echo(delay:1.0 decay:0.3 repeat:4 [wave(Vache)])
          ]
        ]
        )]
    )
    partition([a#8])
    lowpass([partition([a#8])])
  ]
end
