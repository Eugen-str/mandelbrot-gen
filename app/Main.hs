module Main where

import Codec.Picture
import System.Environment (getArgs)
import Control.Monad (when)
import System.Exit (exitSuccess)

maxIterations :: Int
maxIterations = 1000

hsvToRgb :: Int -> Int -> Int -> PixelRGB8
hsvToRgb h_ s_ v_= PixelRGB8 (round(r*255)) (round(g*255)) (round(b*255))
    where
        (r,g,b) = hsvToRgb_
        h = fromIntegral h_ / 360 :: Double
        s = fromIntegral s_ / 100 :: Double
        v = fromIntegral v_ / 100 :: Double

        i = floor(h*6) :: Int

        f = h * 6 - fromIntegral i
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)

        hsvToRgb_ :: (Double, Double, Double)
        hsvToRgb_ = case i `mod` 6 of
            0 -> (v, t, p)
            1 -> (q, v, p)
            2 -> (p, v, t)
            3 -> (p, q, v)
            4 -> (t, p, v)
            5 -> (v, p, q)
            _ -> error "impossible"

lerp :: Double -> Double -> Double -> Double
lerp s e t = s * (1 - t) + e * t

iterMandelbrot :: Double -> Double -> Int -> Double -> Double -> Int
iterMandelbrot za zb iter ca cb | (za*za + zb*zb) > 4 || iter == maxIterations = iter
                                | otherwise = iterMandelbrot newZa newZb (iter + 1) ca cb
    where
        newZa = za*za - zb*zb + ca
        newZb = 2*za*zb + cb

generateMandelbrot :: Int -> Int -> Int -> Int -> Double -> Double -> Double -> PixelRGB8
generateMandelbrot x y w h cx cy scale | nIter == maxIterations = PixelRGB8 0 0 0
                                       | otherwise = hsvToRgb (round(fromIntegral nIter / 100.0 * 360 :: Double)) 100 100
    where
        mapping = fromIntegral w / fromIntegral h * scale
        ca = cx + lerp (-mapping) mapping (fromIntegral x / fromIntegral w)
        cb = cy + lerp (-mapping) mapping (fromIntegral y / fromIntegral h)
        nIter = iterMandelbrot ca cb 0 ca cb

data Option = FileName String
            | Num Double
            deriving Show

getCli :: [String] -> [(String, Option)]
getCli [] = []
getCli args | length args >= 2 = case head args of
    "-x" -> ("x", Num nextDouble) : getCli rest
    "-y" -> ("y", Num nextDouble) : getCli rest
    "-w" -> ("w", Num nextDouble) : getCli rest
    "-zoom" -> ("scale", Num nextDouble) : getCli rest
    "-o" -> ("out", FileName next) : getCli rest
    _ -> error "Unknown option"
            | otherwise = error "Unknown option"
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
    "out" -> FileName "image.png"
    _ -> error $ "Unknown option: " <> s
getOption s opts | s == optName = optValue
                 | otherwise = getOption s rest
    where
        (optName, optValue) = head opts
        rest = tail opts

gd :: Option -> Double
gd (Num x) = x
gd _ = error "this error should be impossible"

gs :: Option -> String
gs (FileName x) = x
gs _ = error "this error should be impossible"

printHelp :: IO()
printHelp = putStrLn "Mandelbrot generator options:\n\
    \-x    : starting x\n\
    \-y    : starting y\n\
    \-w    : width (and height for now) of the image\n\
    \-zoom : starting zoom/scaling of the image\n\
    \-o    : filename of the generated image"

main :: IO ()
main = do
    args <- getArgs

    Control.Monad.when (head args == "help" || head args == "-h") $ do
        printHelp
        exitSuccess

    let cliArgs = getCli args
    let w = round $ gd $ getOption "w" cliArgs
    let cx = gd $ getOption "x" cliArgs
    let cy = gd $ getOption "y" cliArgs
    let scale = gd $ getOption "scale" cliArgs
    let out = gs $ getOption "out" cliArgs
    let img = ImageRGB8 (generateImage (\x y -> generateMandelbrot x y w w cx cy scale) w w)
    savePngImage out img
