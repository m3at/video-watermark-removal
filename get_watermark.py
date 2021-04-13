#!/usr/bin/env python3

import sys
from pathlib import Path

import imageio
import numpy as np
from scipy.ndimage import gaussian_filter


def normalize(x):
    _min = np.min(x)
    _max = np.max(x)
    return (x - _min) / (_max - _min)


if __name__ == "__main__":
    # Load all images
    root = Path(sys.argv[1])
    buff = []
    for p in root.glob("output_*.png"):
        buff.append(imageio.imread(p))
    images = np.array(buff)

    # Compute the gradients
    dx = np.gradient(images, axis=1).mean(axis=3)
    dy = np.gradient(images, axis=2).mean(axis=3)
    mean_dx = np.abs(np.mean(dx, axis=0))
    mean_dy = np.abs(np.mean(dy, axis=0))

    # Filter at a hand picked threshold
    threshold = 10
    salient = ((mean_dx > threshold) | (mean_dy > threshold)).astype(float)
    salient = normalize(gaussian_filter(salient, sigma=3))
    mask = ((salient > 0.2) * 255).astype(np.uint8)

    # Saved the computed mask
    imageio.imsave(root / "mask.png", mask)
