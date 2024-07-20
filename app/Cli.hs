module Cli where

data Option = Str String
            | Num Double
            deriving Show

getCli :: [String] -> [(String, Option)]
getCli [] = []
getCli args | length args >= 2 = case head args of
    "-x" -> ("x", Num nextDouble) : getCli rest
    "-y" -> ("y", Num nextDouble) : getCli rest
    "-w" -> ("w", Num nextDouble) : getCli rest
    "-zoom" -> ("scale", Num nextDouble) : getCli rest
    "-color" -> ("palette", Str next) : getCli rest
    "-o" -> ("out", Str next) : getCli rest
    _ -> error "Unknown option"
            | otherwise = error $ "Value for " <> head args <> " not provided"
    where
        nextDouble = read (head $ tail args) :: Double
        next = head $ tail args
        rest = drop 2 args

getOption :: String -> [(String, Option)] -> Option
getOption s [] = case s of
    "x" -> Num 0
    "y" -> Num 0
    "w" -> Num 1000
    "scale" -> Num 1.5
    "out" -> Str "test.png"
    "palette" -> Str "basic"
    _ -> error $ "Unknown option: " <> s
getOption s opts | s == optName = optValue
                 | otherwise = getOption s rest
    where
        (optName, optValue) = head opts
        rest = tail opts

gd :: Option -> Double
gd (Num x) = x
gd _ = error "Unreachable code"

gs :: Option -> String
gs (Str x) = x
gs _ = error "Unreachable code"

printHelp :: IO()
printHelp = putStrLn "Mandelbrot generator options:\n\
    \-x    : starting x\n\
    \-y    : starting y\n\
    \-w    : width (and height for now) of the image\n\
    \-zoom : starting zoom/scaling of the image\n\
    \-color: the color palette used for the generation\n\
    \    basic -- basic histogram coloring, the default option\n\
    \    continous -- basic smoothing\n\
    \-o    : filename of the generated image"

