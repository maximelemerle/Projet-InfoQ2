declare


fun{Lissage partition samples}   %%% !!! appeler lissage et mix de partition    et rajouter parcourir la partition
  
  local
    fun{LissIn dureenote samples Acc}  % apeler avec note.duree
      case samples of nil then nil
      [] H|T then 
        if duree >= 1 then
          if Acc > 0 then
            H*(- {Pow (Acc/11025) 2} +1) | {LissIN T Acc-1}
          else nil
        else 
          if Acc > 0 then 
            H*(- {Pow (Acc/(dureenote*11025) 2} +1) | {LissIN T Acc-1}
          else
            nil
          end
        end
      end
    end

    fun{LissOut dureenote samples Acc}
      case samples of nil then nil
      [] H|T then 
        if duree >= 1 then
          if Acc > 11025 then
            H*(- {Pow (Acc/11025) 2} +1) | {LissIN T Acc+1}
          else nil
        else 
          if Acc > dureenote*11025 then 
            H*(- {Pow (Acc/(dureenote*11025) 2} +1) | {LissIN T Acc+1}
          else
            nil
          end
        end
      end
    end
  end

  in  %pas oublier take et drop dans l'appel 


