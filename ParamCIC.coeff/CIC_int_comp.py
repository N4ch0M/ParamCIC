import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt

# Parámetros
fs = 2  # Frecuencia de muestreo normalizada (F_Nyquist = 1)
f_pass = 1 / 4  # Frecuencia de corte de la banda de paso
f_stop = 1 / 3  # Frecuencia de corte de la banda de stop
ripple_db = 0.1  # Ripple en la banda de paso en dB
attenuation_db = 80  # Atenuación en la banda de stop en dB

# Número de taps (coeficientes) del filtro
numtaps = 86  # Ajustar según la precisión que se desee

# Definir las bandas (normalizadas) y las ganancias deseadas (1 para paso, 0 para stop)
# Las bandas deben tener dos límites por cada banda: inicio y fin
bands = [0, f_pass, f_stop, 1]
desired = [1, 0]  # Banda de paso: 1, Banda de stop: 0


weight_pass = 10**(ripple_db / 20)  # Peso en la banda de paso
# Peso en la banda de stop: Inverso de 10^(atenuación / 20)
weight_stop = 1 / (10 ** (attenuation_db / 20))  # Peso en la banda de stop

# El arreglo de pesos debe ser del mismo tamaño que desired
weight = [weight_pass, weight_stop]  # Peso en la banda de paso y la banda de stop

# Diseñar el filtro utilizando Remez
coeffs = signal.remez(numtaps, bands, desired, weight=weight, fs=fs)

# Respuesta en frecuencia del filtro
w, h = signal.freqz(coeffs, worN=8000)
f = w / np.pi # Convertir a frecuencia en Hz

# Graficar la respuesta en frecuencia
plt.figure(figsize=(10, 6))
plt.plot(f, 20 * np.log10(abs(h)), 'b', label="Respuesta en frecuencia del FIR compensador")
plt.title("Respuesta en frecuencia del filtro FIR compensador PASABAJOS")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)
plt.axvline(f_pass, color='r', linestyle='--', label="Frecuencia de corte de la banda de paso")
plt.axvline(f_stop, color='g', linestyle='--', label="Frecuencia de corte de la banda de stop")
plt.legend()
plt.show()

# Guardar los coeficientes del filtro
np.savetxt("fir_compensador_pasabajos_coef.txt", coeffs, fmt="%.8f")
