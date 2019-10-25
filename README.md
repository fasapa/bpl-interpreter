# Implementação

O interpretador lê o input, linha por linha, e gera uma representação intermediária, formada por
tabelas do Lua. 

## Programa
Um programa (`program.lua`) é definido como uma lista de funções. O arquivo "main"
(`interpretador.lua`) invoca a função `program.read` que lê o input até encontrar fim do arquivo.
A função retorna uma lista de funções indexadas pelo nome da função, ou seja em:
```
prog = program.read(readline)
main = prog["main"]
```
temos a função main na variável `main`.

## Função
Toda função (`func.lua`) contem: nome, lista de argumentos (`ARGS`), lista de variáveis (`VARS`) e 
lista de comandos (`CMDS`). A função `read_header` obtem o nome e argumentos, `read_vars` retorna 
as variáveis e `read_body` a lista de comandos. Com a seguinte representação interna: 
```
function = {TYPE = "FUNCTION", ARGS = ARGS, VARS = VARS, CMDS = CMDS}
```

## Vardef
Vardef (`vardef.lua`) são variáveis locais da função. São obtidas pela função `read_vars`, 
ela lê variáveis até encontrar a keyword "begin". Toda função
contem no mínimo uma variável por padrão: `ret`. A representação interna (`vardef.new`) depende do 
tipo de variável. Variáveis simples:
```
{TYPE = "VARDEF", NAME = name, DATA = 0}
```
Variáveis vetores (em que `data` é um vetor de tamanho `size`):
```
{TYPE = "VARDEFVEC", NAME = name, SIZE = size, DATA = data}
```
Todas as variáveis são inicializadas com zero.

## Comandos
Comandos (`cmd.lua`) possuem três formatos: atribuições, controle de fluxo (ifelse) e chmada de 
função (funcall). A função `read_body` consome o input, lendo comandos (`cmd.read`) até encontrar a 
keyword "end", indicando o fim da função. Para diferenciar entre as três representações a função
`cmd.read` tenta casar a linha com os formatos esperados. 

### Se (IF-ELSE)
Se for uma estrutura de decisão (ifelse) invoca a função `cmd.se`, com a 
seguinte representação do ifelse:
```
{TYPE = "IF", CMP = cmp, EXP = cmd.attr(attr)}
```
e
```
{TYPE = "IFLESE", CMP = cmp, EXP1 = exp1, EXP2 = exp2}
```

### Atribuição
Caso seja uma atribuição chama a função `cmd.attr`, podendo ser uma atribuição simples (`attrsimples`)
ou com operador (`attrop`), no arquivo `cmd.lua`:
```
{TYPE = "ATTRSIMPLE", VAR = Values.read(var), ARG = Values.read(arg)}
```
e
```
{TYPE = "ATTROP", VAR = Values.read(var),
   LEFT = Values.read(argleft), OP = op, RIGHT = Values.read(argright)}
```

### Chamada de função (FUNCALL)
A chamada de função é lida pela função `cmd.funcall`, podendo conter ou não argumentos:
```
{TYPE = "FUNCALL", NAME = name, VALUES = v}
```
Caso não contenha argumentos a variável `VALUES` é `nil`.

## Valores
Todos os argumentos dos comandos esperam um "valor" ou um "var". Devido a estrutura parecida:
```
<value> → <name>
        | <name>[ <number> ]
        | <number>
<var>   → <name>
        | <name>[ <number> ]
```
Utilizamos a mesma função (`values.read`) para lê-los, podendo ser um nome, número ou vetor:
```
{TYPE = "VECTOR", NAME = vector, POS = tonumber(pos)}
{TYPE = "NUMBER", VALUE = tonumber(number)}
{TYPE = "VAR", NAME = var}
```

## Match
Todos os regex utilizados são armazenados no arquivo `match.lua`.

## Inspect
O arquivo `inspect.lua` não partece ao projeto, ao final será removido. É utilizado para debug das
funções, formatando as tabelas de lua em um formato legível (`inspect(table)`).
