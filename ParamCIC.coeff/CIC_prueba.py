import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

R, M, N = 10, 1, 3
f_clk = 25e6
fc = f_clk / (2 * R * M)  # Frecuencia de corte

# Respuesta en frecuencia
b = np.ones(R * M)  # Coeficientes del comb
a = [1, -1]         # Coeficientes del integrador
w, h = signal.freqz(b, a, worN=8000, fs=f_clk)
h_mag = np.abs(h) ** N

plt.figure()
plt.plot(w, 20 * np.log10(h_mag + 1e-10))  # +1e-10 evita log(0)
plt.axvline(f_clk / (2 * R * M), color='r', linestyle='--', label='f_c ≈ 1.25 MHz')
plt.title('Respuesta en Magnitud (dB)')
plt.xlabel('Frecuencia (Hz)')
plt.ylabel('Ganancia (dB)')
plt.ylim(-100, 100)  # Límites típicos para dB
plt.grid()
plt.legend()
plt.show()

from scipy.signal import firwin2
# Diseña un FIR que compense la caída del CIC
taps = firwin2(numtaps=31, freq=[0, 0.1, 1], gain=[1, 1, 0], fs=2)
w_comp, h_comp = signal.freqz(taps, fs=f_clk)
plt.plot(w, 20 * np.log10(np.abs(h_comp) * h_mag_normalized))