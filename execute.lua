local execute = {}

symbol_table = {}
symbol_definition = {}
Vard = require("vardef")

-- pega o valor do lado direito da igualdade
function getARG(arg)

  -- print(arg.TYPE)
  if arg.TYPE == "FUNCALL" then
    -- print("dsd")
    funcall(arg)
    for i = #symbol_table , 1 , -1 do
      local table = symbol_table[i]
      for tag , var in  ipairs(table) do
        if var.NAME == "ret" then
          return var.VALUE
        end
      end
    end
    return
  end

  if arg.TYPE == "NUMBER" then
    return arg.VALUE
  end

  for i = #symbol_table , 1 , -1 do
    local table = symbol_table[i]
    -- para argumentos
    for tag , var in  ipairs(table) do

      if var.NAME == arg.NAME then
        if var.TYPE == "VARDEFVEC" then
          if tonumber(var.SIZE) < arg.POS then
            print(" variavel " ..  arg.NAME .. " estorou o intervalo"  )
            os.exit()
          end
          return var.DATA[arg.POS]
        end

        return var.DATA
      end
    end
  end

  print(" variavel " ..  arg.NAME .. " fora escopo" )
  os.exit()
end

 -- pega a variavel para setar seu valor. Altera valor da variável na
 -- tabela de símbolos.
function setARG(arg , value)

  for i = #symbol_table , 1 , -1 do
    local table = symbol_table[i]
    -- verifica se variavel e uma argumento

    for tag , var in  ipairs(table) do
      if var.NAME == arg.NAME then

        if var.TYPE == "VARDEFVEC" then
          var.DATA[arg.POS] = value
          return
        end
        var.DATA = value
        return
      end
    end
  end

  print(" variavel " ..  arg.NAME .. " fora escopo" )
  os.exit()
end

-- Executa atribuições IF
function exec_attr_if(cmd)
  if cmd.TYPE == "ATTRSIMPLE" then
    exec_attr_simple(cmd)
  elseif cmd.TYPE == "ATTROP" then
    exec_attr_op(cmd)
  elseif cmd.TYPE == "IF" then
    exec_if(cmd)
  end
end

-- Executa IF
function exec_if(cmd)
  local left = getARG(cmd.CMP.LEFT)
  local right = getARG(cmd.CMP.RIGHT)

  -- Realiza comparação
  if cmd.CMP.OP == ">" then

    if left > right then
      exec_attr_if(cmd.EXP)
    elseif cmd.TYPE == "IFLESE" and cmd.EXP2 ~= nil then
      exec_attr_if(cmd.EXP2)
    end

  elseif cmd.CMP.OP == ">=" then
    if left >= right then
      exec_attr_if(cmd.EXP)
    elseif cmd.TYPE == "IFLESE" and cmd.EXP2 ~= nil then
      exec_attr_if(cmd.EXP2)
    end

  elseif cmd.CMP.OP == "<" then
    if left < right then
      exec_attr_if(cmd.EXP)
    elseif cmd.TYPE == "IFLESE" and cmd.EXP2 ~= nil then
      exec_attr_if(cmd.EXP2)
    end

  elseif cmd.CMP.OP == "<=" then
    if left <= right then
      exec_attr_if(cmd.EXP)
    elseif cmd.TYPE == "IFLESE" and cmd.EXP2 ~= nil then
      exec_attr_if(cmd.EXP2)
    end

  elseif cmd.CMP.OP == "==" then
    if left == right then
      exec_attr_if(cmd.EXP)
    elseif cmd.TYPE == "IFLESE" and cmd.EXP2 ~= nil then
      exec_attr_if(cmd.EXP2)
    end

  elseif cmd.CMP.OP == "!=" then
    if left ~= right then
      exec_attr_if(cmd.EXP)
    elseif cmd.TYPE == "IFLESE" and cmd.EXP2 ~= nil then
      exec_attr_if(cmd.EXP2)
    end
  end
end

-- Atribuição com operação binária a direita.
function exec_attr_op(cmd)

   local left = getARG(cmd.LEFT)
   local right = getARG(cmd.RIGHT)

   if cmd.OP == "+" then
     setARG(cmd.VAR,  left + right)
   elseif cmd.OP == "-" then
     setARG(cmd.VAR , left - right)
   elseif cmd.OP == "*" then
      setARG(cmd.VAR ,left * right)
   elseif cmd.OP == "/" then
      setARG(cmd.VAR, left / right)
   end
end

-- Atribui valor a variável
function exec_attr_simple(cmd)
  setARG(cmd.VAR, getARG(cmd.ARG))
end

-- Realiza chamada de função
function funcall(func)
  local func_symbol_table = {}

  -- Função especial print
  if func.NAME  == "print" then
    print(getARG(func.VALUES[1]))
    return
  end

  local paramenters     = func.VALUES
  local vars     = program[func.NAME].VARS
  local args     = program[func.NAME].ARGS

  table.insert(func_symbol_table , func.NAME)
  local n_args = 1

  if args ~= nil then
    for tag, arg in  ipairs(args) do
      local v_arg = {TYPE = "VARDEF", NAME = arg, DATA = getARG(paramenters[n_args])}
      table.insert( func_symbol_table , v_arg)
      n_args = n_args + 1
    end
  end

  if vars ~= nil then
    for tag , var in  ipairs(vars) do
      if var.NAME  == "ret" then
      else
        table.insert(func_symbol_table , var)
      end
    end
  end

  table.insert(symbol_table , func_symbol_table)
  exec_cmds(program[func.NAME].CMDS) -- Executa corpo da função
  symbol_table[#symbol_table] = nil
  return
end

-- Interpreta (executa) um comando: atribuição "simples", atribuição com op
-- binário, if ou funcall.
function exec_cmds(cmds)

  for tag, cmd in ipairs(cmds) do
    if cmd.TYPE == "ATTRSIMPLE" then
      exec_attr_simple(cmd)
    elseif cmd.TYPE == "ATTROP" then
      exec_attr_op(cmd)
    elseif cmd.TYPE == "IF" or cmd.TYPE == "IFLESE"then
      exec_if(cmd)
    elseif cmd.TYPE == "FUNCALL" then
      funcall(cmd)
    end
  end
end

-- Interpreta um programa
local function interpret(prog)
  program = prog

  main = prog["main"]
  cmds = main.CMDS
  vars = main.VARS

  main_symbol_table = {}

  table.insert(main_symbol_table , "main")
  for tag, var in ipairs(vars) do
    table.insert(main_symbol_table , var)
  end
  table.insert(symbol_table , main_symbol_table)

  exec_cmds(cmds)
end

execute.interpret = interpret
return execute
