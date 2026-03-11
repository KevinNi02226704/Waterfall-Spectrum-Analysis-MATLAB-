# Waterfall Spectrum Analysis (MATLAB)

This project provides a MATLAB script for generating a **waterfall spectrum (time–frequency–amplitude plot)** from an audio signal.  
The script computes the **Short-Time Fourier Transform (STFT)** of the signal and visualizes the spectral evolution over time as a 3D surface.

The output includes:

- a **3D waterfall plot** (frequency–time–amplitude)
- an exported **TXT dataset** containing frequency, time, and amplitude values

This tool was developed for analyzing vibration and wave signals in the **Waves on String experiment**.

---

## Method

The script performs a **Short-Time Fourier Transform (STFT)** using overlapping Hann windows.

Key steps:

1. **Audio Input**
   - Reads an audio file (wav / m4a / mp3)
   - Converts to mono
   - Normalizes the signal
   - Resamples to a target sampling rate if necessary

2. **Windowed FFT**
   - Applies a Hann window
   - Uses overlapping frames
   - Computes the FFT of each frame

3. **Spectral Conversion**
   - Converts magnitude to **decibels**
   - Limits the frequency range of interest
   - Applies a brightness range for visualization

4. **3D Waterfall Visualization**

The resulting plot uses:

- **X axis:** Frequency (Hz)  
- **Y axis:** Time (s)  
- **Z axis:** Amplitude (dB)

A logarithmic frequency axis is used to better visualize spectral features.

---
