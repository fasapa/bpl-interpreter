Match = require("match")

values = {}

-- Lê um valor e retorna sua representação apropriada
function values.read(value)
  -- Acesso ao vetor?
  local vector, pos = string.match(value, Match.vector)
  if vector and pos then
    return {TYPE = "VECTOR", NAME = vector, POS = tonumber(pos)}
  end

  -- É um número inteiro?
  local number = string.match(value, Match.number)
  if number then
    return {TYPE = "NUMBER", VALUE = tonumber(number)}
  end

  -- Variável?
  local var = string.match(value, "(%l+)")
  if var then
    return {TYPE = "VAR", NAME = var}
  end

end

return values
