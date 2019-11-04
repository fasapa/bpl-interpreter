program = require("program")
Ins     = require("inspect")

--
-- Pega o nome do arquivo passado como parâmetro (se houver)
--

local filename = ...
if not filename then
   print("Usage: lua interpretador.lua <prog.bpl>")
   os.exit(1)
end

local file = io.open(filename, "r")
if not file then
   print(string.format("[ERRO] Cannot open file %q", filename))
   os.exit(1)
end

-- Iterador para ler linhas
readline = file:lines()

-- Um programa é uma lista de funções.
local prog = program.read(readline)
print(Ins.inspect(prog))

file:close()
