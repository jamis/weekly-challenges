import System.Environment
import Data.Char

import Data.Map (Map)
import qualified Data.Map as Map

data Token = LParen
           | RParen
           | Plus
           | Minus
           | Times
           | Divide
           | Exp
           | Assn
           | Semi
           | Identifier String
           | Number Float deriving (Show)

data AST = Unary Token AST
         | Binary AST Token AST
         | Variable String
         | Literal Float deriving (Show)

type State = (AST, [Token])

tokenize :: String -> [Token]
tokenize "" = []
tokenize (' ':cs) = tokenize cs
tokenize (';':cs) = Semi:tokenize cs
tokenize ('=':cs) = Assn:tokenize cs
tokenize ('(':cs) = LParen:tokenize cs
tokenize (')':cs) = RParen:tokenize cs
tokenize ('+':cs) = Plus:tokenize cs
tokenize ('-':cs) = Minus:tokenize cs
tokenize ('*':cs) = Times:tokenize cs
tokenize ('/':cs) = Divide:tokenize cs
tokenize ('^':cs) = Exp:tokenize cs
tokenize (c:cs)
  | isDigit c =
      let (num, remainder) = parseNum cs [c]
      in (Number num):tokenize remainder
  | isAlpha c =
      let (ident, remainder) = parseIdent cs [c]
      in (Identifier ident):tokenize remainder
  | otherwise = error [c]

parseNum :: String -> String -> (Float, String)
parseNum (c:cs) agg
  | isDigit c || c == '.' = parseNum cs (c:agg)
parseNum list agg = (read $ reverse agg, list)

parseIdent :: String -> String -> (String, String)
parseIdent (c:cs) agg
  | isAlpha c = parseIdent cs (c:agg)
parseIdent list agg = (reverse agg, list)

parse :: [Token] -> AST
parse tokens =
  case statements tokens of (ast, []) -> ast
                            (ast, ts) -> error "trailing tokens"

binary :: AST -> Token -> State -> State
binary left op (right, tokens) = (Binary left op right, tokens)

statements :: [Token] -> State
statements tokens =
  case statement tokens of
    (left, (Semi:tokens)) -> binary left Semi (statements tokens)
    state                 -> state

statement :: [Token] -> State
statement tokens =
  case expression tokens of
    (left, (Assn:tokens)) -> binary left Assn (statement tokens)
    state                 -> state

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
factor ((Identifier id):tokens) = (Variable id, tokens)
factor tokens = error "invalid token"

evaluate :: AST -> Float
evaluate ast =
  let (result, vars) = evaluate' ast Map.empty
  in result

type VarMap = Map String Float

binaryEval :: AST -> (Float -> Float -> Float) -> AST -> VarMap -> (Float, VarMap)
binaryEval left fn right vars =
  let (leftResult, vars') = evaluate' left vars
      (rightResult, vars'') = evaluate' right vars'
  in (fn leftResult rightResult, vars'')

evaluate' :: AST -> VarMap -> (Float, VarMap)
evaluate' (Binary (Variable id) Assn right) vars =
  let (result, vars') = (evaluate' right vars)
      vars'' = Map.insert id result vars'
  in (result, vars'')
evaluate' (Binary left Assn right) vars = error "lhs is not a variable"
evaluate' (Binary left Plus right) vars = binaryEval left (+) right vars
evaluate' (Binary left Minus right) vars = binaryEval left (-) right vars
evaluate' (Binary left Times right) vars = binaryEval left (*) right vars
evaluate' (Binary left Divide right) vars = binaryEval left (/) right vars
evaluate' (Binary left Exp right) vars = binaryEval left (**) right vars
evaluate' (Binary left Semi right) vars = binaryEval left (\x y -> y) right vars
evaluate' (Unary Minus expr) vars =
  let (result, vars') = (evaluate' expr vars)
  in (-result, vars')
evaluate' (Variable id) vars =
  case Map.lookup id vars of
    Nothing -> error "undefined variable"
    Just x -> (x, vars)
evaluate' (Literal n) vars = (n, vars)

main :: IO ()
main = getArgs >>= print . evaluate . parse . tokenize . head
