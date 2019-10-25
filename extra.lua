-- Funções extras utilizadas pelo interpretador.

extra = {}

-- Quebra uma string 'a,b,c' em um vetor [a,b,c]
function extra.args_split(args)
  local a = {}
  for arg in string.gmatch(args, "([^,]+)") do
    table.insert(a, arg)
  end
  return a
end

return extra
