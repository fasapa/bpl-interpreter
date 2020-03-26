vardef = {}

-- Retorna uma variável. Se size != nil retorna um vetor
function vardef.new(name, size)
  if size then

    -- Inicializa com zeros.
    local data = {}
    for i = 1, size do data[i] = 0 end

    return {TYPE = "VARDEFVEC", NAME = name, SIZE = size, DATA = data}
  else

    -- Inicializa com zero.
    return {TYPE = "VARDEF", NAME = name, DATA = 0}
  end
end

return vardef
