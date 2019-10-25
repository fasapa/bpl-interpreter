-- Regex utilizado pelo interpretador

match = {}

-- (%l+): nome da função. %((.*)%): lista de argumentos (pode ser vazio).
match.header = "^function (%l+)%((.*)%)$"

match.var    = "^var (.+)$"

-- Números positivos maiores que zero.
match.size   = "[1-9][0-9]*"

-- Números inteiros
match.number = "%-?%d+"

-- (%l+): nome da variável. %[(" .. match.size .. ")%]: tamanho da variável (vetor).
match.varv   = "^(%l+)%[(" .. match.size .. ")%]$"

-- (%l+): nome da função. %((.*)%): lista de argumentos.
match.funcall = "(%l+)%((.*)%)"

-- (.+): variável atribuida. (.+): arg esquerdo. (.+) arg direito. [%+%-%*/]: operadores +-*/
match.attrop = "(.+) = (.+) ([%+%-%*/]) (.+)$"

-- (.+): variável atribuida. (.+): argumentos.
match.attr = "(.+) = (.+)$"

-- (%l+): nome do vetor. %[(" .. match.number .. ")%]: posição de acesso (vetor).
match.vector = "^(%l+)%[(" .. match.number .. ")%]$"

-- (.+): comparação do if.
match.se = "^if (.+) then$"

-- (.+): atribuição do fi
match.fi = "(.+) fi$"

-- (.+): atribuicao do else
match.senao = "(.+) else$"

return match
