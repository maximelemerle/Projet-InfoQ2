local




  Part3 = [
  silence(duration:0.2) stretch(factor:1.2 [[d f a] [d f a#4]])
  duration(seconds:0.2[[c f a]]) silence(duration:0.2) duration(seconds:0.2 [[c f a]]) silence(duration:0.2) duration(seconds:0.2 [[c f a]]) silence(duration: 0.2) duration(seconds:0.2 [[c f a]]) duration(seconds:1.0 [[c e g]])
  stretch(factor:1.2 [[d g a#3] [a3 d f]])
  stretch(factor:0.4 [[c#4 e a3] [a3 d f] [c#4 e a3]]) duration(seconds:1 [[d a3]])
  ]

  Part3bis = [
  silence(duration:0.2) duration(seconds:0.4 [[d3 d2]]) stretch(factor:0.2 [[d3 d2] [d3 d2] [d3 d2] [d3 d2]]) duration(seconds:0.4 [[g1 g2]]) stretch(factor:0.2 [[g1 g2] [g1 g2] [g1 g2] [g1 g2]])
  duration(seconds:0.2 [[f1 f2]]) silence(duration:0.2) duration(seconds:0.2 [[f1 f2]]) silence(duration:0.2) stretch(factor:0.2 [f2 f1 [c2 c3] c2 c3 c2 [c2 c3]])
  duration(seconds:0.4 [[g1 g2]]) stretch(factor:0.2 [g1 d2 g2 a2]) duration(seconds:0.4 [[d3 d2]]) stretch(factor:0.2 [d2 a2  d3 f3 a2 f2 c#3])
  duration(seconds:0.4 [[a2 e3]]) duration(seconds:0.4 [[d3 f3]])
  ]



in
   % This is a music :)
   %[wave('wave/animals/cow.wav')]

   [
  merge( [0.3#[partition(Part3)] 0.15#[partition(Part3bis)]]  )
   ]

end
