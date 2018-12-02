local
  X = 100.0
  Half = 50.0/X
  Quarter = Half/2.0
  Quaver = Quarter/2.0
  SemiQuaver = Quaver/2.0
  Parte = [
  drone(amount:30 note:[duration(seconds:Quarter [e]) silence(duration:Quarter*3.0)])
  ]
  Parta = [
  duration(seconds:6.0 [silence]) duration(seconds:2.0 [a]) duration(seconds:4.0 [b])
  duration(seconds:Quarter*3.0 [a g c]) duration(seconds:Quarter*3.0 [g a b]) duration(seconds:Quarter*3.0 [c]) duration(seconds:Half*3.0 [b]) duration(seconds:Half*3.0 [b]) duration(seconds:Half [a]) duration(seconds:Quarter [e])
  ]
in
  [merge([1.0#partition(Parte) 1.0#partition(Parta)])]
end
