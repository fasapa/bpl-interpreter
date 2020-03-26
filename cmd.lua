Match  = require("match")
Values = require("values")
Extra  = require("extra")

cmd = {}

-- Lê uma chamda de função. Retorna nome e lista de argumentos. Se não for funcall retorna nil.
function cmd.funcall(name, values)

  if values == "" then
    return {TYPE = "FUNCALL", NAME = name, VALUES = nil}
  end

  -- Lê os valores
  local v = {}
  for k, val in ipairs(Extra.args_split(values)) do
    table.insert(v, Values.read(val))
  end

  return {TYPE = "FUNCALL", NAME = name, VALUES = v}
end

-- Lê uma atribuição. Ocupam apenas uma linha.
local function attrsimples(var, arg)
  -- var e arg tem estruturas parecidas. Entretanto var não aceita números. Mas supondo que os programas
  -- nunca teram erros gramaticais podemos utilizar Values.read para ler var também, pois var nunca
  -- será um número.


  -- Arg pode ser um valor ou funcall
  local fname, fvalues = string.match(arg, Match.funcall)
  if fname ~= nil then
    return {TYPE = "ATTRSIMPLE", VAR = Values.read(var), ARG = cmd.funcall(fname, fvalues)}
  else
    return {TYPE = "ATTRSIMPLE", VAR = Values.read(var), ARG = Values.read(arg)}
  end
end

local function attrop(var, argleft, op, argright)
  -- var e arg tem estruturas parecidas. Entretanto var não aceita números. Mas supondo que os programas
  -- nunca teram erros gramaticais podemos utilizar Values.read para ler var também, pois var nunca
  -- será um número.
  return {TYPE = "ATTROP", VAR = Values.read(var),
          LEFT = Values.read(argleft), OP = op, RIGHT = Values.read(argright)}
end

-- Retorna Atribuição correta. Se não for atribuição retorna nil
function cmd.attr(line)
  -- Attr Op? (a = b <op> c)
  local var, argleft, op, argright = string.match(line, Match.attrop)
  if var then   -- É uma atribuição Op
    return attrop(var, argleft, op, argright)
  end

  -- Attr Simples? (a = b)
  local var, arg = string.match(line, Match.attr)
  if var then
    return attrsimples(var, arg)
  end

  return nil
end

local function cmpread(line)
  local left, cmp, right = string.match(line, "(.+) (.+) (.+)") -- Três coisas separado por espaço
  return {TYPE = "CMP", LEFT = Values.read(left), RIGHT = Values.read(right), OP = cmp}
end

-- Lê IF. Como ocupa mais e uma linha é necessário passar a função readline para consumir as linhas restantes
function cmd.se(compare, readline)
  local line = readline()       -- Lê attr IF
  local cmp = cmpread(compare)

  -- Expressão corpo IF
  local EXP1 = cmd.attr(line)

  -- Else?
  line = readline()
  if string.match(line, Match.senao) then

    -- Lê segunda expressão IF
    line = readline()
    local EXP2 = cmd.attr(line)

    -- Lê fi
    line = readline()
    return {TYPE = "IFLESE", CMP = cmp, EXP1 = EXP1, EXP2 = EXP2}
  end

  -- IF simples, le fi
  line = readline()
  return {TYPE = "IF", CMP = cmp, EXP = EXP1}
end

-- Lê um comando. Um comando pode ser um attr (atribuição), if (decisão) ou funcall (chamada).
-- Retorna nil se encontrar o fim da função (end).
function cmd.read(readline)
  local line = readline()
  if line == "end" then return nil end

  -- If?
  local cmp = string.match(line, Match.se)
  if cmp then
    return cmd.se(cmp, readline) -- Termina de ler o IF
  end

  -- Attr?
  local attr = cmd.attr(line)
  if attr then                  -- É uma attr
    return attr
  end

  -- Funcall?
  local fname, fvalues = string.match(line, Match.funcall)
  if fname then                  -- É uma funcall
    return cmd.funcall(fname, fvalues)
  end
end

return cmd
