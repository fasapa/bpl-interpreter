-- Lê um programa
-- Um programa é formado por uma lista de funções
Func = require("func")

program = {}

-- Lê funções até acabar o arquivo
function program.read(readline)
  local prog = {}                     -- Lista de funções

  while true do
    local n, f = Func.read(readline)     -- Retorna uma função
    if f ~= nil then                     -- Encontrou uma função
      prog[n] = f
    elseif n == nil and f == nil then    -- Fim do input
      return prog
    end
  end
end

return program
