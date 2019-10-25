-- Lê um programa
-- Um programa é formado por uma lista de funções
Func = require("func")
Ins = require("inspect")

program = {}

-- Lê funções até acabar o arquivo
function program.read(readline)
  local prog = {}                     -- Lista de funções

  while true do
    local n, f = Func.read(readline)     -- Retorna uma função
    if n ~= "" and f ~= nil then
      print(Ins.inspect(f))
      prog[n] = f         -- Lista de funções
    elseif n ~= nil then
      return prog               -- Fim do input
    else do break end end       -- Faz nada (espaço em branco)
  end
end

return program
