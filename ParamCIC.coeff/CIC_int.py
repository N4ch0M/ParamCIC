"""Parameterized CIC Interpolation Filter using Python"""

#%% Bloque 1 Genera el filtro CIC Interpolador
# ============================================

# Importa librerías
import numpy as np
import matplotlib.pyplot as plt

# Parámetros
f_clk = 25e6        # Frecuencia de reloj en Hz
R = 10              # Factor de interpolación
M = 1               # Retardo diferencial
N = 3               # Número de secciones

# El filtro CIC se puede representar como una cascada de integradores y combinadores.
# H(s) = (1 - z^(-M))^num_sections / (1 - z^(-1))^num_sections
# Para esto, usamos la versión digital del filtro.

# Función de transferencia en frecuencia
z = np.exp(2j * np.pi * np.linspace(0, 0.5, 1024))

# Respuesta en frecuencia del filtro CIC (en términos de Z)
numerator = (1 - z**(-R*M))**N
denominator = (1 - z**(-1))**N
# Evita división por cero en el denominador (evitar que se aproxime a cero)
denominator = np.where(np.abs(denominator) < 1e-9, 1e-9, denominator)

# Respuesta en frecuencia
h = numerator / denominator
# Magnitud de la respuesta en frecuencia
magnitude = np.abs(h)
# Reemplaza los valores cercanos a cero con un valor mínimo pequeño
magnitude = np.maximum(magnitude, 1e-9)

# Frecuencia normalizada
f = np.linspace(0, f_clk/2, 1024)

# ========================
# Muestra los resultados
# ========================

# Graficamos la comparación
plt.figure(figsize=(10, 6))

# Magnitud en dB
plt.plot(f, 20 * np.log10(magnitude), label='CIC')

# Personaliza la gráfica
plt.title('Respuesta en Frecuencia')
plt.xlabel('Frecuencia (Hz)')
plt.ylabel('Magnitud (dB)')
plt.grid(True)
plt.legend()
plt.ylim(-50, 50)
plt.tight_layout()
plt.show()

# %% Bloque 2 Verificación del filtro
# =====================================

# ======================================================================
# Genera una señal temporal (suma de señales de diferentes frecuencias)
# ======================================================================

# Vector de tiempo, 1 ms con frecuencia de muestreo f_clk
f_clk = 25e6        # Frecuencia de reloj
t = np.linspace(0, 0.01, int(0.01 * f_clk), endpoint=False)  

# Señal mixta con dos frecuencias
f1 = 1e6
f2 = 8e6
signal = 0.5 * np.sin(2 * np.pi * f1 * t) + 0.35 * np.sin(2 * np.pi * f2 * t)

# Filtrar la señal usando el filtro CIC
filtered_signal = np.convolve(signal, h, mode='same')

# Graficar la señal original y la filtrada en el dominio del tiempo
plt.figure(figsize=(10, 6))

# Señal original
muestras = 200
plt.subplot(2, 2, 1)
plt.plot(t[muestras*2:muestras*3], signal[muestras*2:muestras*3])  # Se muestra una porción para mejor visualización
plt.title("Señal original en el dominio del tiempo")
plt.xlabel("Tiempo (s)")
plt.ylabel("Amplitud")
plt.grid(True)

# Señal filtrada
plt.subplot(2, 2, 2)
plt.plot(t[muestras*2:muestras*3], filtered_signal[muestras*2:muestras*3])
plt.title("Señal filtrada en el dominio del tiempo")
plt.xlabel("Tiempo (s)")
plt.ylabel("Amplitud")
plt.grid(True)

# Transformada de Fourier (FFT)
n_fft = 2**14  # Tamaño de la FFT
f_signal = np.fft.fft(signal, n_fft)
f_filtered_signal = np.fft.fft(filtered_signal, n_fft)

# Normalización y espectro unilateral
f_signal_mag = np.abs(f_signal[:n_fft//2]) / (n_fft//2)
f_filtered_signal_mag = np.abs(f_filtered_signal[:n_fft//2]) / (n_fft//2)

# Eje de frecuencias
f_axis = np.fft.fftfreq(n_fft, 1/f_clk)[:n_fft//2]  # Solo parte positiva

# Gráfico en el dominio de la frecuencia
plt.subplot(2, 2, 3)
plt.plot(f_axis, 20 * np.log10(f_signal_mag), label="Señal original")
plt.title("Espectro de la señal original")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)
plt.ylim(-100, 0)

plt.subplot(2, 2, 4)
plt.plot(f_axis, 20 * np.log10(f_filtered_signal_mag), label="Señal filtrada")
plt.title("Espectro de la señal filtrada")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)
plt.ylim(-20, 60)

plt.tight_layout()
plt.show()

# %% Bloque 3 Guarda para usar como señal en el testbench
# =========================================================

# ======================================================================
# Escribe los datos a un archivo
# ======================================================================

# Acoto la señal
signal_limited = signal[:muestras]

# Escalado para N bits
N_bits       = 16
scale_factor = 2**(N_bits-1)
# Redondeo y conversión a enteros
sig_scaled = np.round(signal_limited * scale_factor).astype(int)

sig_name = f"..\\ParamCIC.srcs\\sim_1\\data\\input_signal_{N_bits}bit.dat"

with open(sig_name, "w", encoding="utf-8") as file:
    for data in sig_scaled:
        # Convertir a complemento a dos (para N bits)
        if data < 0:
            data = (1 << N_bits) + data
        # Escribir en hexadecimal con salto de línea
        file.write(f"{data:04X}\n")

# Mensaje de confirmación mejorado
print(f"✅ Señal de entrada guardada en '{sig_name}'")
print(f"📂 Ubicación: {sig_name}")
print(f"🔢 Total de muestras: {len(sig_scaled)}")


# %%
