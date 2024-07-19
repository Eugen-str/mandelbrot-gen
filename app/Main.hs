module Main where

import Codec.Picture
import System.Environment (getArgs)

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
                                       | otherwise = hsvToRgb (round(fromIntegral nIter / 100.0 * 360)) 100 100
    where
        mapping = fromIntegral w / fromIntegral h * scale
        ca = cx + lerp (-mapping) mapping (fromIntegral x / fromIntegral w)
        cb = cy + lerp (-mapping) mapping (fromIntegral y / fromIntegral h)
        nIter = iterMandelbrot ca cb 0 ca cb

main :: IO ()
main = do
    args <- getArgs
    let w = read $ head args
    let cx = read $ args !! 1
    let cy = read $ args !! 2
    let scale = read $ args !! 3
    let img = ImageRGB8 (generateImage (\x y -> generateMandelbrot x y w w cx cy scale) w w)
    savePngImage "test.png" img
