Extra  = require("extra")
Match  = require("match")
Vardef = require("vardef")
Cmd    = require("cmd")

-- Inspeciona estrutura de dados
ins = require("inspect")

func = {}

-- Lê header da função. Retorna nome e lista de argumentos. Se lista de argumentos for vazia
-- retorna nil.
local function read_header(line)
  local name, args = string.match(line, match.header)
  if args == "" then args = nil end -- Casamento vazio retorna ""

  -- a,b,c -> [a,b,c]
  local argsv = nil
  if args then
    argsv = Extra.args_split(args)
  end

  return name, argsv
end

-- Lê lista de variáveis da função. Caso não houver, retorna nil.
local function read_vars(readline)
  local vars = {}
  -- Inclui variável padrão ret
  table.insert(vars, Vardef.new("ret")) -- TODO: VERIFICAR SE ALGUMA VARIÁVEL ABAIXO É IGUAL A RET!!!!!

  local line = readline()

  -- Não há variáveis
  if line == "begin" then return vars end

  -- Lê variáveis
  while line ~= "begin" do
    local var = string.match(line, Match.var)
    local varname, varsize = string.match(var, Match.varv)

    if varname then             -- Se for um vetor
      table.insert(vars, Vardef.new(varname, varsize))
    else                        -- Se for uma variável
      table.insert(vars, Vardef.new(var))
    end

    line = readline()
  end

  return vars
end

-- Lê lista de comandos no corpo da função. Retorna nil se vazio
local function read_body(readline)
  cmds = {}

  local cmd = Cmd.read(readline)
  while cmd ~= nil do
    table.insert(cmds, cmd)
    cmd = Cmd.read(readline)
  end

  return cmds
end

-- Lê uma função. Caso não tenha mais funções para ler retorna nil
function func.read(readline)
  local line = readline()

  -- Fim do arquivo ou espaço em branco
  if line == "" or line == nil then return line end

  -- Função é constituida de 4 partes: nome, argumentos, variáveis e comandos.
  -- Lê header da função (nome e lista de argumentos)
  local NAME, ARGS = read_header(line)

  -- Lê lista de variáveis. Sempre haverá a veriável de retorno padrão ret.
  local VARS = read_vars(readline)

  -- Lê lista de comands. Caso seja vazio retorna nil.
  local CMDS = read_body(readline)

  return NAME, {TYPE = "FUNCTION", ARGS = ARGS, VARS = VARS, CMDS = CMDS}
end

return func
