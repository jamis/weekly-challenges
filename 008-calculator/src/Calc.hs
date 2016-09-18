import System.Environment
import Data.Char

data Token = LParen
           | RParen
           | Plus
           | Minus
           | Times
           | Divide
           | Exp
           | Number Int deriving (Show)

data AST = Unary Token AST
         | Binary AST Token AST
         | Literal Int deriving (Show)

type State = (AST, [Token])

tokenize :: String -> [Token]
tokenize "" = []
tokenize (' ':cs) = tokenize cs
tokenize ('(':cs) = LParen:tokenize cs
tokenize (')':cs) = RParen:tokenize cs
tokenize ('+':cs) = Plus:tokenize cs
tokenize ('-':cs) = Minus:tokenize cs
tokenize ('*':cs) = Times:tokenize cs
tokenize ('/':cs) = Divide:tokenize cs
tokenize ('^':cs) = Exp:tokenize cs
tokenize (c:cs)
  | isDigit c = (Number $ digitToInt c):tokenize cs
  | otherwise = error [c]

parse :: [Token] -> AST
parse tokens =
  case expression tokens of (ast, []) -> ast
                            (ast, ts) -> error "trailing tokens"

binary :: AST -> Token -> State -> State
binary left op (right, tokens) = (Binary left op right, tokens)

expression :: [Token] -> State
expression tokens =
  case term tokens of
    (left, (Plus:tokens))  -> binary left Plus (expression tokens)
    (left, (Minus:tokens)) -> binary left Minus (expression tokens)
    state                  -> state

term :: [Token] -> State
term tokens =
  case expterm tokens of
    (left, (Times:tokens))  -> binary left Times (term tokens)
    (left, (Divide:tokens)) -> binary left Divide (term tokens)
    state                   -> state

expterm :: [Token] -> State
expterm tokens =
  case factor tokens of
    (left, (Exp:tokens)) -> binary left Exp (expterm tokens)
    state                -> state

factor :: [Token] -> State
factor (Minus:tokens) =
  let (value, tokens') = factor tokens
  in (Unary Minus value, tokens')
factor (LParen:tokens) =
  let (ast, tokens') = expression tokens
      (RParen:tokens'') = tokens'
  in (ast, tokens'')
factor ((Number n):tokens) = (Literal n, tokens)
factor tokens = error "invalid token"

evaluate :: (Floating a) => AST -> a
evaluate (Binary left Plus right) = (evaluate left) + (evaluate right)
evaluate (Binary left Minus right) = (evaluate left) - (evaluate right)
evaluate (Binary left Times right) = (evaluate left) * (evaluate right)
evaluate (Binary left Divide right) = (evaluate left) / (evaluate right)
evaluate (Binary left Exp right) = (evaluate left) ** (evaluate right)
evaluate (Unary Minus expr) = - (evaluate expr)
evaluate (Literal n) = fromIntegral(n)

main :: IO ()
main = getArgs >>= print . evaluate . parse . tokenize . head
